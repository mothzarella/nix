{
  flake.modules.nixos.networking = {
    networking.networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    services.resolved.enable = true;
  };
}
