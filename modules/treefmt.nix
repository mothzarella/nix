{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";

    programs.alejandra.enable = true;
    programs.deadnix.enable = true;
    programs.statix.enable = true;
  };
}
