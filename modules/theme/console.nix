{
  flake.modules.nixos.theme = {
    config,
    lib,
    ...
  }: {
    config = lib.mkIf config.theme.enable {
      console.colors = config.lib.theme.ansi |> map (color: color.hex);
    };
  };
}
