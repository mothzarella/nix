{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  pkg-config,
  kdePackages,
}:
stdenv.mkDerivation {
  pname = "aero-kwin-smod";
  version = "6.7.4-unstable-2026-08-22";

  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "aeroshell";
    repo = "smod";
    rev = "b93cffd1d06a34cb89223270fc6256d1ba557e22";
    hash = "sha256-LB5uKwxmQHctZJHixhlcpg9Mp+SztnYPnuRX0l+9xoM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = with kdePackages; [
    kcmutils
    kcolorscheme
    kconfig
    kconfigwidgets
    kcoreaddons
    kdecoration
    kguiaddons
    ki18n
    kiconthemes
    kwin
    kwindowsystem
    qtbase
    qtdeclarative
  ];

  meta = {
    homepage = "https://gitgud.io/aeroshell/smod";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
  };
}
