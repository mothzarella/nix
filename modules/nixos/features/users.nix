{
  config,
  inputs,
  ...
}: {
  flake.modules.nixos."users/tar" = {pkgs, ...}: let
    name = "tar";
  in {
    imports = [inputs.home-manager.nixosModules.home-manager];

    users.users.${name} = {
      isNormalUser = true;
      initialPassword = "passwd";
      # shell = pkgs.fish;
      extraGroups = [
        "wheel"

        # extra groups
        "audio"
        "docker"
        "libvirtd"
        "network"
        "video"
        "wireshark"
      ];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";

      users.${name} = {
        imports = [config.flake.homeModules."users/${name}"];

        home.persistence."/persistent" = {
          directories = [
            "Downloads"
            {
              directory = ".ssh";
              mode = "0700";
            }
            {
              directory = ".local/share/keyrings";
              mode = "0700";
            }
            ".config/nix"
          ];
          files = [
            ".screenrc"
          ];
        };
      };
    };
  };
}
