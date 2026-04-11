{lib, ...}: {
  flake.homeModules."features/terminal" = {
    config,
    pkgs,
    ...
  }:
    with lib; let
      cfg = config.features.terminal.foot;
    in {
      options.features.terminal.foot = {
        enable = mkEnableOption "Enable `foot` terminal emulator";
      };

      config = mkIf cfg.enable {
        programs.foot.enable = true;
      };
    };
}
