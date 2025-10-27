#!/bin/bash
# ~/.config/polybar/scripts/powermenu.sh

# Иконки (Nerd Font)
shutdown=" Выключение"
reboot=" Перезагрузка"
lock=" Блокировка"
logout=" Выход"

# Опции
options="$shutdown\n$reboot\n$lock\n$logout"

# Rofi
selected=$(echo -e "$options" | rofi -dmenu -p "Система" -i -theme-str 'window {width: 20%;}')

# Выполнение
case "$selected" in
    "$shutdown")
        systemctl poweroff
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$lock")
        # [!] Замени 'betterlockscreen -l' на свою команду блокировки
        betterlockscreen -l
        ;;
    "$logout")
        # [!] Замени на команду выхода из твоего WM
        # i3:     i3-msg exit
        # bspwm:  bspc quit
        bspc exit
        ;;
esac
