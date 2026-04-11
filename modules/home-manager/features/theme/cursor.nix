{
  self,
  inputs,
  ...
}: {
  flake.homeModules."features/theme" = {
    config,
    pkgs,
    lib,
    ...
  }:
    with lib; let
      cfg = config.features.theme.cursor;
    in {
      options.features.theme.cursor = {
        enable = mkEnableOption "cursor theme via stylix";

        source = mkOption {
          type = types.str;
          description = "URL of the cursor archive.";
        };
        hash = mkOption {
          type = types.str;
          description = "Hash of the cursor archive.";
        };
        name = mkOption {
          type = types.str;
          description = "Name of the cursor theme directory inside the archive.";
        };
        size = mkOption {
          type = types.int;
          default = 24;
          description = "Cursor size in pixels.";
        };
      };

      config = mkIf cfg.enable {
        assertions = [
          {
            assertion = config.features.theme.enable;
            message = "features/theme/cursor requires features.theme.enable = true (import features/theme)";
          }
        ];

        stylix.cursor = {
          name = cfg.name;
          size = cfg.size;
          package = pkgs.runCommand "cursor-${cfg.name}" {} ''
            mkdir -p $out/share/icons
            ln -s ${pkgs.fetchzip {
              url = cfg.source;
              hash = cfg.hash;
            }} $out/share/icons/${cfg.name}
          '';
        };

        home.pointerCursor = {
          enable = true;
          gtk.enable = true;
          sway.enable = true;
          x11 = {
            enable = true;
            defaultCursor = cfg.name;
          };
          hyprcursor.size = cfg.size;
        };
      };
    };
}
