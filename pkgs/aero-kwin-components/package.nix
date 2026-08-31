{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  ninja,
  pkg-config,
  libepoxy,
  vulkan-headers,
  vulkan-loader,
  wayland-protocols,
  kdePackages,
}:
stdenv.mkDerivation {
  pname = "aero-kwin-components";
  version = "6.7.0-unstable-2026-08-08";

  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "aeroshell";
    repo = "aeroshell-kwin-components";
    rev = "ba5b59a4b5270a71a17768e0e7a22dc1be926833";
    hash = "sha256-w+C0bNbf23GIyDcAtjqfDsRXI1dTx2KqU7x+6/cG4rE=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs =
    [
      libepoxy
      vulkan-headers
      vulkan-loader
      wayland-protocols
    ]
    ++ (with kdePackages; [
      kcmutils
      kconfig
      kconfigwidgets
      kcoreaddons
      kcrash
      kdecoration
      kguiaddons
      ki18n
      kio
      knotifications
      kservice
      ksvg
      kwidgetsaddons
      kwin
      kwindowsystem
      qtbase
      qtdeclarative
      qttools
      qtwayland
    ]);

  cmakeFlags = ["-DKWIN_BUILD_WAYLAND=ON"];

  # KPluginMetaData derives the plugin id from the file name when the metadata
  # carries no Id, so `smodsnapEnabled` in kwinrc never matched this effect.
  postInstall = ''
    mv $out/lib/qt-6/plugins/kwin/effects/plugins/{libkwin_effect_,}smodsnap.so
  '';

  meta = {
    homepage = "https://gitgud.io/aeroshell/aeroshell-kwin-components";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
