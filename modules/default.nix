{
  imports = let
    tree = dir:
      builtins.concatMap
      (
        name: let
          path = dir + "/${name}";
          type = (builtins.readDir dir).${name};
        in
          if type == "directory"
          then
            if builtins.pathExists (path + "/default.nix")
            then [(path + "/default.nix")]
            else tree path
          else if
            type
            == "regular"
            && builtins.match ".+\\.nix" name != null
            && name != "default.nix" # Ignore default (module entry)
          then [path]
          else []
      )
      (builtins.attrNames (builtins.readDir dir));
  in
    tree ./.;
}
