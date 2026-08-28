{
  config,
  secret,
  ...
}: let
  inherit (config.flake.modules) nixos;
in {
  flake.modules.nixos.cinnamon = {lib, ...}: {
    imports = with nixos; [
      aeroshell
      btrfs-rollback
      networking
      performance
      preservation
      secure-boot
      tar
    ];

    # ------------------------------------------------------------------ session
    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      autoLogin = {
        enable = true;
        user = "tar";
      };
    };

    environment.etc."aeroshell/wallpaper".source = ./wallpaper.webp;

    # ----------------------------------------------------------------- hardware
    hardware.facter = {
      reportPath = ./facter.json;
      detected.boot.graphics.kernelModules = lib.mkForce ["i915"];
    };

    # ------------------------------------------------------------- preservation
    preservation.preserveAt."/persistent" = {
      directories = [
        "/var/lib/AccountsService"
        "/var/lib/power-profiles-daemon"
        "/var/lib/systemd/backlight"
        "/var/lib/systemd/rfkill"
        "/var/lib/upower"
        (secret "/var/lib/bluetooth")
        (secret "/var/lib/iwd")
      ];

      users.tar.directories = [
        "Desktop"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Public"
        "Templates"
        "Videos"
      ];
    };

    system.stateVersion = "26.05";
  };
}
