{config, ...}: let
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

    theme.wallpaper = ./wallpaper.webp;

    hardware.facter = {
      reportPath = ./facter.json;
      detected.boot.graphics.kernelModules = lib.mkForce ["i915"];
    };

    # 1739/52865, exposed by i2c as VEN_06CB:00.
    environment.etc."xdg/kcminputrc".text = lib.mkAfter ''
      [Libinput][1739][52865][VEN_06CB:00 06CB:CE81 Touchpad]
      NaturalScroll=true
    '';

    system.stateVersion = "26.11";
  };
}
