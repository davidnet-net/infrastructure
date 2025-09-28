{ config, pkgs, ... }:

let
  splash = import ../../shared/splash.nix;
in
{
  # META
  networking.hostName = "testserver";
  time.timeZone = "UTC";

  # Time synchronization
  services.timesyncd.enable = true;
  services.timesyncd.servers = [
    "0.nl.pool.ntp.org"
    "1.nl.pool.ntp.org"
    "2.nl.pool.ntp.org"
  ];

  # Journald configuration
  services.journald.extraConfig = "SystemMaxUse=500M\nRateLimitInterval=30s\nRateLimitBurst=1000";

  # Enable SSH server
  services.openssh.enable = true;

  # Enforce SSH keys
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  # Root user with only SSH key access
  users.users.root = {
    isNormalUser = false;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmE2BO6bcsMuVHhoRUOXo6TCxqQmlI4lADGlCh8LAL3 david@davidnet.net"
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [ micro wget curl sl ];

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "25.05";
}
