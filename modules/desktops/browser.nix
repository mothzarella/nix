{
  flake.modules.nixos.browser = {
    config,
    lib,
    ...
  }: {
    programs.firefox = {
      enable = true;
      preferencesStatus = "user";
      preferences = {
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "browser.uidensity" = 1;
        "browser.tabs.inTitlebar" = 0;
      };
    };

    environment.sessionVariables.BROWSER = lib.getExe config.programs.firefox.finalPackage;
  };
}
