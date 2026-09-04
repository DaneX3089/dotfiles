#!/usr/bin/env bash

# Find main battery path
BAT_PATH=$(sysfs_path=$(echo /sys/class/power_supply/BAT* | awk '{print $1}'); echo "$sysfs_path")

if [ ! -d "$BAT_PATH" ]; then
    echo '{"text": "N/A", "class": "missing"}'
    exit 0
fi

# Get energy/charge values
NOW=$(cat "$BAT_PATH"/energy_now 2>/dev/null || cat "$BAT_PATH"/charge_now 2>/dev/null)
FULL=$(cat "$BAT_PATH"/energy_full 2>/dev/null || cat "$BAT_PATH"/charge_full 2>/dev/null)
POWER=$(cat "$BAT_PATH"/power_now 2>/dev/null || cat "$BAT_PATH"/current_now 2>/dev/null)
STATUS=$(cat "$BAT_PATH"/status 2>/dev/null)

if [ -z "$NOW" ] || [ -z "$FULL" ] || [ "$FULL" -eq 0 ]; then
    echo '{"text": "N/A"}'
    exit 0
fi

# Calculate decimal percentage
PERCENT=$(awk -v now="$NOW" -v full="$FULL" 'BEGIN { printf "%.2f", (now/full)*100 }')
INT_PERCENT=${PERCENT%.*}

# Determine icon based on capacity brackets
ICONS=(" " " " " " " " " ")
if [ "$INT_PERCENT" -ge 90 ]; then ICON="${ICONS[4]}"
elif [ "$INT_PERCENT" -ge 60 ]; then ICON="${ICONS[3]}"
elif [ "$INT_PERCENT" -ge 30 ]; then ICON="${ICONS[2]}"
elif [ "$INT_PERCENT" -ge 10 ]; then ICON="${ICONS[1]}"
else ICON="${ICONS[0]}"; fi

# Calculate time remaining
TIME_STR="N/A"
if [ -n "$POWER" ] && [ "$POWER" -gt 0 ]; then
    if [ "$STATUS" = "Discharging" ]; then
        TIME_STR=$(awk -v now="$NOW" -v pwr="$POWER" 'BEGIN { h=now/pwr; printf "%dh %02dm", int(h), int((h-int(h))*60) }')
    elif [ "$STATUS" = "Charging" ]; then
        TIME_STR=$(awk -v now="$NOW" -v full="$FULL" -v pwr="$POWER" 'BEGIN { h=(full-now)/pwr; printf "%dh %02dm until full", int(h), int((h-int(h))*60) }')
    fi
elif [ "$STATUS" = "Full" ]; then
    TIME_STR="Full"
fi

# Primary view string
if [ "$STATUS" = "Charging" ]; then
    TEXT="${PERCENT}% 󰂄"
else
    TEXT="${PERCENT}% ${ICON}"
fi

# Alternative view string (shown on click)
if [ "$STATUS" = "Charging" ]; then
    ALT_TEXT="${TIME_STR} 󰂄"
else
    ALT_TEXT="${TIME_STR} ${ICON}"
fi

# Set state class for CSS styling / warnings
CLASS="normal"
if [ "$INT_PERCENT" -le 10 ]; then CLASS="critical"
elif [ "$INT_PERCENT" -le 25 ]; then CLASS="warning"
fi

# Output JSON with both main text and alt text
printf '{"text": "%s", "alt": "%s", "class": "%s"}\n' "$TEXT" "$ALT_TEXT" "$CLASS"
