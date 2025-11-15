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
  services.fail2ban.enable = true;
  services.fail2ban.maxretry = 3;
  services.fail2ban.bantime = "1h";
  services.fail2ban.jails = {
    sshd = {
      settings = {
        filter = "sshd";
        logpath = "/var/log/auth.log";
        backend = "auto";
        findtime = 600;
      };
    };
  };


  security.auditd.enable = true;
  environment.etc."audit/rules.d/50-k3s.rules".text = ''
    -w /etc/rancher/k3s-token -p rwxa -k k3s-token
    -w /etc/ssh/ -p wa -k ssh-config
    -w /var/lib/rancher/ -p wa -k k3s-data
  '';

  # Security flags
  security.sudo.enable = false;
  security.sudo-rs.enable = true;
  systemd.tmpfiles.rules = [ "f /boot/efi/loader/.#bootctlrandom-seed* 0600 root root -"];
}