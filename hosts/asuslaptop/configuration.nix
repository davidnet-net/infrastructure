{ config, pkgs, ... }:

{
  # Boot stuff
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  
  # META
  networking.hostName = "asuslaptop";
}
