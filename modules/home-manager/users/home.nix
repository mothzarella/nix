{self, ...}: {
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
      self.homeModules."features/development"
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

      # AI
      skills
      additions.junie # Overlay
    ];

    # Terminal
    features.terminal.foot.enable = true;

    # Development --------------------------------------------------------------

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

    features.development = {
      jetbrains = let
        plugins = [
          "nix-idea" # Nix
          "org.intellij.plugins.hcl" # Terraform
          "IdeaVIM" # Vim
        ];
      in {
        pycharm = {
          enable = true;
          inherit plugins;
        };
        goland = {
          enable = true;
          inherit plugins;
        };
      };
    };

    # Theme --------------------------------------------------------------------

    features.theme = {
      enable = true;
      wallpaper = "${self.outPath}/assets/wallpaper.png";
      scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";

      cursor = {
        enable = true;
        name = "miku-cursor-linux";
        source = "https://github.com/supermariofps/hatsune-miku-windows-linux-cursors/releases/download/1.2.6/miku-cursor-linux.tar.xz";
        hash = "sha256-qxWhzTDzjMxK7NWzpMV9EMuF5rg9gnO8AZlc1J8CRjY=";
      };

      targets = {
        gtk = {
          enable = true;
          flatpakSupport.enable = true;
        };
        qt.enable = true;
      };
    };

    home.stateVersion = "26.05";
  };
}
