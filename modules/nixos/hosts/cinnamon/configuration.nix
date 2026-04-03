{pkgs, ...}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "cinnamon";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Rome";

  # Users ----------------------------------------------------------------------

  users.users.tar = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "video" "audio"];
  };

  # Niri -----------------------------------------------------------------------

  programs.niri.enable = true;
  programs.uwsm = {
    enable = true;
    waylandCompositors.niri = {
      prettyName = "Niri";
      comment = "Niri scrollable-tiling Wayland compositor";
      binPath = "/run/current-system/sw/bin/niri";
    };
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  services = {
    dbus.enable = true;
    gvfs.enable = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

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

  system.stateVersion = "25.11";
}
