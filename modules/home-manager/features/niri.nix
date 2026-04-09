{...}: {
  flake.homeModules."features/niri" = {pkgs, ...}: {
    # programs.niri.enable = true; # TODO: add configuration via wrapper

    home.packages = with pkgs; [
      brightnessctl
      niri
      swaybg
      waybar
      fuzzel
      alacritty
    ];
  };
}
