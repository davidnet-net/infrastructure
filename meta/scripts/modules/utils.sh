#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Usage: log "Your message" ["OK|WARNING|ERROR|NOTE"]
log() {
    local message="$1"
    local status="${2:-}"  # Default is empty string

    if [ -z "$status" ]; then
        # No status passed → just print the message
        printf "%s\n" "$message"
        return
    fi

    # ANSI color codes
    local color_reset="\033[0m"
    local color_ok="\033[32m"
    local color_warning="\033[33m"
    local color_error="\033[31m"
    local color_note="\033[34m"

    local color
    case "$status" in
        OK) color="$color_ok" ;;
        WARNING) color="$color_warning" ;;
        ERROR) color="$color_error" ;;
        NOTE) color="$color_note" ;;
        *) color="$color_reset" ;;
    esac

    printf "%s | [%b%s%b]\n" "$message" "$color" "$status" "$color_reset"
}