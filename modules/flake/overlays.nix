{inputs, ...}: {
  flake.overlays.default = final: prev: {
    additions = import ../../pkgs {pkgs = final;};

    stable = import inputs.nixpkgs-stable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
}
