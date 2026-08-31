# System-wide KConfig defaults. Several modules contribute to the same file --
# the theme writes colours and fonts, the desktop writes behaviour -- so the
# files are described as attribute sets and merged, rather than shipped as
# dotfiles that could only ever have one author.
{
  flake.modules.nixos.kconfig = {
    config,
    lib,
    ...
  }: let
    formatValue = value:
      if lib.isBool value
      then lib.boolToString value
      else toString value;

    # Nested attribute sets become nested `[Group][Subgroup]` headers. Values
    # wrapped with `immutable` are written as `key[$i]=value`, which stops
    # KDE's own settings dialogs from overwriting them.
    formatGroup = path: data: let
      split = data |> lib.attrsToList |> lib.partition ({value, ...}: lib.isAttrs value && !(value ? _immutable));

      header = path |> map (group: "[${group}]") |> lib.concatStrings;

      keys =
        split.wrong
        |> map (
          {
            name,
            value,
          }:
            if lib.isAttrs value
            then "${name}[$i]=${formatValue value.value}"
            else "${name}=${formatValue value}"
        );
    in
      lib.optional (keys != [] && path != []) header
      ++ keys
      ++ (
        split.right
        |> lib.concatMap ({
          name,
          value,
        }:
          formatGroup (path ++ [name]) value)
      );
  in {
    options.kconfig = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
      default = {};
      example = lib.literalExpression ''
        {kcminputrc.Mouse.cursorSize = 32;}
      '';
      description = ''
        KConfig files, keyed by name, written to `/etc/xdg/‹name›`.
      '';
    };

    config.lib.kconfig.immutable = value: {
      _immutable = true;
      inherit value;
    };

    config.environment.etc =
      config.kconfig
      |> lib.mapAttrs' (
        name: data:
          lib.nameValuePair "xdg/${name}" {
            text = lib.concatLines (formatGroup [] data);
          }
      );
  };
}
