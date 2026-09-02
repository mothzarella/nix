{config, ...}: let
  inherit (config.flake.modules) nixos;
in {
  flake.modules.nixos.tin076 = {
    lib,
    pkgs,
    ...
  }: {
    imports = with nixos; [
      aeromoe
      btrfs-rollback
      performance
      preservation
      secure-boot
      tar
      virtualisation
    ];

    theme.wallpaper = ./wallpaper.webp;

    hardware.facter = {
      reportPath = ./facter.json;
      detected.boot.graphics.kernelModules = lib.mkForce ["i915"];
    };

    users.users.tar.packages = with pkgs; [
      jetbrains.pycharm
      teams-for-linux
    ];

    # 1739/53184, exposed by i2c as VEN_06CB:00.
    environment.etc."xdg/kcminputrc".text = lib.mkAfter ''
      [Libinput][1739][53184][VEN_06CB:00 06CB:CFC0 Touchpad]
      NaturalScroll=true
    '';

    preservation.preserveAt."/persistent".users.tar.directories = [
      ".config/JetBrains"
      ".local/share/JetBrains"
      ".config/teams-for-linux"
    ];

    system.stateVersion = "26.11";
  };
}
