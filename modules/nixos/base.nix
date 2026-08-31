{inputs, ...}: {
  flake.modules.nixos.base = {
    lib,
    pkgs,
    ...
  }: {
    # ----------------------------------------------------------------- packages
    environment.systemPackages = with pkgs; [git nil];

    programs.command-not-found.enable = false;

    # ---------------------------------------------------------------------- nix
    nix = {
      channel.enable = false;
      registry.nixpkgs.flake = inputs.nixpkgs;

      gc.automatic = true;
      gc.dates = "weekly";
      gc.options = "--delete-older-than 14d";

      optimise.automatic = true;

      settings.experimental-features = ["nix-command" "flakes" "pipe-operators"];
      settings.trusted-users = ["root" "@wheel"];
      settings.download-buffer-size = 1024 * 1024 * 1024;
      settings.build-dir = "/nix/var/nix/builds";

      settings.extra-substituters = [
        "https://nix-community.cachix.org"
        "https://cache.numtide.com"
      ];
      settings.extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };

    # ------------------------------------------------------------------- locale
    time.timeZone = "Europe/Rome";

    i18n.defaultLocale = "en_US.UTF-8";

    # ----------------------------------------------------------------- security
    security.sudo.enable = false;
    security.sudo-rs = {
      enable = true;
      wheelNeedsPassword = false;
    };

    users.mutableUsers = lib.mkDefault false;

    # --------------------------------------------------------------------- boot
    boot = {
      initrd.systemd.enable = true;

      tmp.useTmpfs = true;
      tmp.tmpfsHugeMemoryPages = "within_size";
    };

    # ----------------------------------------------------------------- services
    services.openssh = {
      enable = true;
      openFirewall = false;
      settings.PasswordAuthentication = false;
    };
  };
}
