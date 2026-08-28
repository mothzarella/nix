{
  flake.modules.nixos.terminal = {
    pkgs,
    lib,
    ...
  }: {
    programs.foot.enable = true;
    environment.sessionVariables.TERMINAL = lib.getExe pkgs.foot;
  };
}
