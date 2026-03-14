#!/bin/bash
# Check if Caps Lock is ON
if [ "$(brightnessctl --device='input*::capslock' get)" -eq 1 ]; then
    notify-send -u critical -i keyboard "CAPS LOCK IS ON" "Watch your password!"
fi
