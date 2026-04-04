{inputs, ...}: {
  flake.nixosModules.disko = {
    config,
    lib,
    ...
  }:
    with lib; let
      cfg = config.features.storage.disko;
    in {
      imports = [inputs.disko.nixosModules.disko];

      options.features.storage.disko = {
        enable = mkEnableOption "disk layout management via disko";

        layout = mkOption {
          type = types.attrsOf types.anything;
          default = {};
          description = "Disk layout passed directly to disko.devices.disk";
        };

        luks = {
          enable = mkEnableOption "LUKS encryption";

          device = mkOption {
            type = types.str;
            default = "/dev/disk/by-partlabel/root";
            description = "Encrypted partition device path";
          };

          tpm2 = mkEnableOption "TPM2 auto-unlock via systemd-cryptenroll";
        };
      };

      config = mkIf cfg.enable {
        disko.devices.disk = cfg.layout;

        boot.initrd.luks.devices = mkIf cfg.luks.enable {
          cryptroot.crypttabExtraOpts = optionals cfg.luks.tpm2 ["tpm2-device=auto"];
        };
      };
    };

  flake.nixosModules.storage.imports = [inputs.self.nixosModules.disko];
}
