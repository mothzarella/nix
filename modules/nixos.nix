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
  perSystem = {
    system,
    pkgs,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputs.llm-agents.overlays.shared-nixpkgs
        (final: _prev:
          lib.packagesFromDirectoryRecursive {
            inherit (final) callPackage;
            directory = ../pkgs;
          })
      ];
    };

    packages = lib.packagesFromDirectoryRecursive {
      inherit (pkgs) callPackage;
      directory = ../pkgs;
    };
  };

  flake = {
    nixosConfigurations =
      hostSystems
      |> lib.mapAttrs (
        name: system:
          withSystem system ({pkgs, ...}:
            inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {inherit inputs nixos;};
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
