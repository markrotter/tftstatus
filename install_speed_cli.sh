#!/usr/bin/env bash
###############################################################################
# install_speed_cli.sh – Install Ookla & LibreSpeed CLI on Raspberry Pi
###############################################################################
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo."; exit 1; }

ARCH=$(dpkg --print-architecture)   # arm64  or  armhf
echo "→  Architecture: $ARCH"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

###############################################################################
# 1. Ookla CLI (speedtest)  v1.2.0
###############################################################################
if command -v speedtest &>/dev/null; then
  echo "✓  Ookla speedtest already installed."
else
  case $ARCH in
    arm64) O_TGZ=ookla-speedtest-1.2.0-linux-aarch64.tgz ;;
    armhf) O_TGZ=ookla-speedtest-1.2.0-linux-armhf.tgz   ;;
    *)     O_TGZ=""; echo "✖  Unsupported arch for Ookla CLI." ;;
  esac
  if [[ -n $O_TGZ ]]; then
    echo "→  Downloading Ookla CLI …"
    curl -L -o "$TMP/ookla.tgz" "https://install.speedtest.net/app/cli/$O_TGZ"
    tar -xzf "$TMP/ookla.tgz" -C "$TMP"
    install -m 755 "$TMP/speedtest" /usr/local/bin/speedtest
    echo "✓  Installed Ookla CLI → /usr/local/bin/speedtest"
  fi
fi

###############################################################################
# 2. LibreSpeed CLI  v1.0.11
###############################################################################
if command -v librespeed-cli &>/dev/null; then
  echo "✓  LibreSpeed CLI already installed."
else
  case $ARCH in
    arm64) L_TGZ=librespeed-cli_1.0.11_linux_arm64.tar.gz ;;
    armhf) L_TGZ=librespeed-cli_1.0.11_linux_armv7.tar.gz ;;
    *)     L_TGZ=""; echo "✖  Unsupported arch for LibreSpeed CLI." ;;
  esac
  if [[ -n $L_TGZ ]]; then
    echo "→  Downloading LibreSpeed CLI …"
    curl -L -o "$TMP/libre.tgz" \
      "https://github.com/librespeed/speedtest-cli/releases/download/v1.0.11/$L_TGZ"
    tar -xzf "$TMP/libre.tgz" -C "$TMP"
    # locate the binary regardless of exact folder name
    BIN=$(find "$TMP" -type f -name librespeed-cli -perm -u+x | head -n1 || true)
    if [[ -n $BIN ]]; then
      install -m 755 "$BIN" /usr/local/bin/librespeed-cli
      echo "✓  Installed LibreSpeed CLI → /usr/local/bin/librespeed-cli"
    else
      echo "✖  Could not locate librespeed-cli in extracted archive."
    fi
  fi
fi

echo "############################################################################"
echo "  Finished. Test with:"
echo "    speedtest --accept-license --accept-gdpr --format=human-readable"
echo "    speedtest --accept-license --accept-gdpr --progress=no --format=json"
echo "    librespeed-cli --json"
echo "############################################################################"

