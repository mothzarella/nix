{inputs, ...}: {
  flake.nixosModules.storage = {
    config,
    lib,
    pkgs,
    ...
  }:
    with lib; let
      cfg = config.features.storage.impermanence;

      btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
      findBin = "${pkgs.findutils}/bin/find";
    in {
      imports = [inputs.impermanence.nixosModules.impermanence];

      options.features.storage.impermanence = {
        enable = mkEnableOption "Whether to enable `wipe-on-boot` via btrfs subvolume rotation";

        btrfsDevice = mkOption {
          type = types.str;
          default =
            if config.features.storage.disko.luks.enable
            then "/dev/mapper/cryptroot"
            else "/dev/disk/by-partlabel/root";
        };

        retentionDays = mkOption {
          type = types.int;
          default = 30;
        };
      };

      config = mkIf cfg.enable {
        fileSystems."/persistent".neededForBoot = true;

        # Filesystem in Userspace
        programs.fuse.userAllowOther = true;

        # Delete all files in `/tmp` during boot
        boot.tmp.cleanOnBoot = mkDefault true;

        boot.initrd.systemd = {
          enable = mkDefault true;
          storePaths = with pkgs; [
            btrfs-progs
            findutils
          ];
        };

        # Wipe on Root
        boot.initrd.systemd.services.wipe-root = {
          description = "Wipe root subvolume on boot";
          wantedBy = ["initrd.target"];
          after = ["cryptsetup.target"];
          before = ["sysroot.mount"];
          unitConfig.DefaultDependencies = false;
          serviceConfig.Type = "oneshot";
          script = ''
            set -euo pipefail

            mkdir -p /btrfs_tmp
            mount ${escapeShellArg cfg.btrfsDevice} /btrfs_tmp

            if [[ -e /btrfs_tmp/@root ]]; then
              mkdir -p /btrfs_tmp/@old_roots
              timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@root)" "+%Y-%m-%d_%H:%M:%S")
              mv /btrfs_tmp/@root "/btrfs_tmp/@old_roots/$timestamp"
            fi

            delete_subvolume_recursively() {
              IFS=$'\n'
              for i in $(${btrfs} subvolume list -o "$1" | cut -f 9- -d ' '); do
                delete_subvolume_recursively "/btrfs_tmp/$i"
              done
              ${btrfs} subvolume delete "$1"
            }

            for i in $(${findBin} /btrfs_tmp/@old_roots/ -maxdepth 1 -mtime +${toString cfg.retentionDays} 2>/dev/null); do
              delete_subvolume_recursively "$i"
            done

            ${btrfs} subvolume create /btrfs_tmp/@root
            umount /btrfs_tmp
          '';
        };
      };
    };
}
