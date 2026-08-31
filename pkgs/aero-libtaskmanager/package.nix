{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  ninja,
  pkg-config,
  kdePackages,
}:
stdenv.mkDerivation {
  pname = "aero-libtaskmanager";
  version = "6.7.0-unstable-2026-06-21";

  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "aeroshell";
    repo = "aeroshell-workspace";
    rev = "00a39ba08f3b9441b0883f1b82fc4e7e9e6a44b7";
    hash = "sha256-UGT+MaFwSgLzacdwZTLhaxW5qhaSVa6ZFE6F4XCaHbE=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  # the top-level CMakeLists resolves every find_package for all six components,
  # so the configure step needs their dependencies even though only one is built
  buildInputs = with kdePackages; [
    kcmutils
    kconfig
    kcoreaddons
    ki18n
    kio
    knotifications
    kservice
    kwindowsystem
    libksysguard
    libplasma
    plasma-activities
    plasma-activities-stats
    plasma-workspace
    qtbase
    qtdeclarative
  ];

  # aeroshell-workspace also ships kcmloader, fontconfig, mimetype, showdesktop and
  # utils; only the taskmanager QML plugin is wanted here
  ninjaFlags = ["taskmanagerplugin"];

  installPhase = ''
    runHook preInstall
    ninja libtaskmanager/install
    runHook postInstall
  '';

  # ships a QML plugin, no executables to wrap
  dontWrapQtApps = true;

  meta = {
    homepage = "https://gitgud.io/aeroshell/aeroshell-workspace";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
  };
}
