{
  flake.modules.nixos.virtualisation = {pkgs, ...}: {
    users.users.tar.extraGroups = ["libvirtd" "docker" "incus-admin"];

    virtualisation = {
      libvirtd = {
        enable = true;
        onBoot = "ignore";
        onShutdown = "shutdown";
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = false;
          swtpm.enable = true;
        };
      };
      spiceUSBRedirection.enable = true;

      docker = {
        enable = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
          flags = ["--all"];
        };
        daemon.settings = {
          live-restore = true;
          log-driver = "journald";
        };
      };

      incus = {
        enable = true;
        ui.enable = true;
      };
    };

    programs.virt-manager.enable = true;
    programs.dconf.enable = true;

    networking = {
      nftables.enable = true;
      firewall.trustedInterfaces = ["incusbr0"];
    };

    environment.systemPackages = with pkgs; [
      virt-viewer
      spice-gtk
      docker-compose
      lazydocker
    ];

    # -------------------------------------------------------------- preservation
    preservation.preserveAt."/persistent".directories = [
      "/var/lib/libvirt"
      "/var/lib/docker"
      "/var/lib/incus"
    ];
  };
}
