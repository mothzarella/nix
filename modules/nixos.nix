{
  config,
  inputs,
  lib,
  hostSystems,
  withSystem,
  ...
}: let
  inherit (config.flake.modules) nixos;
in {
  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (final: _prev:
          lib.packagesFromDirectoryRecursive {
            inherit (final) callPackage;
            directory = ../pkgs;
          })
      ];
    };
  };

  flake = {
    nixosConfigurations =
      hostSystems
      |> lib.mapAttrs (
        name: system:
          withSystem system ({pkgs, ...}:
            inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {inherit inputs;};
              modules = [
                {
                  nixpkgs.pkgs = pkgs;
                  networking.hostName = name;
                }
                nixos.base
                nixos.${name}
              ];
            })
      );

    checks =
      config.flake.nixosConfigurations
      |> lib.mapAttrsToList (
        name: configuration: {
          ${hostSystems.${name}}."configurations:nixos:${name}" = configuration.config.system.build.toplevel;
        }
      )
      |> lib.mkMerge;
  };
}
