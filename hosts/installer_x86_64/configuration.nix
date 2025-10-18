{ config, pkgs, ... }:

{
  # Boot stuff
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # META
  networking.hostName = "installer_x86_64";
}
