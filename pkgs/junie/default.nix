{
  pkgs,
  lib,
  ...
}: let
  # See: https://raw.githubusercontent.com/jetbrains-junie/junie/main/update-info.jsonl
  version = "888.219";

  sources = {
    x86_64-linux = pkgs.fetchurl {
      url = "https://github.com/JetBrains/junie/releases/download/${version}/junie-release-${version}-linux-amd64.zip";
      sha256 = "48f208b55a6cfa75bf2b4999bb2fa1e31103aff76b4402768f8c227743229f25";
    };

    aarch64-linux = pkgs.fetchurl {
      url = "https://github.com/JetBrains/junie/releases/download/${version}/junie-release-${version}-linux-aarch64.zip";
      sha256 = "bb94db446df23d1df72ac153ad79271cced7c23bbfbab6c4539fde49c770d93a";
    };
  };

  src = sources.${pkgs.stdenv.hostPlatform.system} or (throw "Unsupported system: ${pkgs.stdenv.hostPlatform.system}");
in
  pkgs.stdenv.mkDerivation {
    pname = "junie";
    inherit version src;

    nativeBuildInputs = with pkgs; [
      unzip
      autoPatchelfHook
      makeWrapper
    ];

    autoPatchelfIgnoreMissingDeps = [
      "libjpeg.so.8"
    ];

    buildInputs = with pkgs; [
      zlib
      stdenv.cc.cc.lib
      libX11
      libXext
      libXrender
      libXtst
      libXi
      alsa-lib
      libjpeg_turbo
      libpng
      giflib
      lcms2
      harfbuzz
      freetype
      pcsclite
    ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/junie
      cp -r * $out/lib/junie/

      mkdir -p $out/bin
      makeWrapper $out/lib/junie/junie $out/bin/junie

      runHook postInstall
    '';

    meta = with lib; {
      description = "Junie CLI - JetBrains AI Coding Assistant";
      homepage = "https://junie.jetbrains.com";
      license = licenses.unfree; # Assuming unfree based on JetBrains
      platforms = ["x86_64-linux" "aarch64-linux"];
      mainProgram = "junie";
    };
  }
