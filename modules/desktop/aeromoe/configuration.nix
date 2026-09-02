{
  flake.modules.nixos.aeromoe = {
    config,
    pkgs,
    lib,
    ...
  }: let
    systemctl = lib.getExe' pkgs.systemd "systemctl";

    startup = pkgs.writeShellScript "aeromoe-session" ''
      export QT_STYLE_OVERRIDE=kvantum
      ${systemctl} --user import-environment DESKTOP_SESSION XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE XDG_RUNTIME_DIR WAYLAND_DISPLAY DISPLAY
      ${systemctl} --user start aeromoe-session.target
      ${systemctl} --user try-restart xdg-desktop-portal.service plasma-xdg-desktop-portal-kde.service
      USE_UAC_AGENT=1 ${pkgs.aero-uac-polkit-agent}/libexec/uac-polkit-agent &
      ${lib.getExe (config.theme.packages.aero-bar or pkgs.aero-bar)} &
      exec ${lib.getExe pkgs.wbg} ${config.theme.wallpaper}
    '';

    shell = pkgs.writeShellScriptBin "aeromoe" ''
      export XDG_DATA_DIRS="${pkgs.aero-kwin-smod}/share:${pkgs.aero-kwin-components}/share''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
      export QML2_IMPORT_PATH="${pkgs.qt6.qt5compat}/lib/qt-6/qml''${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}"
      export KWIN_WAYLAND_NO_PERMISSION_CHECKS=1

      ${lib.getExe' pkgs.coreutils "install"} -Dm600 /etc/xdg/kglobalshortcutsrc "$HOME/.config/kglobalshortcutsrc"
      ${lib.getExe' pkgs.kdePackages.kservice "kbuildsycoca6"} --noincremental
      ${lib.getExe' pkgs.coreutils "env"} -u QT_STYLE_OVERRIDE ${pkgs.kdePackages.kwin}/bin/kwin_wayland_wrapper --xwayland --no-lockscreen --no-kactivities -- ${startup}
      ${systemctl} --user stop aeromoe-session.target
    '';

    session =
      (pkgs.writeTextDir "share/wayland-sessions/aeromoe.desktop" ''
        [Desktop Entry]
        Name=AeroMoe
        Comment=KWin-based AeroMoe desktop
        Exec=${lib.getExe shell}
        Type=Application
        DesktopNames=KDE
      '')
      .overrideAttrs {passthru.providedSessions = ["aeromoe"];};

    inherit (config.services.displayManager.autoLogin) user;
    run = command: "${lib.getExe' pkgs.systemd "systemd-run"} --user --machine=${user}@.host --collect --quiet --working-directory=${config.users.users.${user}.home} -- ${command}";
  in {
    imports = [./..];

    programs.xwayland.enable = true;
    security.polkit.enable = true;

    # ------------------------------------------------------------------ session
    systemd.user = {
      targets.aeromoe-session = {
        description = "AeroMoe session";
        bindsTo = ["graphical-session.target"];
        before = ["graphical-session.target"];
        wants = ["graphical-session-pre.target"];
        after = ["graphical-session-pre.target"];
      };

      services = {
        xwaylandvideobridge = {
          description = "Screencast bridge for XWayland clients";
          partOf = ["aeromoe-session.target"];
          wantedBy = ["aeromoe-session.target"];
          serviceConfig = {
            ExecStart = lib.getExe pkgs.xwaylandvideobridge;
            Slice = "session.slice";
            Restart = "on-failure";
          };
        };

        plasma-xdg-desktop-portal-kde = {
          overrideStrategy = "asDropin";
          serviceConfig.UnsetEnvironment = "QT_STYLE_OVERRIDE";
        };
      };
    };

    # ------------------------------------------------------------------- portal
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.kdePackages.xdg-desktop-portal-kde];
      config.common.default = ["kde"];
    };

    # -------------------------------------------------------------------- theme
    theme = {
      enable = true;
      polarity = "dark";
      colors = {
        base00 = "#1f1f23";
        base01 = "#2a2a30";
        base02 = "#3c3c44";
        base03 = "#8c8c8c";
        base04 = "#b0b0b8";
        base05 = "#f0f0f0";
        base06 = "#fafafa";
        base07 = "#ffffff";
        base08 = "#e74856";
        base09 = "#f7630c";
        base0A = "#ffb900";
        base0B = "#16c60c";
        base0C = "#61b8e0";
        base0D = "#3399ff";
        base0E = "#c76fd6";
        base0F = "#b07242";
      };

      fonts.sizes = {
        desktop = 9;
        applications = 9;
      };

      cursor = {
        package = pkgs.aero-cursors;
        name = "aero-drop";
        size = 32;
      };

      icons = {
        package = pkgs.papirus-icon-theme.override {color = "white";};
        name = "Papirus-Dark";
      };
    };

    # --------------------------------------------------------------------- boot
    boot = {
      plymouth.enable = true;
      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelParams = ["quiet" "udev.log_level=3"];
    };

    # -------------------------------------------------------------- environment
    environment = {
      systemPackages = with pkgs; [
        kdePackages.kwin
        kdePackages.kde-cli-tools
        aero-kwin-smod
        aero-kwin-components
        aero-uac-polkit-agent

        aero-kvantum
        qt6Packages.qtstyleplugin-kvantum
      ];

      pathsToLink = ["/share/smod" "/share/kwin" "/share/aeroshell" "/share/Kvantum"];

      sessionVariables = {
        KDE_SESSION_VERSION = "6";
        QT_STYLE_OVERRIDE = "kvantum";
        QT_PLUGIN_PATH = [
          "${pkgs.aero-kwin-smod}/lib/qt-6/plugins"
          "${pkgs.aero-kwin-components}/lib/qt-6/plugins"
          "${pkgs.qt6Packages.qtstyleplugin-kvantum}/lib/qt-6/plugins"
        ];

        GTK_CSD = "0";
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };

      etc."xdg/Kvantum/kvantum.kvconfig".text = lib.generators.toINI {} {General.theme = "Windows7Aero";};
      etc."xdg/kwinrc".source = ./dotfiles/kwinrc;
      etc."xdg/kwinrulesrc".source = ./dotfiles/kwinrulesrc;
      etc."xdg/kglobalshortcutsrc".text = lib.generators.toINI {} {
        kwin =
          {
            "Show Desktop" = "none,none,Show Desktop";
            "Switch One Desktop to the Left" = "Meta+H,none,Switch One Desktop to the Left";
            "Switch One Desktop Down" = "Meta+J,none,Switch One Desktop Down";
            "Switch One Desktop Up" = "Meta+K,none,Switch One Desktop Up";
            "Switch One Desktop to the Right" = "Meta+L,none,Switch One Desktop to the Right";
          }
          // (lib.range 1 9
            |> map (n: {
              name = "Switch to Desktop ${toString n}";
              value = "Meta+${toString n},none,Switch to Desktop ${toString n}";
            })
            |> lib.listToAttrs);
      };
      etc."xdg/smodrc".text = lib.generators.toINI {} {
        Windeco = {
          DecorationTheme = "Aero";
          EnableShadow = true;
          HideIcon = true;
        };
      };
    };

    # ----------------------------------------------------------------- services
    services = {
      displayManager = {
        sessionPackages = [session];
        defaultSession = "aeromoe";
        sddm = {
          enable = true;
          wayland.enable = true;
        };
      };

      keyd = {
        enable = true;
        keyboards.default = {
          ids = ["*"];
          extraConfig = ''
            [main]
            meta = layer(meta)

            [meta:M]
            enter = command(${run config.environment.sessionVariables.TERMINAL})
            w = command(${run config.environment.sessionVariables.BROWSER})

            [meta+shift]
            r = command(${systemctl} reboot)
          '';
        };
      };
    };
  };
}
