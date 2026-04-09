{lib, ...}: {
  options.flake.homeModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = {};
    description = "Home Manager modules exported by this flake";
  };

  # Use flake.nixosModules instead of nesting under flake.modules
  # This avoids conflicts with the flake-parts "modules" plugin
  # options.flake.nixosModules = lib.mkOption {
  #   type = lib.types.lazyAttrsOf lib.types.deferredModule;
  #   default = {};
  #   description = "NixOS modules exported by this flake";
  # };

  options.flake.meta = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.anything;
  };
}
