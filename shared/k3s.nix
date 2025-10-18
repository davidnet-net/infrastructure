{ config, pkgs, ... }:

{
  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = "/etc/rancher/k3s-token";

    extraFlags = toString ([
      "--disable servicelb"
      "--disable traefik"
      "--disable local-storage"
      ] ++ (if config.networking.hostName == "asuslaptop" then [
        "--cluster-init"
      ] else [
        "--server https://asuslaptop:6443"
      ]));
    };

  # Fixes for longhorn
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
  virtualisation.docker.logDriver = "json-file";

}