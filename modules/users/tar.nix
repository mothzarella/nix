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
      packages = with pkgs; [
        fastfetch
        claude-code
        neovim
        vesktop
        tmux
        jetbrains.pycharm
        zed-editor
      ];
    };

    # ------------------------------------------------------------- preservation
    preservation.preserveAt."/persistent".users.tar = {
      directories = [
        (secret ".gnupg")
        (secret ".ssh")
        (secret ".claude")
        (secret ".local/share/keyrings")
        "Projects"
        "Desktop"
        ".config/mozilla"
        ".local/share/mozilla"
        ".local/state"
      ];
      files = [".claude.json"];
    };
  };
}
