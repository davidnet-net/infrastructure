{
  "secrets/k3s-token.age" = {
    publicKeys = [
      "age1eesyhsknrxq23g80nwyavs5v5kysq2g86uv4pqzvwu57cy3v3udqaqm3eu"
    ];
  };
}

# Encrypt things with

# agenix -e secrets/k3s-token.age

# An editor will open where i can enter the secret
# The age file -e is the encrypted secret location


# Decryption happens in ./shared/secrets.nix