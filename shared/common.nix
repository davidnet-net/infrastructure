{ config, pkgs, ... }:

{
  # Journald configuration
  services.journald.extraConfig = "SystemMaxUse=500M\nRateLimitInterval=30s\nRateLimitBurst=1000";

  # System packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    kubernetes-helm
    helmfile
    kubectl

    htop
    tree
    micro
    wget
    curl
  ];

  # NIX Garbage collection
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 1d";
  };

  services.logrotate.enable = true;
  services.logrotate.logs = {
    "/var/log/audit/audit.log" = { rotate = 5; size = "50M"; compress = true; maxage = 14; };
    "/var/log/messages"        = { rotate = 5; size = "50M"; compress = true; maxage = 14; };
    "/var/log/syslog"          = { rotate = 5; size = "50M"; compress = true; maxage = 14; };
    "/var/log/daemon.log"      = { rotate = 5; size = "50M"; compress = true; maxage = 14; };
    "/var/log/k3s.log"         = { rotate = 5; size = "50M"; compress = true; maxage = 14; };
  };
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
}