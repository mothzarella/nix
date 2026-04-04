{
  config,
  inputs,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.cinnamon = withSystem "x86_64-linux" (
    {pkgs, ...}:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};

        modules = let
	  modules = config.flake.nixosModules;
	  hardware = inputs.nixos-hardware.nixosModules;
	in [
          inputs.nixpkgs.nixosModules.readOnlyPkgs

	  # Hardware
          hardware.common-cpu-intel
          hardware.common-gpu-nvidia-sync

	  # Modules
          modules.storage

          {
            imports = [
	      ./configuration.nix
	      ./hardware.nix
	    ];

            nixpkgs.pkgs = pkgs;
          }
        ];
      }
  );
}
