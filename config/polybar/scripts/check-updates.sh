#!/bin/bash
# ~/.config/polybar/scripts/check-updates.sh

# Иконка
icon=""

if ! command -v checkupdates &> /dev/null; then
    echo "$icon (ошибка)"
    exit
fi

updates=$(checkupdates 2>/dev/null | wc -l)

if [ "$updates" -gt 0 ]; then
    echo "$icon $updates" # Показать иконку и кол-во
else
    echo "$icon 0" # Показать иконку и 0
fi
