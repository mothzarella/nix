{
  config,
  lib,
  ...
}: let
  inherit (config.flake.modules) nixos;
in {
  flake.modules.nixos.cinnamon = {
    imports = with nixos; [
      btrfs-rollback
      networking
      performance
      preservation
      secure-boot
      tar
    ];

    hardware.facter.reportPath = ./facter.json;
    hardware.facter.detected.boot.graphics.kernelModules = lib.mkForce ["i915"];

    system.stateVersion = "26.05";
  };
}
