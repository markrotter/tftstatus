#!/usr/bin/env bash
###############################################################################
# status_install_autostart.sh  –  installs systemd‑user unit   Rev‑2 (2025‑06‑19)
###############################################################################
set -euo pipefail

DASH="$HOME/tftstatus/status.sh"        # ←‑‑ updated
[[ -x $DASH ]] || { echo "✖  $DASH missing or not executable"; exit 1; }

UNIT_DIR="$HOME/.config/systemd/user"
UNIT_FILE="$UNIT_DIR/tft-dashboard.service"
mkdir -p "$UNIT_DIR"

cat >"$UNIT_FILE" <<EOF
[Unit]
Description=TFT dashboard
After=systemd-user-sessions.service

[Service]
ExecStart=$DASH
Restart=on-failure
RestartSec=10
StandardOutput=tty
TTYPath=/dev/tty1
TTYReset=yes
TTYVHangup=yes

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now tft-dashboard.service

echo "✓  tft-dashboard.service enabled."
read -rp "Enable systemd‑linger (run without login)? [y/N] " yn
if [[ $yn =~ ^[Yy]$ ]]; then sudo loginctl enable-linger "$USER"; echo "✓ linger on."; fi
