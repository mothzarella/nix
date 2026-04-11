{
  self,
  inputs,
  ...
}: {
  flake.homeModules."features/theme" = {
    lib,
    config,
    pkgs,
    ...
  }:
    with lib; let
      cfg = config.features.theme;
    in {
      imports = [inputs.stylix.homeModules.stylix];
      options.features.theme = {
        enable = mkEnableOption "custom theme via stylix";

        # Wrapper
        polarity = mkOption {
          type = types.enum ["dark" "light" "either"];
          default = "dark";
        };
        wallpaper = mkOption {
          type = types.path;
        };
        scheme = mkOption {
          type = types.path;
        };
        targets = mkOption {
          type = types.attrsOf types.anything;
          default = {};
          description = "Stylix targets passed directly to stylix.targets";
        };
      };

      config = mkIf cfg.enable {
        stylix = {
          enable = true;
          polarity = cfg.polarity;
          autoEnable = false;
          image = cfg.wallpaper;
          base16Scheme = cfg.scheme;
          targets = cfg.targets;
        };
      };
    };
}
