{
  lib,
  stdenvNoCC,
  replaceVars,
  makeBinaryWrapper,
  kdePackages,
  qt6,
  systemd,
  # Overridden by the `theme` NixOS module; the defaults keep the package
  # buildable on its own.
  theme ? {},
}: let
  bar = replaceVars ./bar.qml (
    {
      busctl = lib.getExe' systemd "busctl";
      foreground = "#000000";
      dim = "#8c8c8c";
      accent = "#3399ff";
      hover = "#99ccff";
      fontFamily = "Sans";
    }
    // theme
  );
in
  stdenvNoCC.mkDerivation {
    pname = "aero-bar";
    version = "0.1.0";

    dontUnpack = true;

    nativeBuildInputs = [makeBinaryWrapper kdePackages.wrapQtAppsHook];

    buildInputs = [
      qt6.qtdeclarative
      qt6.qtwayland
      qt6.qtsvg
      kdePackages.layer-shell-qt # org.kde.layershell
      kdePackages.plasma-workspace # org.kde.taskmanager
      kdePackages.plasma5support # org.kde.plasma.plasma5support
      kdePackages.kirigami # org.kde.kirigami
    ];

    dontWrapQtApps = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 ${lib.getExe' qt6.qtdeclarative "qml"} $out/libexec/aero-bar

      makeBinaryWrapper $out/libexec/aero-bar $out/bin/aero-bar \
        "''${qtWrapperArgs[@]}" \
        --add-flags ${bar}

      runHook postInstall
    '';

    meta = {
      mainProgram = "aero-bar";
      platforms = lib.platforms.linux;
    };
  }
