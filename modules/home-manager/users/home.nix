{
  self,
  inputs,
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
      self.homeModules."features/theme"
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

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "tar";
          email = "git@mothzarella.dev";
        };
        init.defaultBranch = "main";
      };
    };

    # Terminal
    features.terminal.foot.enable = true;

    # Theme
    features.theme = {
      enable = true;
      wallpaper = "${self.outPath}/assets/wallpaper.png";
      scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";
    };

    features.theme.cursor = {
      enable = true;
      name = "miku-cursor-linux";
      source = "https://github.com/supermariofps/hatsune-miku-windows-linux-cursors/releases/download/1.2.6/miku-cursor-linux.tar.xz";
      hash = "sha256-qxWhzTDzjMxK7NWzpMV9EMuF5rg9gnO8AZlc1J8CRjY=";
    };

    features.theme.targets = {
      gtk = {
        enable = true;
        flatpakSupport.enable = true;
      };
      qt.enable = true;
    };

    home.stateVersion = "26.05";
  };
}
