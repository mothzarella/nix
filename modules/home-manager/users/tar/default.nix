{
  inputs,
  withSystem,
  ...
}: {
  flake.homeConfigurations."tar" = withSystem "x86_64-linux" ({pkgs, ...}:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {inherit inputs;};
      modules = [./home.nix];
    });
}
