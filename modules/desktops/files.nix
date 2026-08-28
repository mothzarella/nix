{
  flake.modules.nixos.files = {
    programs.thunar.enable = true;
    programs.xfconf.enable = true;

    services.gvfs.enable = true;
    services.tumbler.enable = true;
  };
}
