#!/usr/bin/env bash
source "$(dirname "$0")/../.env" 2>/dev/null || true
source "$(dirname "$0")/detect-os.sh"
AUTH_KEY="${TAILSCALE_AUTH_KEY:-}"
[ -z "$AUTH_KEY" ] || [[ "$AUTH_KEY" == *"YOUR"* ]] && \
    echo "Add TAILSCALE_AUTH_KEY to .env — generate at login.tailscale.com → Settings → Auth keys" && exit 1
echo "=== Vaultpath VPN Connect ==="
case "$OS_TYPE" in
    linux|mac) tailscale up --auth-key="$AUTH_KEY" ;;
    windows) & "C:\Program Files\Tailscale\tailscale.exe" up --auth-key="$AUTH_KEY" ;;
esac
tailscale status 2>/dev/null | head -5
