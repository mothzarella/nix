{inputs, ...}: let
  mountOptions = ["compress=zstd" "noatime"];

  layout.disko.devices.disk.main = {
    device = "/dev/disk/by-id/nvme-tin076";
    type = "disk";

    content.type = "gpt";

    content.partitions.esp = {
      name = "ESP";
      type = "EF00";
      size = "1G";

      content.type = "filesystem";
      content.format = "vfat";
      content.mountpoint = "/boot";
      content.mountOptions = ["umask=0077"];
    };

    content.partitions.swap = {
      size = "4G";
      content.type = "swap";
    };

    content.partitions.root = {
      name = "root";
      size = "100%";

      content.type = "luks";
      content.name = "cryptroot";
      content.settings.allowDiscards = true;

      content.content.type = "btrfs";
      content.content.extraArgs = ["-f"];

      content.content.subvolumes."/root" = {
        inherit mountOptions;
        mountpoint = "/";
      };
      content.content.subvolumes."/persistent" = {
        inherit mountOptions;
        mountpoint = "/persistent";
      };
      content.content.subvolumes."/nix" = {
        inherit mountOptions;
        mountpoint = "/nix";
      };
    };
  };
in {
  imports = [inputs.disko.flakeModules.disko];

  flake = {
    diskoConfigurations.tin076 = layout;

    modules.nixos.tin076 = {
      imports = [inputs.disko.nixosModules.disko];
      inherit (layout) disko;
    };
  };
}
