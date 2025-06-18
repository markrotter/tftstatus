#!/usr/bin/env bash
###############################################################################
# status_setup_drivers.sh  –  ROOT script to prepare TFT + console
###############################################################################
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Run with sudo."; exit 1; }

USER_TARGET="${1:-${SUDO_USER:-}}"
while [[ -z $USER_TARGET ]]; do read -rp "Dashboard user: " USER_TARGET; done
id "$USER_TARGET" &>/dev/null || { echo "User $USER_TARGET not found"; exit 1; }

BOOT=/boot/firmware; [[ -e $BOOT/config.txt ]] || BOOT=/boot
spi='dtparam=spi=on'
tft='dtoverlay=piscreen,drm,rotate=90,speed=16000000'
map='fbcon=map:1 consoleblank=0'

for f in config.txt cmdline.txt; do cp -p "$BOOT/$f" "$BOOT/${f}.bak.$(date +%s)"; done
grep -q "$spi" "$BOOT/config.txt" || echo "$spi" >> "$BOOT/config.txt"
grep -q "^dtoverlay=piscreen" "$BOOT/config.txt" || echo "$tft" >> "$BOOT/config.txt"
sed -Ei 's/fbcon=map:[0-9]//g' "$BOOT/cmdline.txt"
sed -i  "s/$/ $map/"            "$BOOT/cmdline.txt"

sed -Ei 's/^FONTFACE=.*/FONTFACE="Fixed"/' /etc/default/console-setup
sed -Ei 's/^FONTSIZE=.*/FONTSIZE="16x8"/'  /etc/default/console-setup
update-initramfs -u -k all

mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER_TARGET --noclear %I \$TERM
EOF
systemctl daemon-reload
systemctl restart getty@tty1.service

echo "✓  SPI, overlay, font, and autologin configured for $USER_TARGET."
echo "→  Reboot, then run status_install_autostart.sh as $USER_TARGET."
