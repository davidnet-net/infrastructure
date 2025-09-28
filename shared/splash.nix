{ config, pkgs, ... }:

{
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

    sleep 10
    HOSTNAME=$(hostname)
    IP=$(hostname -I | awk '{print $1}')
    /run/current-system/sw/bin/clear

    # ASCII art
    cat <<'EOF'
              ____              _     __           __ 
            / __ \____ __   __(_)___/ /___  ___  / /_
            / / / / __ `/ | / / / __  / __ \/ _ \/ __/
          / /_/ / /_/ /| |/ / / /_/ / / / /  __/ /_  
          /_____/\__,_/ |___/_/\__,_/_/ /_/\___/\__/  
                                                      
    EOF

    sleep 2

    echo "Welcome to $HOSTNAME - Booted: $(date)"
    echo "----------------------------------------------------"
    echo "   TTY1 - DN Splash | TTY2 - LOGS | TTY3 - Console  "
    echo "----------------------------------------------------"
    echo "         root@$HOSTNAME:22 | root@$IP:22            "
    echo "                                                    "
    echo "           NOTICE: SSH key access only              "
    echo "----------------------------------------------------"
  '';

  # Logs script for TTY2
  environment.etc."davidnet-logs.sh".text = ''
    #!/bin/bash
    /run/current-system/sw/bin/clear
    echo "Davidnet Logs - Booted: $(date)"
    journalctl -f
  '';
}