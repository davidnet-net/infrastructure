{ config, pkgs, ... }:

{
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
}