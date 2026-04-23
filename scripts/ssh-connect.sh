#!/usr/bin/env bash
source "$(dirname "$0")/../.env" 2>/dev/null || true
source "$(dirname "$0")/detect-os.sh"
source "$(dirname "$0")/check-network.sh" > /dev/null 2>&1

USER="${1:-${SERVER_USER:-}}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/vaultpath_id_ed25519}"
MAX_RETRIES=3

[ -z "$USER" ] && read -p "Username: " USER

echo "=== Vaultpath SSH ==="
echo "User: $USER | System: $OS_NAME | Target: $TARGET_IP"

[ "$NETWORK" = "remote" ] && bash "$(dirname "$0")/check-vpn.sh" || true
bash "$(dirname "$0")/test-port.sh" "$TARGET_IP" 22 || exit 1

SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new"
[ -f "$SSH_KEY" ] && SSH_OPTS="$SSH_OPTS -i $SSH_KEY" || echo "No SSH key — password required"

echo "Connecting to $USER@$TARGET_IP..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ATTEMPT=0
while [ $ATTEMPT -lt $MAX_RETRIES ]; do
    ATTEMPT=$((ATTEMPT+1))
    ssh $SSH_OPTS "$USER@$TARGET_IP"
    [ $? -eq 0 ] && echo "Session closed." && exit 0
    [ $ATTEMPT -lt $MAX_RETRIES ] && echo "Attempt $ATTEMPT failed. Retrying..." && sleep 3
done
echo "3 consecutive failures. Please check manually."
exit 1
