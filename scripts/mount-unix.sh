#!/usr/bin/env bash
# mount-unix.sh — Montar unidad Samba en Linux y macOS
source "$(dirname "$0")/detect-os.sh"
source "$(dirname "$0")/../.env" 2>/dev/null || true

TS_IP="${SERVER_TS_IP:-}"
LAN_IP="${SERVER_LAN_IP:-}"

# Tabla del equipo
USERS=("raul"    "lumiora" "nexora" "waydra")
SHARES=("Datos"  "Lumiora" "nexora" "waydra")

echo ""
echo "╔══════════════════════════════════╗"
echo "║        VAULTPATH 🔑              ║"
echo "║     Mount network drive          ║"
echo "╚══════════════════════════════════╝"
echo "System: $OS_NAME"
echo ""
printf "  %-4s %-12s %-15s\n" "#" "User" "Share"
echo "  ─────────────────────────────────"
for i in "${!USERS[@]}"; do
    printf "  %d)   %-12s %-15s\n" "$((i+1))" "${USERS[$i]}" "${SHARES[$i]}"
done
echo ""
read -p "Choose [1-${#USERS[@]}]: " OPCION

IDX=$((OPCION-1))
if [ $IDX -lt 0 ] || [ $IDX -ge ${#USERS[@]} ]; then
    echo "Invalid option."; exit 1
fi

USER="${USERS[$IDX]}"
SHARE="${SHARES[$IDX]}"
MOUNT_DIR="/mnt/$USER"

echo ""
echo "User: $USER | Share: $SHARE"

# Detectar red
IN_LAN=false
ip route 2>/dev/null | grep -q "192.168" && IN_LAN=true
netstat -rn 2>/dev/null | grep -q "192.168" && IN_LAN=true

if $IN_LAN && [ -n "$LAN_IP" ] && [[ "$LAN_IP" != *"YOUR"* ]]; then
    TARGET_IP="$LAN_IP"
    echo "Network: LAN → $TARGET_IP"
else
    TARGET_IP="$TS_IP"
    echo "Network: Tailscale → $TARGET_IP"
fi

case "$OS_TYPE" in
    linux)
        read -s -p "Samba password for $USER: " PASS
        echo ""
        command -v mount.cifs &>/dev/null || sudo apt-get install -y cifs-utils 2>/dev/null
        sudo mkdir -p "$MOUNT_DIR"
        sudo mount -t cifs "//$TARGET_IP/$SHARE" "$MOUNT_DIR" \
            -o "username=$USER,password=$PASS,uid=$(id -u),gid=$(id -g),iocharset=utf8"
        [ $? -eq 0 ] && echo "✓ Mounted at $MOUNT_DIR" || echo "ERROR — check password and network"
        ;;
    mac)
        echo ""
        echo "Opening Terminal to mount drive..."
        echo "(Enter your password in the new Terminal window)"
        echo ""
        SCRIPT_CMD="echo ''; echo '=== VAULTPATH — Mount $SHARE ==='; echo ''; "
        SCRIPT_CMD+="read -s -p 'Samba password for $USER: ' PASS; echo ''; "
        SCRIPT_CMD+="sudo mkdir -p $MOUNT_DIR; "
        SCRIPT_CMD+="mount_smbfs \"//$USER:\$PASS@$TARGET_IP/$SHARE\" $MOUNT_DIR 2>/dev/null; "
        SCRIPT_CMD+="if [ \$? -eq 0 ]; then "
        SCRIPT_CMD+="  echo '✓ Mounted at $MOUNT_DIR'; "
        SCRIPT_CMD+="else "
        SCRIPT_CMD+="  echo 'Direct mount failed, opening Finder...'; "
        SCRIPT_CMD+="  open \"smb://$USER@$TARGET_IP/$SHARE\"; "
        SCRIPT_CMD+="fi; "
        SCRIPT_CMD+="echo ''; read -p 'Press Enter to close'"
        osascript -e "tell application \"Terminal\" to do script \"$SCRIPT_CMD\""
        osascript -e "tell application \"Terminal\" to activate"
        echo "Check Finder for mounted drive."
        ;;
esac
