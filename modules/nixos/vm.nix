{
  flake.modules.nixos.vm = {
    virtualisation.vmVariant.virtualisation = {
      memorySize = 4096;
      cores = 4;
      qemu.options = ["-device virtio-vga-gl" "-display gtk,gl=on"];
    };

    # -------------------------------------------------------------------- users
    users.users.test = {
      isNormalUser = true;
      extraGroups = ["wheel" "video" "input"];
      password = "test";
    };

    # ----------------------------------------------------------------- hardware
    boot.loader.grub.devices = ["/dev/vda"];

    fileSystems."/" = {
      device = "/dev/vda";
      fsType = "ext4";
    };
  };
}
