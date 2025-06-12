#!/bin/bash

set -e

if [ "$EUID" -eq 0 ]; then
    echo "[X] Этот установщик нельзя запускать от root или через sudo!"
    echo "    Пожалуйста, запусти скрипт обычным пользователем:"
    echo "    bash ./install-zpsr.sh"
    exit 1
fi

INSTALL_DIR="$HOME/.zpsr-lang"
FILES=("zpsr" "zpsr.cmd" "zpsr.py" "zpsr-build" "zpsr-build.cmd" "zpsr-build.py" "zpsr-install.bat")

echo "[*] Установка ZPSR в $INSTALL_DIR..."

mkdir -p "$INSTALL_DIR"

echo "[*] Копирование файлов..."
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        cp "$file" "$INSTALL_DIR/"
        echo "[+] $file скопирован"
    else
        echo "[!] $file не найден, пропущен"
    fi
done

echo "[*] Установка прав на выполнение..."
chmod +x "$INSTALL_DIR/zpsr" "$INSTALL_DIR/zpsr-build" "$INSTALL_DIR/zpsr.py" "$INSTALL_DIR/zpsr-build.py" 2>/dev/null || true

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "[*] Добавление $INSTALL_DIR в PATH..."
    SHELL_RC="$HOME/.bashrc"
    if [ -n "$ZSH_VERSION" ]; then SHELL_RC="$HOME/.zshrc"; fi
    if [ -z "$SHELL_RC" ]; then SHELL_RC="$HOME/.profile"; fi

    if ! grep -qF "$INSTALL_DIR" "$SHELL_RC"; then
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_RC"
        echo "[+] Путь добавлен в $SHELL_RC"
    fi

    echo "[!] Выполни: source $SHELL_RC или перезапусти терминал"
else
    echo "[*] Путь уже есть в \$PATH"
fi

echo "[*] Установка зависимостей Python..."

PIP_CMD="pip3"
PYTHON_CMD="python3"

if ! command -v "$PIP_CMD" &>/dev/null; then
    echo "[!] pip3 не найден. Пытаюсь установить..."

    if command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y python3-pip
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y python3-pip
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm python-pip
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y python3-pip
    else
        echo "[X] Неизвестный пакетный менеджер. Установи pip вручную."
        exit 1
    fi
fi

if [ -f "requirements.txt" ]; then
    "$PIP_CMD" install --user --break-system-packages -r requirements.txt || \
    "$PIP_CMD" install --user -r requirements.txt
else
    echo "[!] Файл requirements.txt не найден, зависимости не установлены."
fi

echo "[✔] Установка завершена. Проверь 'zpsr' и 'zpsr-build' в терминале!"
ll
