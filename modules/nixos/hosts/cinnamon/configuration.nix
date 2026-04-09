{
  config,
  inputs,
  withSystem,
  ...
}: let
  hostName = "cinnamon";
in {
  flake = {
    nixosConfigurations.${hostName} = withSystem "x86_64-linux" ({pkgs, ...}:
      inputs.nixpkgs.lib.nixosSystem {
        inherit pkgs;
        modules = [config.flake.nixosModules."hosts/${hostName}"];
      });

    nixosModules."hosts/${hostName}" = {pkgs, ...}: {
      imports = [
        inputs.nixos-hardware.nixosModules.common-cpu-intel
        inputs.nixos-hardware.nixosModules.common-gpu-nvidia-sync

        config.flake.nixosModules."users/tar" # User
        config.flake.nixosModules."hosts/cinnamon/hardware" # Hardware
        config.flake.nixosModules.storage # Disk
      ];

      # Enable experimental features
      nix.settings.experimental-features = ["nix-command" "flakes"];

      # Run unpatched dynamic binaries
      programs.nix-ld.enable = true;

      networking = {
        inherit hostName;
        networkmanager.enable = true;
      };

      boot.kernelPackages = pkgs.stable.linuxPackages_zen;
      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      time.timeZone = "Europe/Rome";
      i18n.defaultLocale = "en_US.UTF-8";

      # Persistent -------------------------------------------------------------

      environment.persistence."/persistent" = {
        hideMounts = true;
        directories = [
          "/var/log"
          "/var/lib/bluetooth"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/etc/NetworkManager/system-connections"
          {
            directory = "/var/lib/colord";
            user = "colord";
            group = "colord";
            mode = "u=rwx,g=rx,o=";
          }
        ];
        files = [
          "/etc/machine-id"
          {
            file = "/var/keys/secret_file";
            parentDirectory = {mode = "u=rwx,g=,o=";};
          }
        ];
      };

      # Users ------------------------------------------------------------------

      environment.systemPackages = with pkgs; [
        vim # must have editor
        gcc # GNU compiler
        git # version control
        openssl # secure communication

        # TODO: to remove
        fuzzel
        neovim
      ];

      users.users.root.hashedPassword = "!";

      # Session ----------------------------------------------------------------

      services.displayManager.gdm = {
        enable = true;
        wayland = true;
      };

      programs.niri.enable = true;

      programs.uwsm = {
        enable = true;
        waylandCompositors.niri = {
          prettyName = "Niri";
          comment = "Niri scrollable-tiling Wayland compositor";
          binPath = "/run/current-system/sw/bin/niri";
        };
      };

      programs.xwayland = {
        enable = true;
        package = pkgs.xwayland-satellite;
      };

      security = {
        polkit.enable = true;
        rtkit.enable = true;
      };

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome

          # Fallback
          xdg-desktop-portal-gtk
        ];
      };

      services.gnome.gnome-keyring.enable = true;
      system.stateVersion = "25.11";
    };
  };
}
