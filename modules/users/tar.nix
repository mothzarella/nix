{config, ...}: let
  inherit (config.flake.modules) nixos;
in {
  flake.modules.nixos.tar = {pkgs, ...}: {
    imports = [nixos.preservation];

    users.users.tar = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video" "input"];
      hashedPasswordFile = "/persistent/passwords/tar";
      packages = [pkgs.brave-origin pkgs.claude-code];
    };

    preservation.preserveAt."/persistent".users.tar.directories = [
      {
        directory = ".gnupg";
        mode = "0700";
      }
      {
        directory = ".ssh";
        mode = "0700";
      }
      "Projects"
      {
        directory = ".claude";
        mode = "0700";
      }
      ".config/BraveSoftware"
      ".local/state"
      {
        directory = ".local/share/keyrings";
        mode = "0700";
      }
    ];

    preservation.preserveAt."/persistent".users.tar.files = [".claude.json"];
  };
}
