{
  flake.modules.nixos.theme = {
    config,
    lib,
    ...
  }: let
    cfg = config.theme;
    inherit (config.lib.theme) ansi colors;

    range = prefix: list:
      list
      |> lib.imap0 (index: color: lib.nameValuePair "${prefix}${toString index}" color.hex)
      |> builtins.listToAttrs;
  in {
    config = lib.mkIf (cfg.enable && config.programs.foot.enable) {
      programs.foot.settings = {
        main = {
          font = "${cfg.fonts.monospace.name}:size=${toString cfg.fonts.sizes.terminal}";

          # foot carries a light and a dark palette side by side; we only fill
          # the one matching the polarity, so point it at that one.
          initial-color-theme = cfg.polarity;
        };

        "colors-${cfg.polarity}" =
          {
            alpha = cfg.opacity;
            background = colors.base00.hex;
            foreground = colors.base05.hex;
            selection-background = colors.base02.hex;
            selection-foreground = colors.base05.hex;
            urls = colors.base0D.hex;
          }
          // (ansi |> lib.take 8 |> range "regular")
          // (ansi |> lib.drop 8 |> range "bright");
      };
    };
  };
}
