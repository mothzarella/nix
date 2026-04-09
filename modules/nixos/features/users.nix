{
  config,
  self,
  inputs,
  ...
}: {
  flake.nixosModules."users/tar" = {pkgs, ...}: let
    username = "tar";
  in {
    imports = [inputs.home-manager.nixosModules.home-manager];

    users.users.${username} = {
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

      users.${username} = {
        imports = [
          self.homeModules."users/${username}"
        ];

        home.persistence."/persistent" = {
          directories = [
            "Downloads"
            ".config/vivaldi"
            ".pki"
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
