{
  inputs,
  moduleWithSystem,
  ...
}: let
  IDEs = ["pycharm" "goland"];
in {
  flake.homeModules."features/development" = moduleWithSystem (
    perSystem @ {config, ...}: {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.features.development.jetbrains;
      anyEnabled = lib.any (n: cfg.${n}.enable) IDEs;

      addPlugins = n: let
        ide = perSystem.config.packages.${n};
        list = cfg.${n}.plugins;
        plugins = lib.attrValues (inputs.nix-jetbrains-plugins.lib.pluginsForIde pkgs ide list);
      in
        if list == []
        then ide
        else pkgs.jetbrains.plugins.addPlugins ide plugins;
    in {
      options.features.development.jetbrains = lib.genAttrs IDEs (n: {
        enable = lib.mkEnableOption "JetBrains ${n}";
        plugins = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          example = ["ideavim"];
        };
      });

      config = lib.mkIf anyEnabled {
        home.packages = lib.flatten (
          map (n: lib.optional cfg.${n}.enable (addPlugins n)) IDEs
        );

        home.persistence."/persistent".directories = [
          ".config/JetBrains"
          ".local/share/JetBrains"
          ".cache/JetBrains"
          {
            directory = ".java";
            mode = "0700";
          }
        ];
      };
    }
  );
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages = lib.genAttrs IDEs (n:
      pkgs.jetbrains.${n}.override {
        vmopts = "-Dawt.toolkit.name=WLToolkit";
      });
  };
}
