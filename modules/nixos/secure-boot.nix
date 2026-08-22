{
  config,
  inputs,
  ...
}: let
  inherit (config.flake.modules) nixos;
in {
  flake.modules.nixos.secure-boot = {pkgs, ...}: {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
      nixos.preservation
    ];

    environment.systemPackages = [pkgs.sbctl];

    boot = {
      loader.efi.canTouchEfiVariables = true;
      loader.systemd-boot.editor = false;

      lanzaboote.enable = true;
      lanzaboote.pkiBundle = "/var/lib/sbctl";
      lanzaboote.configurationLimit = 8;

      lanzaboote.autoGenerateKeys.enable = true;
      lanzaboote.autoEnrollKeys.enable = true;
      lanzaboote.autoEnrollKeys.autoReboot = true;
    };

    preservation.preserveAt."/persistent".directories = ["/var/lib/sbctl"];
  };
}
