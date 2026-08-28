{config, ...}: let
  inherit (config.flake.modules) nixos;
in {
  flake.modules.nixos.aeroshell = {
    config,
    pkgs,
    lib,
    ...
  }: let
    inherit (pkgs.kdePackages) kwin;

    user = config.services.displayManager.autoLogin.user;

    smod = pkgs.aeroshell-kwin-smod;
    components = pkgs.aeroshell-kwin-components;

    # ------------------------------------------------------------------ scripts

    run = pkgs.writeShellScript "aeroshell-run" ''
      exec ${lib.getExe' pkgs.systemd "systemd-run"} --user --machine=${user}@.host \
        --collect --quiet --working-directory=${config.users.users.${user}.home} -- "$@"
    '';

    startup = pkgs.writeShellScript "aeroshell-startup" ''
      exec ${lib.getExe pkgs.wbg} /etc/aeroshell/wallpaper
    '';

    shell = pkgs.writeShellScriptBin "aeroshell" ''
      export QT_PLUGIN_PATH="${smod}/lib/qt-6/plugins:${components}/lib/qt-6/plugins''${QT_PLUGIN_PATH:+:$QT_PLUGIN_PATH}"
      export QML2_IMPORT_PATH="${pkgs.qt6.qt5compat}/lib/qt-6/qml''${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}"

      ${lib.getExe' pkgs.coreutils "install"} -Dm600 /etc/xdg/kglobalshortcutsrc "$HOME/.config/kglobalshortcutsrc"
      ${lib.getExe' pkgs.kdePackages.kservice "kbuildsycoca6"} --noincremental

      # natural scroll
      for dev in $(${lib.getExe' pkgs.systemd "udevadm"} trigger --dry-run --verbose \
        --subsystem-match=input --property-match=ID_INPUT_TOUCHPAD=1); do
        [ -e "$dev/name" ] || continue
        ${lib.getExe' pkgs.kdePackages.kconfig "kwriteconfig6"} --file "$HOME/.config/kcminputrc" \
          --group Libinput \
          --group "$((16#$(<"$dev/id/vendor")))" \
          --group "$((16#$(<"$dev/id/product")))" \
          --group "$(<"$dev/name")" \
          --key NaturalScroll true
      done

      exec ${kwin}/bin/kwin_wayland_wrapper --xwayland --no-lockscreen --no-kactivities -- ${startup}
    '';

    session = (pkgs.writeTextDir "share/wayland-sessions/aeroshell.desktop" ''
      [Desktop Entry]
      Name=AeroShell
      Comment=KWin-based AeroShell desktop
      Exec=${shell}/bin/aeroshell
      Type=Application
      DesktopNames=KDE
    '').overrideAttrs {passthru.providedSessions = ["aeroshell"];};
  in {
    imports = [nixos.terminal nixos.browser nixos.files];

    # -------------------------------------------------------------- environment
    environment = {
      systemPackages = [
        kwin
        smod
        components

        pkgs.kdePackages.breeze
        pkgs.kdePackages.breeze-icons
      ];

      pathsToLink = ["/share/smod" "/share/kwin" "/share/aeroshell"];

      sessionVariables = {
        XCURSOR_THEME = "breeze_cursors";
        XCURSOR_SIZE = "24";

        GDK_BACKEND = "x11";
        GTK_CSD = "0";
        MOZ_ENABLE_WAYLAND = "0";
      };

      etc."xdg/kwinrc".text = builtins.readFile ./dotfiles/kwinrc;
      etc."xdg/smodrc".source = ./dotfiles/smodrc;
      etc."xdg/kglobalshortcutsrc".text = builtins.readFile ./dotfiles/kglobalshortcutsrc;
    };

    # ----------------------------------------------------------------- programs

    programs.xwayland.enable = true;

    # ----------------------------------------------------------------- services

    services.keyd = {
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

    services.displayManager = {
      sessionPackages = [session];
      defaultSession = "aeroshell";
    };
  };
}
