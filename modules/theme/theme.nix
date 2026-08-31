{config, ...}: let
  inherit (config.flake.modules) nixos;
in {
  flake.modules.nixos.theme = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.theme;
    inherit (lib) mkOption types;

    digits =
      "0123456789abcdef"
      |> lib.stringToCharacters
      |> lib.imap0 (index: digit: lib.nameValuePair digit index)
      |> builtins.listToAttrs;

    mkColor = value: let
      hex = value |> lib.removePrefix "#" |> lib.toLower;
      channels =
        [0 2 4]
        |> map (
          offset:
            builtins.substring offset 2 hex
            |> lib.stringToCharacters
            |> lib.foldl (accumulator: digit: accumulator * 16 + digits.${digit}) 0
        );
      join = separator: lib.concatMapStringsSep separator toString channels;
    in {
      inherit hex;
      hash = "#${hex}"; # CSS, GTK, QML
      rgb = join ","; # KConfig colour triples
      css = alpha: "rgba(${join ", "}, ${toString alpha})";
    };

    colors = lib.mapAttrs (_: mkColor) cfg.colors;

    font = family: package: {
      name = mkOption {
        type = types.str;
        default = family;
      };
      package = mkOption {
        type = types.package;
        default = package;
      };
    };

    size = default:
      mkOption {
        type = types.numbers.positive;
        inherit default;
      };

    nullable = type:
      mkOption {
        type = types.nullOr type;
        default = null;
      };
  in {
    imports = [nixos.kconfig];

    options.theme = {
      enable = lib.mkEnableOption "theming";

      polarity = mkOption {
        type = types.enum ["light" "dark"];
        default = "dark";
        description = "Whether the palette is light or dark.";
      };

      colors =
        lib.genAttrs
        (lib.range 0 15 |> map (index: "base0${lib.toHexString index}"))
        (
          name:
            mkOption {
              type = types.strMatching "#[[:xdigit:]]{6}";
              description = "The base16 colour `${name}`.";
            }
        );

      fonts = {
        sansSerif = font "DejaVu Sans" pkgs.dejavu_fonts;
        monospace = font "DejaVu Sans Mono" pkgs.dejavu_fonts;
        emoji = font "Noto Color Emoji" pkgs.noto-fonts-color-emoji;

        sizes = {
          desktop = size 10;
          applications = size 12;
          terminal = size cfg.fonts.sizes.applications;
        };
      };

      cursor = {
        name = nullable types.str;
        package = nullable types.package;
        size = mkOption {
          type = types.ints.positive;
          default = 24;
        };
      };

      icons = {
        name = nullable types.str;
        package = nullable types.package;
      };

      opacity = mkOption {
        type = types.numbers.between 0.0 1.0;
        default = 1.0;
        description = "Window opacity, where supported.";
      };

      packages = mkOption {
        type = types.attrsOf types.package;
        default = {};
        description = "Packages a target rebuilt with the current theme.";
      };
    };

    config = lib.mkMerge [
      {
        lib.theme = {
          inherit colors;
          ansi = with colors; [
            base00
            base08
            base0B
            base0A
            base0D
            base0E
            base0C
            base05
            base03
            base08
            base0B
            base0A
            base0D
            base0E
            base0C
            base07
          ];
        };
      }

      (lib.mkIf cfg.enable {
        fonts.packages = with cfg.fonts; lib.unique [sansSerif.package monospace.package emoji.package];

        environment = {
          systemPackages = [cfg.cursor.package cfg.icons.package] |> lib.filter (package: package != null);

          sessionVariables = lib.mkIf (cfg.cursor.name != null) {
            XCURSOR_THEME = cfg.cursor.name;
            XCURSOR_SIZE = toString cfg.cursor.size;
          };
        };
      })
    ];
  };
}
