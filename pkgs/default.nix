{pkgs ? import <nixpkgs> {}, ...}: {
  junie = pkgs.callPackage ./junie/default.nix {};
}