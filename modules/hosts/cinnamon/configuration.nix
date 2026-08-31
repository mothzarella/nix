{
  config,
  secret,
  ...
}: let
  inherit (config.flake.modules) nixos;
in {
  flake.modules.nixos.cinnamon = {lib, ...}: {
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

    # -------------------------------------------------------------------- theme
    # 1739/52865, exposed by i2c as VEN_06CB:00.
    kconfig.kcminputrc.Libinput."1739"."52865"."VEN_06CB:00 06CB:CE81 Touchpad".NaturalScroll = true;

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
