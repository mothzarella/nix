{
  config,
  secret,
  ...
}: let
  inherit (config.flake.modules) nixos;
in {
  flake.modules.nixos.tin076 = {lib, ...}: {
    imports = with nixos; [
      aeromoe
      btrfs-rollback
      performance
      preservation
      secure-boot
      tar
    ];

    hardware.facter = {
      reportPath = ./facter.json;
      detected.boot.graphics.kernelModules = lib.mkForce ["i915"];
    };

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
        # "Downloads"
        "Music"
        "Pictures"
        "Public"
        "Templates"
        "Videos"
      ];
    };

    system.stateVersion = "26.11";
  };
}
