{config, ...}: let
  inherit (config.flake.modules) nixos;
in {
  flake.modules.nixos.vm = {
    imports = with nixos; [
      aeromoe
    ];

    theme.wallpaper = ./wallpaper.webp;

    services.displayManager.autoLogin = {
      enable = true;
      user = "test";
    };

    system.stateVersion = "26.05";
  };
}
