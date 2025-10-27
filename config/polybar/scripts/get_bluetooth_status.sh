#!/bin/bash
# ~/.config/polybar/scripts/get_bluetooth_status.sh

# Цвета из конфига polybar (если хочешь)
COLOR_DISABLED="#665c54" # ${colors.disabled}
COLOR_DEFAULT="#ebdbb2"  # ${colors.foreground}

if [ $(bluetoothctl show | grep "Powered: yes" | wc -c) -eq 0 ]; then
  # Выключено
  echo "%{F$COLOR_DISABLED}%{F-}" # Иконка выкл
else
  # Включено
  if [ $(echo "info" | bluetoothctl | grep "Device" | wc -c) -eq 0 ]; then
    # Нет подключенных устройств
    echo "%{F$COLOR_DEFAULT}%{F-}" # Иконка вкл
  else
    # Есть подключенное устройство
    echo "%{F$COLOR_DEFAULT}%{F-}" # Показываем просто иконку, что есть коннект
    # Если хочешь имя устройства (может быть длинным):
    # device_name=$(echo "info" | bluetoothctl | grep "Name:" | cut -d ' ' -f 2-)
    # echo " $device_name"
  fi
fi
