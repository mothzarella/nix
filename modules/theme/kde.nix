{
  flake.modules.nixos.theme = {
    config,
    lib,
    ...
  }: let
    cfg = config.theme;
    inherit (config.lib.theme) colors;
    inherit (config.lib.kconfig) immutable;

    palette = {
      BackgroundNormal = colors.base00.rgb;
      BackgroundAlternate = colors.base01.rgb;
      ForegroundNormal = colors.base05.rgb;
      ForegroundActive = colors.base05.rgb;
      ForegroundInactive = colors.base03.rgb;
      ForegroundLink = colors.base0D.rgb;
      ForegroundVisited = colors.base0E.rgb;
      ForegroundNegative = colors.base08.rgb;
      ForegroundNeutral = colors.base0A.rgb;
      ForegroundPositive = colors.base0B.rgb;
      DecorationFocus = colors.base0D.rgb;
      DecorationHover = colors.base0D.rgb;
    };

    selection =
      palette
      // {
        BackgroundNormal = colors.base0D.rgb;
        BackgroundAlternate = colors.base0D.rgb;
        ForegroundNormal = colors.base00.rgb;
        ForegroundActive = colors.base00.rgb;
        ForegroundInactive = colors.base00.rgb;
      };

    qtFont = family: size: "${family},${toString size},-1,5,50,0,0,0,0,0";
    desktopFont = qtFont cfg.fonts.sansSerif.name cfg.fonts.sizes.desktop;
  in {
    config = lib.mkIf cfg.enable {
      kconfig = {
        kdeglobals = lib.mkMerge [
          {
            General = {
              font = qtFont cfg.fonts.sansSerif.name cfg.fonts.sizes.applications;
              fixed = qtFont cfg.fonts.monospace.name cfg.fonts.sizes.terminal;
              smallestReadableFont = desktopFont;
              toolBarFont = desktopFont;
              menuFont = desktopFont;
              taskbarFont = desktopFont;
              inherit desktopFont;
            };

            WM.activeFont = desktopFont;

            "Colors:Window" = palette;
            "Colors:View" = palette;
            "Colors:Button" = palette;
            "Colors:Tooltip" = palette;
            "Colors:Complementary" = palette;
            "Colors:Selection" = selection;
          }

          (lib.mkIf (cfg.icons.name != null) {Icons.Theme = cfg.icons.name;})
        ];

        kcminputrc = lib.mkIf (cfg.cursor.name != null) {
          Mouse = {
            cursorTheme = immutable cfg.cursor.name;
            cursorSize = immutable cfg.cursor.size;
          };
        };
      };
    };
  };
}
