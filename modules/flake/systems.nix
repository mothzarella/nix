{
  inputs,
  self,
  ...
}: {
  systems = import inputs.systems;

  perSystem = {system, pkgs, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [self.overlays.default];
      config.allowUnfree = true;
    };
  };
}
