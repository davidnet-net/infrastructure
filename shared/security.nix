{ config, pkgs, ... }:

{
  # User
  users.users.root = {
    isNormalUser = false;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+TdfBM57RH+AKlZUFFN3uu4SWRvrcFrEB3uBQsl6L4 david@davidnet.net"
    ];
  };

  # SSH
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "prohibit-password";
    PermitEmptyPasswords = false;
    MaxAuthTries = 3;
    ChallengeResponseAuthentication = false;
    LoginGraceTime = "30s";
  };

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 6443 10250];
  networking.firewall.allowedUDPPorts = [ 8472 ];

  # Ports
  # 22 - SSH
  # 6443 - Kubelet API server
  # 10250 - Kublet metrics server
  # 8472 - VXLAN Networking

  # More info: https://docs.k3s.io/installation/requirements#inbound-rules-for-k3s-nodes

  # Fail2Ban
  services.fail2ban = {
    enable = true;
    jails = {
      sshd = {
        enabled = true;
        maxRetry = 3;
        findTime = "10m";
        banTime = "1h";
      };
    };
  };

  # Auditd
  services.auditd.enable = true;
  services.auditd.rules = ''
    # Monitor k3s token file
    -w /etc/rancher/k3s-token -p rwxa -k k3s-token

    # Monitor SSH configs
    -w /etc/ssh/ -p wa -k ssh-config

    # Monitor k3s persistent data directory
    -w /var/lib/rancher/ -p wa -k k3s-data
  '';

  # Security flags
  security.sudo.enable = false;
  security.sudo-rs.enable = true;
}