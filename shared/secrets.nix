{ config, pkgs, ... }:

let
  sharedKeyPath = "/etc/agenix/shared.agekey";
in {
  age.identityPaths = [ sharedKeyPath ];

  age.secrets.k3s-token = {
    file = ../secrets/k3s-token.age;
    path = "/etc/rancher/k3s-token";
  };
}
