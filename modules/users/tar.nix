{config, ...}: let
  inherit (config.flake.modules) nixos;
in {
  flake.modules.nixos.tar = {
    imports = [nixos.preservation];

    users.users.tar = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video" "input"];
      hashedPasswordFile = "/persistent/passwords/tar";
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
    ];
  };
}
