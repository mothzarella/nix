{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  kdePackages,
}:
stdenv.mkDerivation {
  pname = "smod";
  version = "6.7.0-unstable-2026-08-07";

  src = fetchFromGitHub {
    owner = "aeroshell-desktop";
    repo = "smod";
    rev = "d15bbd187cae7898fd348c15342d8d6b57100a19";
    hash = "sha256-0bY7iMnKrZWUYdYSUCrVuVyJHt5aXeieUfohq2k1rZY=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = with kdePackages; [
    frameworkintegration
    kcmutils
    kcolorscheme
    kconfig
    kcoreaddons
    kdecoration
    kguiaddons
    ki18n
    kiconthemes
    kirigami
    kwin
    kwindowsystem
    qtbase
    qtdeclarative
  ];

  postInstall = ''
    export PKG_CONFIG_PATH=$out/lib/pkgconfig''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}
    cmake -S ../smodglow -B ../build-smodglow -DKWIN_BUILD_WAYLAND=ON \
      -DCMAKE_INSTALL_PREFIX=$out -DKDE_INSTALL_PLUGINDIR=$out/lib/qt-6/plugins
    cmake --build ../build-smodglow
    cmake --install ../build-smodglow
  '';

  meta = {
    description = "A KDecoration3 decoration engine made for AeroShell-based desktops.";
    homepage = "https://github.com/aeroshell-desktop/smod";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
  };
}
