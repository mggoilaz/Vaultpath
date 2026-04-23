#!/usr/bin/env bash
TARGET_IP="${1:-}"; PORT="${2:-22}"
[ -z "$TARGET_IP" ] && echo "Usage: test-port.sh IP PORT" && exit 1
echo "Testing $TARGET_IP:$PORT..."
if command -v nc &>/dev/null; then
    nc -zw3 "$TARGET_IP" "$PORT" 2>/dev/null
else
    (echo >/dev/tcp/"$TARGET_IP"/"$PORT") 2>/dev/null
fi
[ $? -eq 0 ] && echo "Port $PORT open ✓" && exit 0
echo "Port $PORT closed ✗ — check server, Tailscale and firewall"
exit 1
