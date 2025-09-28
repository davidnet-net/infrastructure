{ config, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # META
  networking.hostName = "testserver";
  time.timeZone = "Europe/Amsterdam";
  services.timesyncd.enable = true;
  services.timesyncd.servers = [
    "0.nl.pool.ntp.org"
    "1.nl.pool.ntp.org"
    "2.nl.pool.ntp.org"
  ];
  services.journald.extraConfig = "SystemMaxUse=500M   RateLimitInterval=30s RateLimitBurst=1000";
  services.journald.console = "/dev/tty2";

  # Enable SSH server
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = "prohibit-password";

  # Disable Pysical console
  systemd.services."getty@tty1".enable = false;
  systemd.services."getty@tty1".masked = true;

  systemd.services."getty@tty2".enable = false;
  systemd.services."getty@tty2".masked = true;

  # Root user authorized key
  users.users.root = {
    isNormalUser = false;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmE2BO6bcsMuVHhoRUOXo6TCxqQmlI4lADGlCh8LAL3 david@davidnet.net"
    ];
  };

  environment.systemPackages = with pkgs; [ micro wget curl sl ];

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 1d";
  };


  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "25.05";

  # Custom SPLASH 
  systemd.services."custom-splash" = {
    description = "Custom Console Splash Screen";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash /etc/custom-splash.sh";
      StandardOutput = "tty";
      TTYPath = "/dev/tty1";
      TTYReset = true;
      TTYVHangup = true;
    };
  };

  # Script that generates your splash
  environment.etc."custom-splash.sh".text = ''
    #!/bin/bash
    echo "Preparing Davidnet Splashscreen"
    sleep 10
    clear

    # ASCII art
    cat <<'EOF'
              ____              _     __           __ 
            / __ \____ __   __(_)___/ /___  ___  / /_
            / / / / __ `/ | / / / __  / __ \/ _ \/ __/
          / /_/ / /_/ /| |/ / / /_/ / / / /  __/ /_  
          /_____/\__,_/ |___/_/\__,_/_/ /_/\___/\__/  
                                                      
    EOF

    echo "       Welcome to testserver - Booted: $(date)      "
    echo "----------------------------------------------------"
  '';
}
