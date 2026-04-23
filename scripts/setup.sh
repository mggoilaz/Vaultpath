#!/usr/bin/env bash
# setup.sh — First-time setup
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/detect-os.sh"
source "$SCRIPT_DIR/../.env" 2>/dev/null || true

echo ""
echo "╔══════════════════════════════════╗"
echo "║        VAULTPATH 🔑              ║"
echo "║        Team setup                ║"
echo "╚══════════════════════════════════╝"
echo "System: $OS_NAME"
echo ""

# Usuario
if [ -n "$SERVER_USER" ] && [[ "$SERVER_USER" != *"YOUR"* ]]; then
    echo "User from .env: $SERVER_USER"
    read -p "Use this? [Y/n]: " C
    [[ "$C" == "n" || "$C" == "N" ]] && read -p "Enter username: " SERVER_USER
else
    read -p "Enter your server username: " SERVER_USER
fi
echo "User: $SERVER_USER ✓"

# .env
ENV_FILE="$SCRIPT_DIR/../.env"
[ ! -f "$ENV_FILE" ] && cp "$SCRIPT_DIR/../.env.example" "$ENV_FILE"
sed -i "s/SERVER_USER=.*/SERVER_USER=$SERVER_USER/" "$ENV_FILE" 2>/dev/null || \
sed -i '' "s/SERVER_USER=.*/SERVER_USER=$SERVER_USER/" "$ENV_FILE"
echo ".env updated ✓"

# Clave SSH
KEY_PATH="$HOME/.ssh/vaultpath_id_ed25519"
if [ ! -f "$KEY_PATH" ]; then
    echo ""
    echo "Generating SSH key..."
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -f "$KEY_PATH" -N "" -C "vaultpath-$SERVER_USER"
    echo "Key generated ✓"
else
    echo "SSH key exists ✓"
fi

# Copiar clave al servidor
source "$SCRIPT_DIR/../.env" 2>/dev/null || true
TARGET_IP="${SERVER_TS_IP:-${SERVER_LAN_IP:-}}"

if [ -z "$TARGET_IP" ] || [[ "$TARGET_IP" == *"YOUR"* ]]; then
    echo ""
    echo "⚠ Fill SERVER_TS_IP or SERVER_LAN_IP in .env, then run:"
    echo "  ssh-copy-id -i $KEY_PATH.pub $SERVER_USER@YOUR_SERVER_IP"
else
    echo ""
    echo "Copying key to server (asks password once)..."
    if command -v ssh-copy-id &>/dev/null; then
        ssh-copy-id -i "$KEY_PATH.pub" "$SERVER_USER@$TARGET_IP"
    else
        cat "$KEY_PATH.pub" | ssh "$SERVER_USER@$TARGET_IP" \
            "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    fi
    [ $? -eq 0 ] && echo "✓ Key copied" || echo "Could not copy now — try when connected to network"
fi

# Montar unidad
echo ""
read -p "Mount network drive now? [y/N]: " MONTAR
if [[ "$MONTAR" == "y" || "$MONTAR" == "Y" ]]; then
    case "$OS_TYPE" in
        windows) powershell -ExecutionPolicy Bypass -File "$SCRIPT_DIR/mount-windows.ps1" ;;
        linux|mac) bash "$SCRIPT_DIR/mount-unix.sh" ;;
    esac
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Setup complete — $SERVER_USER"
echo "To connect: bash scripts/connect.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
