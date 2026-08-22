{inputs, ...}: {
  flake.modules.nixos.preservation = {
    imports = [inputs.preservation.nixosModules.preservation];

    fileSystems."/persistent".neededForBoot = true;
    fileSystems."/nix".neededForBoot = true;

    preservation = {
      enable = true;

      preserveAt."/persistent".directories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/nvpcr" # TPM2
        "/var/lib/systemd/timers"
        "/var/log"
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
      ];

      preserveAt."/persistent".files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
        "/var/lib/systemd/credential.secret"

        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key.pub";
          how = "symlink";
          configureParent = true;
        }
      ];
    };

    systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];
  };
}
