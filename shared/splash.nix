{ config, pkgs, ... }:

{
  # Enable Plymouth and set the theme
  boot.plymouth.enable = true;
  boot.plymouth.theme = "fade-in";
  boot.kernelParams = [ "quiet" "splash" ];
  boot.plymouth.logo = "${config.environment.etc."/boot/bootsplash.png".source}";
  environment.etc."/boot/bootsplash.png".source = ./bootsplash.png;
  
 # Custom splash service on TTY1
  systemd.services."davidnet-splash" = {
    description = "Davidnet Splash";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash /etc/davidnet-splash.sh";
      StandardOutput = "tty";
      TTYPath = "/dev/tty1";
      TTYReset = true;
      TTYVHangup = true;
    };
  };

  # Logs service on TTY2
  systemd.services."davidnet-logs" = {
    description = "Davidnet Logs";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash /etc/davidnet-logs.sh";
      StandardOutput = "tty";
      TTYPath = "/dev/tty2";
      TTYReset = true;
      TTYVHangup = true;
    };
  };

  # Splash script
  environment.etc."davidnet-splash.sh".text = ''
    #!/bin/bash

    # Stop getty on TTY1 and TTY2
    systemctl stop getty@tty1.service
    systemctl disable getty@tty1.service
    systemctl stop getty@tty2.service
    systemctl disable getty@tty2.service

    /run/current-system/sw/bin/clear

    # ASCII art
    cat <<'EOF'
              ____              _     __           __ 
            / __ \____ __   __(_)___/ /___  ___  / /_
            / / / / __ `/ | / / / __  / __ \/ _ \/ __/
          / /_/ / /_/ /| |/ / / /_/ / / / /  __/ /_  
          /_____/\__,_/ |___/_/\__,_/_/ /_/\___/\__/  
                                                      
                      Loading thingies 

                   
    EOF

    echo "Loading network info..."
    echo "Waiting for network to start..."
    while true; do
      IP=$(/run/current-system/sw/bin/ip -4 addr show scope global | \
          /run/current-system/sw/bin/awk '/inet / {print $2; exit}' | \
          /run/current-system/sw/bin/cut -d/ -f1)
      if [ -n "$IP" ]; then
        break
      fi
      sleep 1
    done
    sleep 2
    /run/current-system/sw/bin/clear
    cat <<'EOF'
              ____              _     __           __ 
            / __ \____ __   __(_)___/ /___  ___  / /_
            / / / / __ `/ | / / / __  / __ \/ _ \/ __/
          / /_/ / /_/ /| |/ / / /_/ / / / /  __/ /_  
          /_____/\__,_/ |___/_/\__,_/_/ /_/\___/\__/  
                                                      
                      Davidnet Server 

                   
    EOF


    echo "Host: $(/run/current-system/sw/bin/hostname) - Booted: $(date)"
    echo "----------------------------------------------------------"
    echo "         TTY1 - DN Splash | TTY2 - LOGS | TTY3 - Console  "
    echo "----------------------------------------------------------"
    echo "              root@$(/run/current-system/sw/bin/hostname):22 | root@$(/run/current-system/sw/bin/ip -4 addr show scope global | /run/current-system/sw/bin/awk '/inet / {print $2; exit}' | /run/current-system/sw/bin/cut -d/ -f1):22        "
    echo "                                                    "
    echo "                NOTICE: SSH key access only              "
    echo "----------------------------------------------------------"
  '';

  # Logs script for TTY2
  environment.etc."davidnet-logs.sh".text = ''
    #!/bin/bash
    /run/current-system/sw/bin/clear
    echo "Davidnet Logs - Booted: $(date)"
    journalctl -f
  '';
}