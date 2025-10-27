#!/bin/bash

# --- НАСТРОЙКИ ---
# Цвета для вывода
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
NC="\033[0m" # No Color

# Путь к этому скрипту и его папке
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# Имена файлов с пакетами
PACMAN_PKGS="pkglist.txt"
AUR_PKGS="aurlist.txt"

# --- НАСТРОЙКИ СИМЛИНКОВ (Имена папок в репозитории) ---
# Вам больше не нужно редактировать массивы!
# Просто добавляйте файлы в эти папки.

# 1. Папка для конфигов в $HOME/.config
# (например, ~/dotfiles/config/bspwm -> ~/.config/bspwm)
CONFIG_DIR_NAME="config"

# 2. Папка для конфигов в $HOME
# (например, ~/dotfiles/home/.zshrc -> ~/.zshrc)
HOME_DIR_NAME="home"

# 3. Папка для системных конфигов (управляется отдельной командой)
# (например, ~/dotfiles/system/etc/vconsole.conf -> /etc/vconsole.conf)
SYSTEM_DIR_NAME="system"


# --- ХЕЛПЕРЫ ---
msg() {
    echo -e "${GREEN}[INFO]${NC} $1"
}
warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}
err() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# --- ФУНКЦИИ ---

# 1. Установка YAY (AUR Helper)
# ... (без изменений) ...
install_yay() {
    if ! command -v yay &>/dev/null; then
        msg "YAY не найден. Установка YAY..."
        # Проверяем наличие git и base-devel перед установкой yay
        if ! pacman -Q git &>/dev/null || ! pacman -Q base-devel &>/dev/null; then
             sudo pacman -S --needed --noconfirm git base-devel
        fi
        
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
        rm -rf /tmp/yay
        msg "YAY установлен."
    else
        msg "YAY уже установлен."
    fi
}

# 2. Установка пакетов (Pacman и YAY)
# ... (без изменений) ...
install_packages() {
    msg "Установка пакетов из Pacman ($PACMAN_PKGS)..."
    # Читаем файл, убираем inline-комментарии (после #),
    # убираем пустые строки, xargs очищает лишние пробелы
    # и передает все как отдельные аргументы в pacman.
    local pacman_args=$(sed 's/#.*//' "$SCRIPT_DIR/$PACMAN_PKGS" | grep -vE '^\s*$' | xargs)

    if [[ ! -z "$pacman_args" ]]; then
        sudo pacman -S --needed --noconfirm $pacman_args
    else
        msg "Список Pacman пуст, пропуск."
    fi
    
    msg "Проверка и установка YAY..."
    install_yay
    
    msg "Установка пакетов из AUR ($AUR_PKGS)..."
    # Аналогично для YAY
    local aur_args=$(sed 's/#.*//' "$SCRIPT_DIR/$AUR_PKGS" | grep -vE '^\s*$' | xargs)
    
    if [[ ! -z "$aur_args" ]]; then
        yay -S --needed --noconfirm $aur_args
    else
        msg "Список AUR пуст, пропуск."
    fi
    
    msg "Установка пакетов завершена."
}

# 3. Создание символических ссылок (ОБНОВЛЕНО)
link_dotfiles() {
    msg "Создание символических ссылок (симлинков)..."
    
    local source_dir=""
    local target_dir=""

    # --- 1. Линкуем файлы в $HOME (из папки 'home') ---
    msg "  -> Линковка в $HOME (из '$HOME_DIR_NAME')"
    source_dir="$SCRIPT_DIR/$HOME_DIR_NAME"
    target_dir="$HOME"
    
    if [ -d "$source_dir" ]; then
        # Ищем все файлы и папки на первом уровне в 'home/'
        # -mindepth 1 (чтобы не найти саму папку 'home')
        # -maxdepth 1 (чтобы найти '.zshrc', 'bin', но не 'bin/скрипт')
        for item_path in $(find "$source_dir" -mindepth 1 -maxdepth 1); do
            local item_name=$(basename "$item_path")
            local source_path="$item_path"
            local target_path="$target_dir/$item_name"
            
            # Бэкапим, если в $HOME уже что-то есть (и это не симлинк)
            if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
                warn "Файл/папка '$target_path' уже существует. Бэкап в '$target_path.bak'..."
                mv "$target_path" "$target_path.bak"
            fi
            
            ln -sfn "$source_path" "$target_path"
            msg "    -> $target_path -> $source_path"
        done
    else
        warn "Папка '$source_dir' не найдена. Пропуск $HOME линков."
    fi

    # --- 2. Линкуем файлы в $HOME/.config (из папки 'config') ---
    msg "  -> Линковка в $HOME/.config (из '$CONFIG_DIR_NAME')"
    source_dir="$SCRIPT_DIR/$CONFIG_DIR_NAME"
    target_dir="$HOME/.config"
    
    # Создаем ~/.config, если его нет (на новой системе)
    mkdir -p "$target_dir"
    
    if [ -d "$source_dir" ]; then
        # Аналогичная логика для папки 'config'
        for item_path in $(find "$source_dir" -mindepth 1 -maxdepth 1); do
            local item_name=$(basename "$item_path")
            local source_path="$item_path"
            local target_path="$target_dir/$item_name"
            
            # Бэкапим, если в ~/.config уже есть такой конфиг (и это не симлинк)
            if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
                warn "Файл/папка '$target_path' уже существует. Бэкап в '$target_path.bak'..."
                mv "$target_path" "$target_path.bak"
            fi
            
            ln -sfn "$source_path" "$target_path"
            msg "    -> $target_path -> $source_path"
        done
    else
        warn "Папка '$source_dir' не найдена. Пропуск $HOME/.config линков."
    fi
    
    msg "Симлинки созданы."
}

# 4. Проверка текущей конфигурации (ОБНОВЛЕНО)
check_config() {
    # ... (проверка пакетов остается без изменений) ...
    msg "Проверка установленных пакетов Pacman..."
    local missing_pacman=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        local pkg=$(echo "$line" | sed 's/#.*//' | xargs)
        if [[ -z "$pkg" ]]; then continue; fi
        if ! pacman -Q "$pkg" &>/dev/null; then
            warn "  -> Не найден (Pacman): $pkg"
            missing_pacman=1
        fi
    done < "$SCRIPT_DIR/$PACMAN_PKGS"
    if [ $missing_pacman -eq 0 ]; then msg "Все пакеты Pacman установлены."; fi

    msg "Проверка установленных пакетов AUR..."
    local missing_aur=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        local pkg=$(echo "$line" | sed 's/#.*//' | xargs)
        if [[ -z "$pkg" ]]; then continue; fi
        if ! pacman -Q "$pkg" &>/dev/null; then
            warn "  -> Не найден (AUR): $pkg"
            missing_aur=1
        fi
    done < "$SCRIPT_DIR/$AUR_PKGS"
    if [ $missing_aur -eq 0 ]; then msg "Все пакеты AUR установлены."; fi
    
    
    msg "Проверка симлинков..."
    
    # --- 1. Проверка $HOME (из папки 'home') ---
    local source_dir="$SCRIPT_DIR/$HOME_DIR_NAME"
    if [ -d "$source_dir" ]; then
        for item_path in $(find "$source_dir" -mindepth 1 -maxdepth 1); do
            local item_name=$(basename "$item_path")
            if [ ! -L "$HOME/$item_name" ]; then
                warn "  -> Симлинк не найден: $HOME/$item_name"
            fi
        done
    fi
    
    # --- 2. Проверка $HOME/.config (из папки 'config') ---
    source_dir="$SCRIPT_DIR/$CONFIG_DIR_NAME"
    if [ -d "$source_dir" ]; then
        for item_path in $(find "$source_dir" -mindepth 1 -maxdepth 1); do
            local item_name=$(basename "$item_path")
            if [ ! -L "$HOME/.config/$item_name" ]; then
                warn "  -> Симлинк не найден: $HOME/.config/$item_name"
            fi
        done
    fi
    
    msg "Проверка завершена."
}

# 5. (Бонус) Проверка драйверов
# ... (без изменений) ...
check_drivers() {
    msg "Проверка оборудования и рекомендации по драйверам..."
    warn "Это только рекомендации! Не устанавливайте автоматически."
    
    # Видеокарта
    local vga=$(lspci -k | grep -A 2 -E "(VGA|3D)")
    
    if echo "$vga" | grep -iq "NVIDIA"; then
        warn "Найдена карта NVIDIA. Рекомендуемые пакеты:"
        warn "  -> nvidia (или nvidia-lts, nvidia-dkms)"
        warn "  -> lib32-nvidia-utils (для 32-bit)"
        
    elif echo "$vga" | grep -iq "Intel"; then
        msg "Найдена карта Intel. Рекомендуемые пакеты (обычно уже в списке):"
        msg "  -> mesa, lib32-mesa, vulkan-intel"
        if ! pacman -Q xf86-video-intel &>/dev/null; then
             warn "  -> xf86-video-intel (старый 2D драйвер, может быть не нужен)"
        fi
        
    elif echo "$vga" | grep -iq "AMD"; then
        msg "Найдена карта AMD/ATI. Рекомендуемые пакеты (обычно уже в списке):"
        msg "  -> mesa, lib32-mesa, vulkan-radeon"
    fi
    
    # Wi-Fi / Bluetooth
    if lspci -k | grep -iq "broadcom"; then
        warn "Найден чип Broadcom. Вам может понадобиться:"
        warn "  -> broadcom-wl-dkms (для Wi-Fi)"
    fi
    
    msg "Проверка драйверов завершена."
}

# 6. (НОВАЯ ФУНКЦИЯ) Интерактивная установка системных конфигов
apply_system_configs() {
    msg "--- РЕЖИМ: ПРИМЕНЕНИЕ СИСТЕМНЫХ КОНФИГОВ ---"
    local system_source_dir="$SCRIPT_DIR/$SYSTEM_DIR_NAME"
    
    if [ ! -d "$system_source_dir" ]; then
        err "Папка '$system_source_dir' не найдена. Создайте ее и поместите туда конфиги."
        return 1
    fi
    
    # Ищем все *файлы* внутри папки 'system'
    find "$system_source_dir" -type f | while read -r source_file; do
        # Получаем относительный путь (например, "etc/vconsole.conf")
        local rel_path=${source_file#$system_source_dir/}
        # Получаем абсолютный целевой путь (например, "/etc/vconsole.conf")
        local target_file="/$rel_path"
        
        msg "Найден конфиг: $rel_path"
        
        # 1. Проверяем, существует ли оригинал
        if [ ! -f "$target_file" ]; then
            warn "Файл '$target_file' не существует. Хотите скопировать новый?"
            read -p "  [y/N] (Да/Нет): " choice < /dev/tty
            if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
                # Создаем дирректорию, если нужно
                sudo mkdir -p "$(dirname "$target_file")"
                sudo cp "$source_file" "$target_file"
                msg "  -> СКОПИРОВАНО: $target_file"
            else
                msg "  -> Пропущено."
            fi
            continue # Переходим к следующему файлу
        fi
        
        # 2. Оригинал существует, показываем diff
        if command -v diff &>/dev/null; then
            msg "Разница между вашим конфигом (dotfiles) и системным (/) :"
            # diff [оригинал] [новый]
            diff -u "$target_file" "$source_file" || true # || true чтобы скрипт не падал, если есть разница
        else
            warn "Команда 'diff' не найдена. Не могу показать разницу."
        fi
        
        # 3. Запрос на замену
        warn "Заменить системный файл '$target_file'?"
        read -p "  [y/N/b] (Да / Нет / Бэкап и замена): " choice < /dev/tty
        
        case "$choice" in
            y|Y)
                sudo cp "$source_file" "$target_file"
                msg "  -> ЗАМЕНЕНО: $target_file"
                ;;
            b|B)
                sudo mv "$target_file" "$target_file.bak"
                sudo cp "$source_file" "$target_file"
                msg "  -> БЭКАП СОЗДАН: $target_file.bak"
                msg "  -> ЗАМЕНЕНО: $target_file"
                ;;
            *)
                msg "  -> Пропущено."
                ;;
        esac
    done
    
    msg "--- СИСТЕМНЫЕ КОНФИГИ ОБРАБОТАНЫ ---"
}

# 7. (НОВАЯ ФУНКЦИЯ) Создание стандартных папок пользователя
create_user_dirs() {
    msg "Проверка и создание стандартных папок пользователя (Downloads, Desktop...)"
    
    if command -v xdg-user-dirs-update &>/dev/null; then
        msg "  -> Найден xdg-user-dirs-update. Запускаем..."
        xdg-user-dirs-update
        msg "  -> XDG папки обновлены."
    else
        warn "  -> 'xdg-user-dirs-update' не найден."
        warn "  -> (Рекомендуется: добавьте 'xdg-user-dirs' в pkglist.txt для корректной локализации)"
        msg "  -> Создаем базовые папки вручную (на английском)..."
        
        # Создаем стандартный набор
        mkdir -p \
            "$HOME/Desktop" \
            "$HOME/Documents" \
            "$HOME/Downloads" \
            "$HOME/Music" \
            "$HOME/Pictures" \
            "$HOME/Public" \
            "$HOME/Templates" \
            "$HOME/Videos"
        
        msg "  -> Базовые папки созданы."
    fi
}


# --- ГЛАВНЫЙ БЛОК (ВЫБОР РЕЖИМА) ---

show_help() {
    echo "Скрипт управления конфигурацией Arch Linux (Dotfiles)"
    echo "Использование: $0 [команда]"
    echo
    echo "Команды:"
    echo "  install   - Установить все пакеты и создать симлинки (полная установка)."
    echo "  check     - Проверить, все ли установлено и настроено."
    echo "  update    - Обновить конфиг из Git и применить изменения (пакеты, симлинки)."
    echo "  drivers   - (Бонус) Проверить оборудование и предложить драйверы."
    echo "  system    - (НОВОЕ) Интерактивно применить системные конфиги из папки '$SYSTEM_DIR_NAME'."
    echo "  help      - Показать это сообщение."
}

# Проверяем, что скрипт не запущен от root
if [ "$EUID" -eq 0 ]; then
  err "Не запускайте этот скрипт от имени root (используйте 'sudo' только когда он сам попросит)."
  exit 1
fi

# Если нет аргументов, показать помощь
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

case "$1" in
    install)
        msg "--- РЕЖИМ: ПОЛНАЯ УСТАНОВКА ---"
        install_packages
        link_dotfiles
        create_user_dirs # <-- ДОБАВЛЕНО
        msg "--- УСТАНОВКА ЗАВЕРШЕНА ---"
        msg "Для применения системных конфигов (vconsole.conf и т.д.) запустите: $0 system"
        ;;
    check)
        msg "--- РЕЖИМ: ПРОВЕРКА КОНФИГУРАЦИИ ---"
        check_config
        ;;
    update)
        msg "--- РЕЖИМ: ОБНОВЛЕНИЕ КОНФИГУРАЦИИ ---"
        msg "1. Получение изменений из Git (git pull)..."
        if ! git pull; then
            err "Не удалось выполнить 'git pull'. Проверьте подключение и статус репозитория."
            exit 1
        fi
        msg "2. Применение изменений (установка/линковка)..."
        install_packages
        link_dotfiles
        create_user_dirs # <-- ДОБАВЛЕНО
        msg "--- ОБНОВЛЕНИЕ ЗАВЕРШЕНО ---"
        ;;
    drivers)
        msg "--- РЕЖИМ: ПРОВЕРКА ДРАЙВЕРОВ ---"
        check_drivers
        ;;
    system)
        # (НОВЫЙ РЕЖИМ)
        apply_system_configs
        ;;
    help|*)
        show_help
        ;;
esac
