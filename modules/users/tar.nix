{
  config,
  secret,
  ...
}: let
  inherit (config.flake.modules) nixos;
in {
  flake.modules.nixos.tar = {pkgs, ...}: {
    imports = [nixos.preservation];

    # -------------------------------------------------------------------- users
    users.users.tar = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video" "input"];
      hashedPasswordFile = "/persistent/passwords/tar";
      packages = [
        pkgs.claude-code
        pkgs.neovim
        pkgs.vesktop

        (pkgs.jetbrains.pycharm.overrideAttrs (old: {
          postInstall =
            (old.postInstall or "")
            + ''
              substituteInPlace $out/pycharm/bin/pycharm64.vmoptions \
                --replace-fail '-Dawt.toolkit.name=auto' '-Dawt.toolkit.name=XToolkit'
            '';
        }))
      ];
    };

    # ------------------------------------------------------------- preservation
    preservation.preserveAt."/persistent".users.tar = {
      directories = [
        (secret ".gnupg")
        (secret ".ssh")
        "Projects"
        (secret ".claude")
        ".mozilla"
        ".config/JetBrains"
        ".local/state"
        (secret ".local/share/keyrings")
      ];
      files = [".claude.json"];
    };
  };
}
