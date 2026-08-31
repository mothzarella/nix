{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
}:
stdenvNoCC.mkDerivation {
  pname = "aero-cursors";
  version = "0-unstable-2026-06-20";

  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "aeroshell";
    repo = "atp/aerothemeplasma-icons";
    rev = "96950b8028a5d960cb683280fe5f1d9e33e6b8a2";
    hash = "sha256-7dfoGD3LQiBQ7/JeM1CwAZ+NNMaAJyAN/SaYIHZl1xg=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -r aero-drop $out/share/icons
    runHook postInstall
  '';

  dontFixup = true;

  meta = {
    homepage = "https://gitgud.io/aeroshell/atp/aerothemeplasma-icons";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
