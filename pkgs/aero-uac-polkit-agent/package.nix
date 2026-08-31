{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  kdePackages,
}:
stdenv.mkDerivation {
  pname = "aero-uac-polkit-agent";
  version = "6.6.4-unstable-2026-04-07";

  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "aeroshell";
    repo = "uac-polkit-agent";
    rev = "e2f42e6ada98bbcd944b83f2575c0a62ea766b71";
    hash = "sha256-rrUkI6fbG4HywPPS1u4PBGyveT9ylWJPv/9n5G8FlzM=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = with kdePackages; [
    kconfig
    kcoreaddons
    kcrash
    kdbusaddons
    ki18n
    kirigami
    kirigami-addons
    knotifications
    ksvg
    kwindowsystem
    polkit-qt-1
    qtbase
    qtdeclarative
    qtmultimedia
  ];

  postInstall = ''
    rm -r $out/etc/systemd
  '';

  meta = {
    homepage = "https://gitgud.io/aeroshell/uac-polkit-agent";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
