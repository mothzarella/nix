{
  flake.modules.nixos.theme = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.theme;
    inherit (config.lib.theme) colors;

    base =
      if cfg.polarity == "dark"
      then "adw-gtk3-dark"
      else "adw-gtk3";

    stylesheet = pkgs.writeText "theme-gtk.css" ''
      @define-color accent_color ${colors.base0D.hash};
      @define-color accent_bg_color ${colors.base0D.hash};
      @define-color accent_fg_color ${colors.base00.hash};
      @define-color destructive_color ${colors.base08.hash};
      @define-color destructive_bg_color ${colors.base08.hash};
      @define-color destructive_fg_color ${colors.base00.hash};
      @define-color success_color ${colors.base0B.hash};
      @define-color success_bg_color ${colors.base0B.hash};
      @define-color success_fg_color ${colors.base00.hash};
      @define-color warning_color ${colors.base0A.hash};
      @define-color warning_bg_color ${colors.base0A.hash};
      @define-color warning_fg_color ${colors.base00.hash};
      @define-color error_color ${colors.base08.hash};
      @define-color error_bg_color ${colors.base08.hash};
      @define-color error_fg_color ${colors.base00.hash};

      @define-color window_bg_color ${colors.base00.hash};
      @define-color window_fg_color ${colors.base05.hash};
      @define-color view_bg_color ${colors.base00.hash};
      @define-color view_fg_color ${colors.base05.hash};
      @define-color headerbar_bg_color ${colors.base01.hash};
      @define-color headerbar_fg_color ${colors.base05.hash};
      @define-color headerbar_border_color ${colors.base01.css 0.7};
      @define-color headerbar_backdrop_color @window_bg_color;
      @define-color headerbar_shade_color ${colors.base00.css 0.07};
      @define-color sidebar_bg_color ${colors.base01.hash};
      @define-color sidebar_fg_color ${colors.base05.hash};
      @define-color sidebar_backdrop_color @window_bg_color;
      @define-color sidebar_shade_color ${colors.base00.css 0.07};
      @define-color card_bg_color ${colors.base01.hash};
      @define-color card_fg_color ${colors.base05.hash};
      @define-color dialog_bg_color ${colors.base01.hash};
      @define-color dialog_fg_color ${colors.base05.hash};
      @define-color popover_bg_color ${colors.base01.hash};
      @define-color popover_fg_color ${colors.base05.hash};
      @define-color shade_color ${colors.base00.css 0.07};
      @define-color scrollbar_outline_color ${colors.base02.hash};

      @define-color theme_bg_color ${colors.base00.hash};
      @define-color theme_fg_color ${colors.base05.hash};
      @define-color theme_base_color ${colors.base00.hash};
      @define-color theme_text_color ${colors.base05.hash};
      @define-color theme_selected_bg_color ${colors.base0D.hash};
      @define-color theme_selected_fg_color ${colors.base00.hash};
      @define-color insensitive_bg_color ${colors.base01.hash};
      @define-color insensitive_fg_color ${colors.base03.hash};
      @define-color borders ${colors.base02.hash};
    '';

    package =
      pkgs.runCommandLocal "gtk-theme" {}
      ''
        install -d "$out/share/themes/theme"
        cp --recursive --no-preserve=mode \
          "${pkgs.adw-gtk3}/share/themes/${base}/." "$out/share/themes/theme"

        for version in 3.0 4.0; do
          install -d "$out/share/themes/theme/gtk-$version"
          cat "${stylesheet}" >>"$out/share/themes/theme/gtk-$version/gtk.css"
        done
      '';

    settings = lib.generators.toINI {} {
      Settings = lib.filterAttrs (_: value: value != null) {
        gtk-theme-name = "theme";
        gtk-font-name = "${cfg.fonts.sansSerif.name} ${toString cfg.fonts.sizes.applications}";
        gtk-application-prefer-dark-theme = cfg.polarity == "dark";
        gtk-icon-theme-name = cfg.icons.name;
        gtk-cursor-theme-name = cfg.cursor.name;
        gtk-cursor-theme-size =
          if cfg.cursor.name == null
          then null
          else cfg.cursor.size;
      };
    };
  in {
    config = lib.mkIf cfg.enable {
      environment = {
        systemPackages = [package];

        etc = {
          "xdg/gtk-3.0/settings.ini".text = settings;
          "xdg/gtk-4.0/settings.ini".text = settings;
        };
      };
    };
  };
}
