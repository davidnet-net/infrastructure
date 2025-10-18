#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

cd "$(dirname "$0")/../.."
source config.sh
source meta/scripts/modules/utils.sh
start_time=$(date +%s%3N)

log "Initing Davidnet Infrastructure Environment" "NOTE"

#? host_arch
host_arch=$(uname -m)
if [ "$host_arch" != "x86_64" ] && [ "$host_arch" != "aarch64" ]; then
    log "Unsupported architecture: $host_arch" "ERROR"
    exit 1
fi
if  [ "$host_arch" == "aarch64" ]; then
    log "ARM ARCH - Is not tested in DEV!" "WARNING"
fi

#? Enter NIX dev shell
if [ "$INNIXDEVSHELL" = "true" ]; then
  echo "Already inside the devshell (:"
else
  echo "Entering NIX dev shell."
  nix develop
fi

#? Config Check
log "Running config check"
config_check=("x86_64_nixOS_minimal_iso" "aarch64_nixOS_minimal_iso" "x86_64_nixOS_minimal_iso_hash" "aarch64_nixOS_minimal_iso_hash")
for config in "${config_check[@]}"; do
    if [ -z "${!config:-}" ]; then
        log " - $config not found!" "ERROR"
        exit 1
    else
        log " - $config exists" "OK"
    fi
done
log "Config check" "OK"

#? Packages Check
log "Checking required packages"

# virsh = libvirt
required_packages=("virt-manager" "virsh" "wget" "git")

# Add architecture-specific packages
if [ "$host_arch" = "x86_64" ]; then
    required_packages+=("qemu-system-x86_64")
else
    required_packages+=("qemu-system-aarch64")
fi

for package in "${required_packages[@]}"; do
    if command -v "$package" &>/dev/null; then
        log " - $package found" "OK"
    else
        log " - $package not found!" "ERROR"
        exit 1
    fi
done

#? Folder Setup
log "Setting up the folders"

folders=("dev" "dev/run" "dev/ovmf")

for folder in "${folders[@]}"; do
    if [ -d "$folder" ]; then
        log "Folder '$folder'" "OK"
    else
        if mkdir -p "$folder"; then
            log "Created folder '$folder'" "OK"
        else
            log "Failed to create folder '$folder'" "ERROR"
            exit 1
        fi
    fi
done
log "Folder setup" "OK"

#? Caching
log "Caching"
declare -A files_to_cache=(
    #["cache/nixos-minimal_x86_64.iso"]="$x86_64_nixOS_minimal_iso"
    #["cache/nixos-minimal_aarch.iso"]="$aarch64_nixOS_minimal_iso"
)

declare -A files_hashes=(
    #["cache/nixos-minimal_x86_64.iso"]="$x86_64_nixOS_minimal_iso_hash"
    #["cache/nixos-minimal_aarch.iso"]="$aarch64_nixOS_minimal_iso_hash"
)

for file_path in "${!files_to_cache[@]}"; do
    url="${files_to_cache[$file_path]}"
    expected_hash="${files_hashes[$file_path]:-}"

    if [ -f "$file_path" ]; then
        log " - $file_path" "OK"
    else
        log "Downloading $url --> $file_path"
        wget -q --show-progress "$url" -O "$file_path" \
            && log " - $file_path" "OK" \
            || { log "Failed to download $file_path" "ERROR"; exit 1; }
    fi

    # Verify hash if provided
    if [ -n "$expected_hash" ]; then
        actual_hash=$(sha256sum "$file_path" | awk '{print $1}')
        if [ "$actual_hash" != "$expected_hash" ]; then
            log "Hash mismatch for $file_path!" "ERROR"
            exit 1
        else
            log " - Hash $file_path" "OK"
        fi
    else
        log " - No Hash for $file_path" "WARNING"
    fi
done

cp -r /usr/share/OVMF/* ./dev/ovmf
log "Caching complete" "OK"

#? Timings
end_time=$(date +%s%3N)
elapsed_ms=$((end_time - start_time))

hours=$((elapsed_ms / 3600000))
minutes=$(((elapsed_ms % 3600000) / 60000))
seconds=$(((elapsed_ms % 60000) / 1000))
milliseconds=$((elapsed_ms % 1000))

log "Finished INIT in $(printf '%02d:%02d:%02d:%03d' $hours $minutes $seconds $milliseconds)" "NOTE"

log "Checking secrets"
if [ -f "secrets/keys/shared.agekey" ]; then
    log " - shared.agekey" "OK"
else
    log "Please decrypt the secrets" "NOTE"
    age -d -o secrets/keys/shared.agekey meta/shared.agekey.age
fi
log "Script completed" "NOTE"