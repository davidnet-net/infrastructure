{ config, pkgs, ... }:

let
  vip = "192.168.1.245";
in
{
  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = "/etc/rancher/k3s-token";

    extraFlags = toString ([
      "--disable servicelb"
      "--disable local-storage"
      "--disable traefik"
      "--tls-san 192.168.1.245"
    ] ++ (if config.networking.hostName == "asuslaptop" then [
      "--cluster-init"
    ] else [
      "--server https://192.168.1.245:6443"
    ]));
  };
  environment.etc."kube/config".source = "/etc/rancher/k3s/k3s.yaml"; # Fix kubectl issue

  services.keepalived = {
    enable = true;

    vrrpInstances = {
      "VI_1" = {
        interface = if config.networking.hostName == "asuslaptop" then "enp3s0f5"
                    else if config.networking.hostName == "acerlaptop" then "enp2s0"
                    else "eth0";

        virtualRouterId = 245;

        state = if config.networking.hostName == "asuslaptop" then "MASTER" else "BACKUP";
        priority = if config.networking.hostName == "asuslaptop" then 100
                   else if config.networking.hostName == "acerlaptop" then 90
                   else 80;

        virtualIps = [{
          addr = vip;
          scope = "global";
        }];

        extraConfig = ''
          authentication PASS supersecretpass
        '';
      };
    };
  };
}
