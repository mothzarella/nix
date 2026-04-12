{
  self,
  inputs,
  ...
}: {
  flake.nixosModules."users/tar" = {pkgs, config, ...}: let
    username = "tar";
    ifGroupExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  in {
    imports = [inputs.home-manager.nixosModules.home-manager];

    users.users.${username} = {
      isNormalUser = true;
      initialPassword = "passwd";
      # shell = pkgs.fish;
      extraGroups = ifGroupExist [
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
      extraSpecialArgs = {inherit inputs self;};

      users.${username} = {
        imports = [self.homeModules."users/${username}"];

        home.persistence."/persistent" = {
          directories = [
            ".config/nix" # Nix flake config

            ".pki" # Certificates NSS (Network Security Services)

            {
              directory = ".ssh"; # SSH Keys
              mode = "0700";
            }
            {
              directory = ".local/share/keyrings"; # Gnome passwd keyring
              mode = "0700";
            }

            "Downloads"
          ];

          files = [".screenrc"];
        };
      };
    };
  };
}
