{
  flake.modules.nixos."hosts/cinnamon" = {
    hardware.enableRedistributableFirmware = true;

    hardware.nvidia = {
      open = true;

      prime = {
        sync.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };

      powerManagement.enable = true;
    };

    # Intel thermal daemon
    services.thermald.enable = true;

    # Power profiles: balanced/power-saver/performance
    services.power-profiles-daemon.enable = true;

    # Periodic TRIM — complements btrfs discard=async for NVMe health
    services.fstrim.enable = true;

    features.storage = {
      disko = {
        enable = true;

        layout.main = {
          device = "/dev/disk/by-id/nvme-BC901_NVMe_SK_hynix_512GB__4YC6T000310706R22";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                name = "ESP";
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["fmask=0077" "dmask=0077"];
                };
              };
              root = {
                name = "root";
                size = "100%";
                content = {
                  type = "luks";
                  name = "cryptroot";
                  settings.allowDiscards = true;
                  content = {
                    type = "btrfs";
                    extraArgs = ["-f"];
                    subvolumes = {
                      "@root" = {
                        mountpoint = "/";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                      "@nix" = {
                        mountpoint = "/nix";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                      "@persistent" = {
                        mountpoint = "/persistent";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                      "@old_roots" = {};
                    };
                  };
                };
              };
            };
          };
        };

        luks = {
          enable = true;
          tpm2 = true;
        };
      };

      impermanence.enable = true;
    };
  };
}
