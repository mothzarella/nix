{
  flake.modules.nixos.theme = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.theme;
    inherit (config.lib.theme) colors;
  in {
    config = lib.mkIf cfg.enable {
      theme.packages.aero-bar = pkgs.aero-bar.override {
        theme = {
          foreground = colors.base05.hash;
          dim = colors.base03.hash;
          accent = colors.base0D.hash;
          hover = colors.base0C.hash;
          fontFamily = cfg.fonts.sansSerif.name;
        };
      };
    };
  };
}
