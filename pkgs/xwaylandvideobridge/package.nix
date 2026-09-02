{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  pkg-config,
  kdePackages,
  libxcb,
  libxcb-util,
}:
stdenv.mkDerivation {
  pname = "xwaylandvideobridge";
  version = "0.5.2";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "system";
    repo = "xwaylandvideobridge";
    rev = "v0.5.2";
    hash = "sha256-WFklGsUPdt14P6gDX71CpCsBoO5fxbC4TgWb8IBdNfc=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs =
    (with kdePackages; [
      kcoreaddons
      kcrash
      kdbusaddons
      ki18n
      kpipewire
      kstatusnotifieritem
      kwindowsystem
      qtbase
      qtdeclarative
    ])
    ++ [
      libxcb
      libxcb-util
    ];

  meta = {
    homepage = "https://invent.kde.org/system/xwaylandvideobridge";
    license = lib.licenses.gpl2Plus;
    mainProgram = "xwaylandvideobridge";
    platforms = lib.platforms.linux;
  };
}
