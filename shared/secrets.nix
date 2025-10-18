{
  age.identityPaths = [ "/etc/agenix/shared.agekey" ]; # PRIVATE KEY to decrypt with.

  age.secrets.k3s-token = {
    file = ../secrets/k3s-token.age;
    path = "/etc/rancher/k3s-token";
  };
}
