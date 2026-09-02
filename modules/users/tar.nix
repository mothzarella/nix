{secret, ...}: {
  flake.modules.nixos.tar = {pkgs, ...}: {
    # -------------------------------------------------------------------- users
    users.users.tar = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video" "input"];
      hashedPasswordFile = "/persistent/passwords/tar";
      packages = with pkgs; [
        fastfetch
        claude-code
        neovim
        llm-agents.junie
        vesktop
        tmux
        zed-editor
      ];
    };

    services.displayManager.autoLogin = {
      enable = true;
      user = "tar";
    };

    # ------------------------------------------------------------- preservation
    preservation.preserveAt."/persistent".users.tar = {
      directories = [
        (secret ".gnupg")
        (secret ".ssh")
        (secret ".claude")
        (secret ".junie")
        (secret ".local/share/keyrings")

        "Projects"
        "Desktop"
        "Documents"
        "Music"
        "Pictures"
        "Public"
        "Templates"
        "Videos"

        ".local/state"

        ".config/mozilla"
        ".local/share/mozilla"
        ".config/vesktop"
        ".config/zed"
        ".local/share/zed"
      ];
      files = [".claude.json"];
    };
  };
}
