#!/bin/bash

# Get the current volume
VOLUME=$(pamixer --get-volume)

# Check if muted
MUTED=$(pamixer --get-mute)

if [ "$MUTED" = "true" ]; then
    ICON=""
    VOLUME="Muted"
else
    ICON=""
fi

echo -n "{\"full_text\": \"$ICON $VOLUME%\", \"color\": \"#ffffff\"}"
