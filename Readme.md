Мои Dotfiles (Arch Linux + bspwm)

Это моя персональная конфигурация для Arch Linux.

Основное окружение построено на bspwm (менеджер окон) и sxhkd (горячие клавиши).

Что внутри

WM: bspwm, sxhkd

Панель: polybar

Лаунчер: rofi

Композитор: picom

Терминал: alacritty

Уведомления: dunst

Списки пакетов для Pacman (pkglist.txt) и AUR (aurlist.txt).

Скрипт install.sh для автоматического управления всем этим.

Быстрая установка

Этот репозиторий предназначен для развертывания на "чистой" системе Arch Linux.

ВАЖНО: Раскомментируйте [multilib] в /etc/pacman.conf и выполните sudo pacman -Syu.

Установите git:

sudo pacman -S git


Клонируйте репозиторий:

# Замените [URL] на URL вашего git-репозитория
git clone https://github.com/te4gh0st/dotfiles ~/dotfiles


Перейдите в папку и запустите установку:

cd ~/dotfiles
chmod +x install.sh
./install.sh install


(Опционально) Примените системные настройки (например, locale.conf, vconsole.conf):

./install.sh system


Управление

Скрипт install.sh используется для всего управления:

./install.sh install: Полная установка (пакеты, симлинки, папки XDG).

./install.sh update: Обновление из Git (git pull) + применение изменений.

./install.sh check: Проверка, все ли установлено и на своих местах.

./install.sh system: Интерактивная установка системных файлов (из папки system/).

./install.sh drivers: Проверка оборудования и рекомендации по драйверам.
