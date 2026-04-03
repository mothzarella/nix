{...}: {
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
}
