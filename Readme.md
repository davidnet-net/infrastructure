# Init

When opening the project do the following

  - Make sure NIX the package manager is installed
  - Nix Flakes are turned on
  - You are inside the devshell using ``` nix develop ```
  - You run the initer: ``` bash meta/scripts/init.sh ```

# Installers

## x86_64
``` nix build .#nixosConfigurations.installer_x86_64.config.system.build.isoImage ```

An iso will appear under result/iso

## aarch64
``` TODO ```

# Testing

To start the VM run ``` bash meta/scripts/run.sh ```

Add the ``` --keepdisk ``` flag if you want to keep your disk.

Use nixos-everywhere as following ``` nixos-anywhere --debug --flake .#server1 --target-host root@localhost -p 2222 ```

Make sure to use the testserver host

# PROD

Use the installer ISO's to start an headless initer.


From then on and after first boot update using:

``` nixos-anywhere --debug --flake .#hostname --target-host root@hostname -p 22 ```

# Notes

## QEMU TTY
In qemu tty can be switched using the qemu console

``` ctrl + alt + 2 ```

Enter

``` sendkey ctrl-alt-f2 ```

Return to vm

``` ctrl + alt + 1 ```

## Hardware stuff:
https://github.com/NixOS/nixos-hardware/blob/master/raspberry-pi/5/default.nix

## Timezone

NOTICE: USING UTC TIMEZONE

