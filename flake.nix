{
  description = "DEV environment for Davidnet Infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-anywhere, disko }: 
    let
      # NixIgnore - Prevents the nixstore from ballooning
      cleanSrc = nixpkgs.lib.cleanSource ./. {
        exclude = [
          "dev/run/**"
          "dev/ovmf/**"
          "result"
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

    # Dev Packages
    packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = [
        nixpkgs.legacyPackages.x86_64-linux.qemu
        nixpkgs.legacyPackages.x86_64-linux.virt-manager
        nixpkgs.legacyPackages.x86_64-linux.libvirt
        nixpkgs.legacyPackages.x86_64-linux.wget
        nixpkgs.legacyPackages.x86_64-linux.git
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
        
        nixos-anywhere.packages.x86_64-linux.default
      ];
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
          ./hosts/testserver/configuration.nix
          ./hosts/testserver/disko-config.nix
          ./shared/common.nix
          ./shared/locals.nix
          ./shared/security.nix
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
          ./hosts/asuslaptop/configuration.nix
          ./hosts/asuslaptop/disko-config.nix
          ./hosts/asuslaptop/hardware-config.nix
          ./shared/common.nix
          ./shared/locals.nix
          ./shared/security.nix
          ./shared/k3s.nix
        ];

        # Use cleanSrc so large files like VM images are ignored
        specialArgs = { inherit cleanSrc; };
      };
    };
  };
}
