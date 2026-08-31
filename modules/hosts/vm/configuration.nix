{config, ...}: let
  inherit (config.flake.modules) nixos;
in {
  flake.modules.nixos.vm = {
    imports = with nixos; [
      aeromoe
    ];

    # ------------------------------------------------------------------ session
    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      autoLogin = {
        enable = true;
        user = "test";
      };
    };

    system.stateVersion = "26.05";
  };
}
