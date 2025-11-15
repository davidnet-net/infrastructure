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

  # Log rotation
  services.logrotate.enable = true;
  services.logrotate.settings = {
    "audit" = {
      files = [ "/var/log/audit/audit.log" ];
      frequency = "daily";
      rotate = 5;
      size = "50M";
      compress = true;
      maxage = 14;
      enable = true;
    };

    "syslog" = {
      files = [ "/var/log/messages" "/var/log/syslog" "/var/log/daemon.log" ];
      frequency = "daily";
      rotate = 5;
      size = "50M";
      compress = true;
      maxage = 14;
      enable = true;
    };

    "k3s" = {
      files = [ "/var/log/k3s.log" ];
      frequency = "daily";
      rotate = 5;
      size = "50M";
      compress = true;
      maxage = 14;
      enable = true;
    };
  };

  # Nix Config
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
}