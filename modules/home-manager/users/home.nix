{
  self,
  ...
}: {
  # tar (Default) --------------------------------------------------------------

  flake.homeModules."users/tar" = {
    config,
    pkgs,
    ...
  }: let
    username = "tar";
  in {
    imports = [
      self.homeModules."features/niri"
      self.homeModules."features/terminal"
      self.homeModules."features/jetbrains"
    ];

    home = {
      inherit username;
      homeDirectory = "/home/${username}";
    };

    home.packages = with pkgs; [
      vivaldi

      neovim
      gh

      additions.junie # Overlay
    ];

    programs.git.enable = true;

    # programs.niri.enable = true; # Enabled via features/niri

    # Terminal
    features.terminal.foot.enable = true;

    home.stateVersion = "25.11";
  };
}
