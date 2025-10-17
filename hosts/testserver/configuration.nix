{ config, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  
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

  # Root user authorized key
  users.users.root = {
    isNormalUser = false;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+TdfBM57RH+AKlZUFFN3uu4SWRvrcFrEB3uBQsl6L4 david@davidnet.net"
    ];
  };

  # System packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [ micro wget curl sl ];

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 1d";
  };

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # System state version
  system.stateVersion = "25.05";
}
