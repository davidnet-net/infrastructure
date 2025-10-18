{
  description = "DEV environment for Davidnet Infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, nixos-anywhere, disko, agenix }: 
    let
      # NixIgnore - Prevents the nixstore from ballooning
      cleanSrc = nixpkgs.lib.cleanSource ./. {
        exclude = [
          "dev/run/**"
          "dev/ovmf/**"
          "result"
          "secrets/keys/shared.agekey"
          "secrets/raw/**"
        ];
      };
    in
  {
    # Packages for dev tools
    packages.x86_64-linux.qemu = nixpkgs.legacyPackages.x86_64-linux.qemu;
    packages.x86_64-linux.virtManager = nixpkgs.legacyPackages.x86_64-linux.virt-manager;
    packages.x86_64-linux.libvirt = nixpkgs.legacyPackages.x86_64-linux.libvirt;
    packages.x86_64-linux.wget = nixpkgs.legacyPackages.x86_64-linux.wget;
    packages.x86_64-linux.git = nixpkgs.legacyPackages.x86_64-linux.git;
    packages.x86_64-linux.age = nixpkgs.legacyPackages.x86_64-linux.age;
    packages.x86_64-linux.micro = nixpkgs.legacyPackages.x86_64-linux.micro;
    packages.x86_64-linux.agenix = agenix.packages.x86_64-linux.agenix;
    packages.x86_64-linux.nixosAnywhere = nixos-anywhere.packages.x86_64-linux.default;
   
    # Dev Packages
    packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = [
        nixpkgs.legacyPackages.x86_64-linux.qemu
        nixpkgs.legacyPackages.x86_64-linux.virt-manager
        nixpkgs.legacyPackages.x86_64-linux.libvirt
        nixpkgs.legacyPackages.x86_64-linux.wget
        nixpkgs.legacyPackages.x86_64-linux.git
        nixpkgs.legacyPackages.x86_64-linux.age
        nixpkgs.legacyPackages.x86_64-linux.micro
        agenix.packages.x86_64-linux.agenix
        nixos-anywhere.packages.x86_64-linux.default
      ];
    };

    # Dev shell
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = [
        nixpkgs.legacyPackages.x86_64-linux.qemu
        nixpkgs.legacyPackages.x86_64-linux.virt-manager
        nixpkgs.legacyPackages.x86_64-linux.libvirt
        nixpkgs.legacyPackages.x86_64-linux.wget
        nixpkgs.legacyPackages.x86_64-linux.git
        nixpkgs.legacyPackages.x86_64-linux.age
        nixpkgs.legacyPackages.x86_64-linux.micro
        agenix.packages.x86_64-linux.agenix
        nixos-anywhere.packages.x86_64-linux.default
      ];

      shellHook = ''
        export EDITOR=micro
        export RULES=./secrets.nix
        export INNIXDEVSHELL=true
      '';
    };

    # Hosts:
    nixosConfigurations = {
      # Installer ISO
      installer_x86_64 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/installer_x86_64/configuration.nix
          ./shared/common.nix
          ./shared/locals.nix
          ./shared/security.nix
          ./shared/splash.nix
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ];

        # Use cleanSrc so large files like VM images are ignored
        specialArgs = { inherit cleanSrc; };
      };


      # For use in the VM
      testserver = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          agenix.nixosModules.default
          ./hosts/testserver/configuration.nix
          ./hosts/testserver/disko-config.nix
          ./shared/common.nix
          ./shared/locals.nix
          ./shared/security.nix
          ./shared/secrets.nix
          ./shared/splash.nix
          ./shared/k3s.nix
        ];

        # Use cleanSrc so large files like VM images are ignored
        specialArgs = { inherit cleanSrc; };
      };


      # Normal servers:
      asuslaptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          agenix.nixosModules.default
          ./hosts/asuslaptop/configuration.nix
          ./hosts/asuslaptop/disko-config.nix
          ./hosts/asuslaptop/hardware-config.nix
          ./shared/common.nix
          ./shared/locals.nix
          ./shared/security.nix
          ./shared/secrets.nix
          ./shared/splash.nix
          ./shared/k3s.nix
        ];

        # Use cleanSrc so large files like VM images are ignored
        specialArgs = { inherit cleanSrc; };
      };
    };
  };
}
