# Davidnet Infrastructure

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

Deploy as following ``` bash meta/scripts/deploy.sh -h testserver -s localhost -p 2222 ```

Make sure to use the testserver host

# PROD

Use the installer ISO's to start an headless initer.


From then on and after first boot update using:

``` bash meta/scripts/deploy.sh -h hostname -s host -p 22 ```

# Notes

## QEMU TTY
In qemu tty can be switched using the qemu console

``` ctrl + alt + 2 ```

Enter

``` sendkey ctrl-alt-f2 ```

Return to vm

``` ctrl + alt + 1 ```

# KubeCONFIG
``` scp root@192.168.1.245:/etc/rancher/k3s/k3s.yaml ~/.kube/config
 ```

Make sure to update the server ip!!!


Kubectl cli will not work on first boot on the server itself

## Hardware stuff:
https://github.com/NixOS/nixos-hardware/blob/master/raspberry-pi/5/default.nix

## Info

USING UTC TIMEZONE

IP's >192.168.1.245 zijn niet met DHCP

