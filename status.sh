#!/usr/bin/env bash
###############################################################################
# status.sh – flicker-free 3½" TFT dashboard           Rev-9  (2025-06-11)
#
# • Works interactively *and* under systemd --user
# • Dynamic NIC list (IP / MAC), uptime, ping, time, CPU temp
# • Dual speed tests (Ookla & LibreSpeed) every 30 min  –- low-priority
# • Safe runtime file in $XDG_RUNTIME_DIR or /tmp
###############################################################################
set -euo pipefail

# Hide cursor; restore on exit
tput civis
trap 'tput cnorm; exit' INT TERM EXIT

WIDTH=$(tput cols)                         # 60 on 480×320 with 8×16 font

# ─────────── Helper: print line, clear to EOL, newline ──────────────────────
pad() {
  printf '%s' "$1"
  tput el
  printf '\n'
}

# ─────────── Runtime speed-result file (always writable) ────────────────────
export SPEED_FILE="${XDG_RUNTIME_DIR:-/tmp}/tft-speed.txt"
: >"$SPEED_FILE"

# ─────────── Background bandwidth thread (runs forever) ─────────────────────
(
  exec nice -n10 ionice -c3 bash -eu <<'EOF'
CYCLE=$((30*60))                    # 30-minute interval
while true; do
  : >"$SPEED_FILE"

  # Helper: try to pull key; fall back to 0
  get() { jq -r "$1 // 0" <<<"$json"; }

  ###########################################################################
  # Ookla CLI
  ###########################################################################
  if command -v speedtest >/dev/null; then
    json=$(speedtest --accept-license --accept-gdpr \
                     --format=json --progress=no 2>/dev/null || :)
    if [[ $json == \{* ]]; then
      dn=$(get '.download.bandwidth')
      up=$(get '.upload.bandwidth')
      # v1.2 fallback when bandwidth missing
      [[ $dn == 0 ]] && dn=$(awk 'BEGIN{print (b>0)?b*8/e:0}' \
                            b=$(get '.download.bytes') e=$(get '.download.elapsed'))
      [[ $up == 0 ]] && up=$(awk 'BEGIN{print (b>0)?b*8/e:0}' \
                            b=$(get '.upload.bytes')   e=$(get '.upload.elapsed'))
      ping=$(get '.ping.latency')
      if (( dn > 0 && up > 0 )); then
        printf "📡  Ookla  ↓%5.1fMb/s ↑%5.1fMb/s %4.1fms\n" \
               "$(awk "BEGIN{print $dn/1e6}")" \
               "$(awk "BEGIN{print $up/1e6}")" "$ping" >>"$SPEED_FILE"
      fi
    fi
  fi

  ###########################################################################
  # LibreSpeed CLI
  ###########################################################################
  if command -v librespeed-cli >/dev/null; then
    json=$(librespeed-cli --json 2>/dev/null || :)
    if [[ $json == \{* ]]; then
      dn=$(get '.download'); up=$(get '.upload'); ping=$(get '.ping')
      if (( dn > 0 && up > 0 )); then
        printf "📡  Libre  ↓%5.1fMb/s ↑%5.1fMb/s %4.1fms\n" \
               "$(awk "BEGIN{print $dn/1e6}")" \
               "$(awk "BEGIN{print $up/1e6}")" "$ping" >>"$SPEED_FILE"
      fi
    fi
  fi

  [[ -s $SPEED_FILE ]] || echo "📡  Install Ookla-CLI / LibreSpeed-CLI" >"$SPEED_FILE"
  sleep "$CYCLE"
done
EOF
) &

# ─────────── Helper: list NICs (UP + IPv4) ──────────────────────────────────
nic_lines() {
  ip -4 -o addr show up | awk '!/ lo /{print $2" "$4}' \
    | while read -r if ip; do
        mac=$(cat /sys/class/net/"$if"/address 2>/dev/null)
        ico=$([[ $if == wl* || $if == wlp* ]] && echo "📶" || echo "🌐")
        pad "$ico  $if: ${ip%%/*} / $mac"
      done
}

# ─────────── Main screen refresh loop (1 Hz) ────────────────────────────────
while true; do
  tput cup 0 0
  pad "💻  Host : $(hostname)"
  pad "⏱️   Uptime: $(uptime -p)"
  nic_lines

  if rtt=$(ping -q -c1 -W1 1.1.1.1 2>/dev/null | awk -F/ '/min/{print $5}'); then
    pad "🔗  Ping : 1.1.1.1 ${rtt} ms"
  elif rtt=$(ping -q -c1 -W1 8.8.8.8 2>/dev/null | awk -F/ '/min/{print $5}'); then
    pad "🔗  Ping : 8.8.8.8 ${rtt} ms"
  else
    pad "🔗  Ping : timeout"
  fi

  pad "🕒  Time : $(date '+%Y-%m-%d  %H:%M:%S')"
  command -v vcgencmd >/dev/null && pad "🌡️   Temp : $(vcgencmd measure_temp | cut -d= -f2)"

  while IFS= read -r ln; do pad "$ln"; done <"$SPEED_FILE"

  tput ed                               # clear rest of screen
  sleep 1
done
