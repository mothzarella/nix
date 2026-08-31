{
  flake.modules.nixos.networking = {
    networking.networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    services.resolved.enable = true;

    # --------------------------------------------------------------------- wifi
    networking.wireless.iwd = {
      enable = true;
      settings = {
        Settings.AutoConnect = true;
      };
    };

    # ---------------------------------------------------------------------- bbr
    boot = {
      kernelModules = ["tcp_bbr"];
      kernel.sysctl = {
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "cake";
      };
    };
  };
}
