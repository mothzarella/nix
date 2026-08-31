{
  flake.modules.nixos.aeromoe = {
    config,
    pkgs,
    lib,
    ...
  }: let
    run = pkgs.writeShellScript "aeromoe-run" ''
      exec ${lib.getExe' pkgs.systemd "systemd-run"} \
        --user \
        --machine=${config.services.displayManager.autoLogin.user}@.host \
        --collect --quiet --working-directory=${config.users.users.${config.services.displayManager.autoLogin.user}.home} -- "$@"
    '';

    startup = pkgs.writeShellScript "aeromoe-startup" ''
      export QT_STYLE_OVERRIDE=kvantum # dropped for kwin itself, wanted by its children

      USE_UAC_AGENT=1 ${pkgs.aero-uac-polkit-agent}/libexec/uac-polkit-agent &

      ${lib.getExe (config.theme.packages.aero-bar or pkgs.aero-bar)} &

      exec ${lib.getExe pkgs.wbg} /etc/aeromoe/wallpaper
    '';

    shell = pkgs.writeShellScriptBin "aeromoe" ''
      export XDG_DATA_DIRS="${pkgs.aero-kwin-smod}/share:${pkgs.aero-kwin-components}/share''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
      export QML2_IMPORT_PATH="${pkgs.qt6.qt5compat}/lib/qt-6/qml''${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}"
      export KWIN_WAYLAND_NO_PERMISSION_CHECKS=1

      ${lib.getExe' pkgs.coreutils "install"} -Dm600 /etc/xdg/kglobalshortcutsrc "$HOME/.config/kglobalshortcutsrc"
      ${lib.getExe' pkgs.kdePackages.kservice "kbuildsycoca6"} --noincremental

      # QT_QUICK_CONTROLS_STYLE -- its QML then dies on `import kvantum`.
      exec ${lib.getExe' pkgs.coreutils "env"} -u QT_STYLE_OVERRIDE ${pkgs.kdePackages.kwin}/bin/kwin_wayland_wrapper --xwayland --no-lockscreen --no-kactivities -- ${startup}
    '';

    session = (pkgs.writeTextDir "share/wayland-sessions/aeromoe.desktop" ''
      [Desktop Entry]
      Name=AeroMoe
      Comment=KWin-based AeroMoe desktop
      Exec=${shell}/bin/aeromoe
      Type=Application
      DesktopNames=KDE
    '').overrideAttrs {passthru.providedSessions = ["aeromoe"];};
  in {
    imports = [./..];

    programs.xwayland.enable = true;
    security.polkit.enable = true;

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
        package = lib.mkDefault (pkgs.papirus-icon-theme.override {color = "white";});
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
        aero-kwin-smod
        aero-kwin-components
        aero-uac-polkit-agent

        aero-kvantum
        qt6Packages.qtstyleplugin-kvantum
      ];

      pathsToLink = ["/share/smod" "/share/kwin" "/share/aeroshell" "/share/Kvantum"];

      sessionVariables = {
        QT_STYLE_OVERRIDE = "kvantum";
        QT_PLUGIN_PATH = [
          "${pkgs.aero-kwin-smod}/lib/qt-6/plugins"
          "${pkgs.aero-kwin-components}/lib/qt-6/plugins"
          "${pkgs.qt6Packages.qtstyleplugin-kvantum}/lib/qt-6/plugins"
        ];

        # server-side decoration
        GDK_BACKEND = "x11";
        GTK_CSD = "0";
        MOZ_ENABLE_WAYLAND = "0";
      };

      etc."xdg/Kvantum/kvantum.kvconfig".text = lib.generators.toINI {} {General.theme = "Windows7Aero";};
      etc."xdg/kwinrulesrc".source = ./dotfiles/kwin/kwinrulesrc;
      etc."xdg/kglobalshortcutsrc".source = ./dotfiles/kwin/kglobalshortcutsrc;
      etc."aeromoe/wallpaper".source = ../../hosts + "/${config.networking.hostName}/wallpaper.webp";
    };

    # -------------------------------------------------------------------- smod
    # https://gitgud.io/aeroshell/smod
    kconfig.smodrc.Windeco = {
      DecorationTheme = "Aero";
      EnableShadow = true;
      HideIcon = true;
    };

    # --------------------------------------------------------------------- kwin
    # https://invent.kde.org/plasma/kwin/-/tree/master/src/plugins
    kconfig.kwinrc = {
      "org.kde.kdecoration2".library = "org.smod.smod";

      Windows.RollOverDesktops = true;

      Desktops = {
        Number = 9;
        Rows = 3;
      };

      Outline.QmlPath = "aeroshell/outline/plasma/outline.qml";

      TabBox = {
        ShowDesktopMode = 1;
        LayoutName = "thumbnail_aero";
      };

      TabBoxAlternative = {
        ShowDesktopMode = 1;
        LayoutName = "flip3d";
      };

      Plugins = {
        aeroglassblurEnabled = true;
        aeroglideEnabled = true;
        "aeroshell-thumbnailsEnabled" = true;
        dimscreenaeroEnabled = true;
        fadingpopupsaeroEnabled = true;
        launchfeedbackEnabled = true;
        smodglowEnabled = true;
        smodsnapEnabled = true;
        squashaeroEnabled = true;

        smodpeekeffectEnabled = false;
        smodpeekscriptEnabled = false;

        blurEnabled = false;
        contrastEnabled = false;
        kscreenEnabled = false;
        kwin4_effect_fadeEnabled = false;
        kwin4_effect_scaleEnabled = false;
        kwin4_effect_squashEnabled = false;
        magiclampEnabled = false;
        outputlocatorEnabled = false;
        overviewEnabled = false;
        slidingpopupsEnabled = false;
        tileseditorEnabled = false;
        windowviewEnabled = false;
      };

      "Effect-aeroglassblur" = {
        AeroHue = 202;
        AeroSaturation = 39;
        AeroBrightness = 35;
        AeroIntensity = 140;

        BlurDocks = true;
        BlurMatching = true;
        BlurMenus = true;
        BlurStrength = 4;
        EnableCornerGlow = true;
        EnableTransparency = true;
        ReflectionIntensity = 75;

        WindowClasses = "aero-bar";
      };

      "Effect-aeroglide" = {
        AccurateTilt = true;
        Duration = 220;
        InDistance = 28;
        InRotationAngle = 10;
        OutDistance = 28;
        OutRotationAngle = 10;
      };
    };

    # ----------------------------------------------------------------- services
    services = {
      displayManager = {
        sessionPackages = [session];
        defaultSession = "aeromoe";
      };

      keyd = {
        enable = true;
        keyboards.default = {
          ids = ["*"];
          extraConfig = ''
            [main]
            meta = layer(meta)

            [meta:M]
            enter = command(${run} ${config.environment.sessionVariables.TERMINAL})
            w = command(${run} ${config.environment.sessionVariables.BROWSER})

            [meta+shift]
            r = command(${lib.getExe' pkgs.systemd "systemctl"} reboot)
          '';
        };
      };
    };
  };
}
