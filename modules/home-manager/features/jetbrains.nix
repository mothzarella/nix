{moduleWithSystem, ...}: {
  flake.homeModules."features/jetbrains" = moduleWithSystem (
    perSystem @ {config, ...}: {
      home.packages = [
        config.packages.pycharm
      ];

      home.persistence."/persistent" = {
        directories = [
          ".config/JetBrains"
          ".local/share/JetBrains"
          ".cache/JetBrains"
        ];
      };
    }
  );

  perSystem = {pkgs, ...}: {
    # Pycharm
    packages.pycharm = pkgs.jetbrains.pycharm.override {
      vmopts = ''
        -Dawt.toolkit.name=WLToolkit
      '';
    };
  };
}
