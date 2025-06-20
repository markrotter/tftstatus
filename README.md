# Raspberry Pi Network TFT Dashboard

## Overview
This project turns a Raspberry Pi into a network status dashboard with a small TFT display. It shows real-time system and network information on the screen, making a handy status monitor. The dashboard can auto-start on boot and is ideal for monitoring network speed, IP addresses, and system resource usage at a glance.

## Caveats
This is a work in progress, this project was developed to learn coding using AI models such as ChatGPT. The Raspberry Pi 3B+ does not have fast enough networking so the speedtest functionlity is not super helpful. The display hardware used has been chellenging to use with RPi 4 and up.

## Features
- **Network Speed Monitor:** Displays current upload/download throughput and runs periodic internet speed tests (using Speedtest CLI).
- **System Stats:** Shows CPU load, memory usage, disk space, and uptime on the TFT display.
- **IP and Connectivity:** Shows the Pi’s IP address (useful for headless setups) and network connectivity status.
- **Auto-start on Boot:** Includes a script to install the dashboard as a service that launches on startup.
- **Easy Setup:** Automated install scripts for required drivers (TFT screen) and dependencies (e.g., speed test utility).

## Hardware Requirements
- **Raspberry Pi:** Any model with 40-pin header (tested on Raspberry Pi 3B/4 running Raspberry Pi OS).
- **TFT Display:** 3.5-inch 320x480 TFT touchscreen (e.g., Adafruit PiTFT) connected to the Pi’s GPIO/SPi.
- **Internet Connection:** Ethernet or Wi-Fi for network stats and speed tests.
- **MicroSD Card:** With Raspberry Pi OS installed.
- *(Optional)* **Case/Mount:** A case or stand to mount the Pi and display.

## Quick install — Raspberry Pi OS 64-bit

Follow the steps below; each code block can be copied directly into your terminal.

### 0 — Update & install Git
```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y git
```

### 1 — Clone the repository
```bash
cd ~
git clone git@github.com:<GITHUB-USER>/tftstatus.git
cd tftstatus
```
*Use the HTTPS URL if you prefer PAT authentication.*
### 2 — Make scripts executable
```bash
chmod +x *.sh
```
### 3 — Install TFT drivers & console tweaks
```bash
sudo ./status_setup_drivers.sh <USER>
```
### 4 — (Optional) Install speed‑test CLIs
```bash
sudo ./install_speed_cli.sh
```
### 5 — Enable the dashboard service
```bash
./status_install_autostart.sh
```
### 6 — Reboot once
```bash
sudo reboot
```

### 7 — Pull updates later
```bash
cd ~/tftstatus
git pull --rebase
systemctl --user restart tft-dashboard
```

After step 6 the TFT should show IP, ping, CPU temperature, and network speed in real time.  
For service logs: `journalctl --user -u tft-dashboard -f`.
