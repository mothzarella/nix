{
  config,
  inputs,
  withSystem,
  ...
}: {
  flake.homeConfigurations.tar = withSystem "x86_64-linux" (
    {pkgs, ...}:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit inputs;};
        modules = [
          config.flake.modules.homeManager."users/tar"
          {
            programs.home-manager.enable = true;
          }
        ];
      }
  );
}
