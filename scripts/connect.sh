#!/usr/bin/env bash
source "$(dirname "$0")/../.env" 2>/dev/null || true
source "$(dirname "$0")/detect-os.sh"

DEFAULT_USER="${SERVER_USER:-}"

echo ""
echo "╔══════════════════════════════╗"
echo "║        VAULTPATH 🔑          ║"
echo "║      Server connection       ║"
echo "╚══════════════════════════════╝"
echo "System: $OS_NAME"
echo ""

if [ -n "$DEFAULT_USER" ] && [[ "$DEFAULT_USER" != *"YOUR"* ]]; then
    echo "Connect as: $DEFAULT_USER"
    read -p "Use this user? [Y/n]: " CONFIRM
    [[ "$CONFIRM" == "n" || "$CONFIRM" == "N" ]] && read -p "Username: " USER || USER="$DEFAULT_USER"
else
    read -p "Enter your username: " USER
fi

bash "$(dirname "$0")/ssh-connect.sh" "$USER"
