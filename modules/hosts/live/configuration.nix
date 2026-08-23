{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (config.flake.modules) nixos;
in {
  flake.modules.nixos.live = {
    config,
    modulesPath,
    pkgs,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) system;

    name = "live-${config.system.nixos.release}-${inputs.self.shortRev or "dirty"}-${pkgs.stdenv.hostPlatform.uname.processor}";

    live = pkgs.writeShellApplication {
      name = "live";
      runtimeInputs = [
        pkgs.gum
        pkgs.mkpasswd
        pkgs.util-linux
        inputs.disko.packages.${system}.disko-install
      ];
      text = ''
        [ "$(id -u)" -eq 0 ] || exec sudo -- "$0" "$@"

        flake=/iso/flake

        host=$(
          nix eval --raw "$flake#diskoConfigurations" \
            --apply 'cs: builtins.concatStringsSep "\n" (builtins.attrNames cs)' |
            gum choose --header "Host to install"
        )

        disk=$(
          lsblk -dnpo PATH,SIZE,MODEL |
            gum choose --header "Target disk" |
            awk '{print $1}'
        )

        password=$(gum input --password --header "Password for tar")

        gum confirm "Erase $disk and install $host?" || exit 1

        extra=$(mktemp -d)
        trap 'rm -rf "$extra"' EXIT
        mkdir -p "$extra/passwords"
        (umask 077 && mkpasswd -m yescrypt "$password" >"$extra/passwords/tar")

        disko-install --flake "$flake#$host" --disk main "$disk" \
          --write-efi-boot-entries \
          --extra-files "$extra/passwords" /persistent/passwords
      '';
    };
  in {
    imports = [
      nixos.networking
      "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel.nix"
    ];

    image.baseName = lib.mkImageMediaOverride name;

    isoImage = {
      volumeID = name;

      appendToMenuLabel = "";
      edition = "";

      contents = [
        {
          source = lib.sources.cleanSource inputs.self;
          target = "/flake";
        }
      ];
    };

    environment.systemPackages = [live pkgs.nixos-facter];
    environment.defaultPackages = lib.mkForce [];

    
    system.extraDependencies = builtins.attrValues inputs;

    nix.settings.http-connections = 128;
    nix.settings.max-substitution-jobs = 32;

    users.mutableUsers = true; # passwordless users

    zramSwap.enable = true; # evaluating a host takes more RAM than a small machine has

    boot.kernelParams = ["toram"]; # squashfs into RAM, stick can be unplugged
    boot.swraid.enable = lib.mkForce false;
    boot.supportedFilesystems.zfs = false;

    documentation.enable = lib.mkForce false;
    documentation.nixos.enable = lib.mkForce false;

    system.switch.enable = false;
    system.installer.channel.enable = false;
  };
}
