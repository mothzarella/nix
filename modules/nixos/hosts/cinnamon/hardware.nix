{
  flake.nixosModules."hosts/cinnamon" = {pkgs, config, ...}: {
    # Kernel
    boot.kernelPackages = pkgs.stable.linuxPackages_zen; # Stable linux_zen

    # Loader
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Firmware
    hardware = {
      enableRedistributableFirmware = true;
      enableAllFirmware = true;
    };

    # CPU ----------------------------------------------------------------------

    powerManagement.cpuFreqGovernor = "schedutil";
    boot.kernelParams = ["intel_pstate=active"];

    services = {
      thermald.enable = true;
      irqbalance.enable = true;
    };

    # GPU ----------------------------------------------------------------------

    # OpenGL
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Nvidia
    hardware.nvidia = let
      cfg = config.hardware.nvidia.package;
    in {
      # Enable open source drivers if pkg supports it
      open = cfg ? open && cfg ? firmware;

      # Prime sync PCI
      prime = {
        sync.enable = true;
        # lspci | grep -E "VGA|3D"
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };

      powerManagement.enable = true;

      # Kernel driver package
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    # Storage ------------------------------------------------------------------

    features.storage = {
      impermanence.enable = true;

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

        # Encryption
        luks = {
          enable = true;
          tpm2 = true;
        };
      };
    };
  };
}
