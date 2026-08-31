{nixos, ...}: {
  imports = with nixos; [audio browser files networking terminal theme];
}
