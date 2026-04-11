{
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.home-manager.flakeModules.home-manager
  ];

  options.flake.meta = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.anything;
  };
}
