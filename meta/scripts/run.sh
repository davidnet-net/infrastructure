#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

cd "$(dirname "$0")/../.."
source config.sh
source meta/scripts/modules/utils.sh

KEEPDISK=false

# Parse flags
for arg in "$@"; do
    case $arg in
        --keepdisk)
            KEEPDISK=true
            shift
            ;;
        *)
            ;;
    esac
done

log "Starting x86_64 NixOS VM" "NOTE"

# Disk creation
if [ -f "dev/run/x86_64.img" ]; then
    if [ "$KEEPDISK" = true ]; then
        log " - VM disk exists, keeping it" "NOTE"
    else
        log " - VM disk exists, resetting"
        rm -rf dev/run/x86_64.img
        rm -rf dev/run/OVMF_VARS.fd
        rm -rf dev/run/OVMF_CODE.fd

        log " - Reset" "OK"
    fi
fi

if [ ! -f "dev/run/x86_64.img" ]; then
    log " - Creating VM disk at dev/run/x86_64.img (20G)"
    if qemu-img create -f raw dev/run/x86_64.img 20G; then
        log " - VM disk created at dev/run/x86_64.img" "OK"
    else
        log " - Failed to create VM disk at dev/run/x86_64.img" "ERROR"
        exit 1
    fi

    cp dev/ovmf/OVMF_VARS_4M.fd dev/run/OVMF_VARS.fd
    cp dev/ovmf/OVMF_CODE_4M.fd dev/run/OVMF_CODE.fd
fi

# Start VM
qemu-system-x86_64 \
    -m 8096 \
    -smp 4 \
    -drive if=pflash,format=raw,readonly=on,file=dev/run/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=dev/run/OVMF_VARS.fd \
    -drive file=dev/run/x86_64.img,format=raw \
    -cdrom result/iso/nixos-minimal-25.05.20250925.25e53aa-x86_64-linux.iso \
    -boot d \
    -net nic -net user,hostfwd=tcp::2222-:22 \
    -enable-kvm
