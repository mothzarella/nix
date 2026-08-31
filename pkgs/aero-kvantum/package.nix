{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
}:
stdenvNoCC.mkDerivation {
  pname = "aero-kvantum";
  version = "0-unstable-2026-08-22";

  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "aeroshell";
    repo = "atp/aerothemeplasma";
    rev = "afaaa49dad2a9fc894e44e05caf2d5be75f85061";
    hash = "sha256-l4QaCvka8LzKnx8y4/BFbNZnPKd2LVzaTIIKe1qZpFY=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/Kvantum
    cp -r misc/kvantum/Windows7Aero $out/share/Kvantum
    runHook postInstall
  '';

  dontFixup = true;

  meta = {
    homepage = "https://gitgud.io/aeroshell/atp/aerothemeplasma";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
