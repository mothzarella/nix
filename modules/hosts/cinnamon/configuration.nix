{
  config,
  lib,
  ...
}: let
  inherit (config.flake.modules) nixos;
in {
  flake.modules.nixos.cinnamon = {pkgs, ...}: {
    imports = with nixos; [
      btrfs-rollback
      networking
      performance
      preservation
      secure-boot
      tar
    ];

    hardware.facter.reportPath = ./facter.json;
    hardware.facter.detected.boot.graphics.kernelModules = lib.mkForce ["i915"];

    # graphical session --------------------------------------------------------

    services.desktopManager.cosmic.enable = true;
    environment.cosmic.excludePackages = with pkgs; [
      cosmic-edit
      cosmic-player
      cosmic-reader
      cosmic-store
      cosmic-term
      cosmic-wallpapers
      networkmanagerapplet
    ];

    programs.foot.enable = true;

    environment.sessionVariables = {
      TERMINAL = "foot";
      COSMIC_DATA_CONTROL_ENABLED = 1;
    };

    services.system76-scheduler.enable = true;

    services.displayManager.cosmic-greeter.enable = true;
    services.displayManager.autoLogin = {
      enable = true;
      user = "tar";
    };

    preservation.preserveAt."/persistent".directories = [
      "/var/lib/AccountsService"
      "/var/lib/power-profiles-daemon"
      "/var/lib/systemd/backlight"
      "/var/lib/systemd/rfkill"
      "/var/lib/upower"
      {
        directory = "/var/lib/bluetooth";
        mode = "0700";
      }
      {
        directory = "/var/lib/iwd";
        mode = "0700";
      }
    ];

    preservation.preserveAt."/persistent".users.tar.directories = [
      ".config/cosmic"
      "Desktop"
      "Documents"
      "Downloads"
      "Music"
      "Pictures"
      "Public"
      "Templates"
      "Videos"
    ];

    system.stateVersion = "26.05";
  };
}
