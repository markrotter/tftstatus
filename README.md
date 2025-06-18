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

## Installation
```bash
# Clone repository
cd ~
git clone git@github.com:markrotter/tftstatus.git
cd tftstatus
./status_setup_drivers.sh $USER   # requires sudo           This is to set up the display drivers etc
./install_speed_cli.sh            # optional                Installs Ookla Speedtest
./status_install_autostart.sh                               Sets up status.sh so it autostarts on systemd
