{lib, ...}: let
  hostSystems =
    ./hosts
    |> builtins.readDir
    |> lib.mapAttrs (
      host: _: let
        facter = ./hosts + "/${host}/facter.json";
      in
        if builtins.pathExists facter
        then (lib.importJSON facter).system
        else "x86_64-linux"
    );
in {
  imports =
    ./.
    |> lib.filesystem.listFilesRecursive
    |> builtins.filter (f: f != ./default.nix && lib.hasSuffix ".nix" (toString f));

  _module.args = {
    inherit hostSystems;
    secret = directory: {
      inherit directory;
      mode = "0700";
    };
  };

  systems =
    hostSystems
    |> lib.attrValues
    |> lib.unique;
}
