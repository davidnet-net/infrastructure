{ config, pkgs, ... }:

let
  splash = import ../../shared/splash.nix;
in
{
  # Enable SSH server
  services.openssh.enable = true;

  # Disable password login completely
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  # Root user with only SSH key access
  users.users.root = {
    isNormalUser = false;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmE2BO6bcsMuVHhoRUOXo6TCxqQmlI4lADGlCh8LAL3 david@davidnet.net"
    ];
  };

   # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "25.05";
}
