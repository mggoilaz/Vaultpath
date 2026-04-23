#!/usr/bin/env bash
source "$(dirname "$0")/../.env" 2>/dev/null || true
TS_IP="${SERVER_TS_IP:-}"
echo "=== Vaultpath VPN Check ==="
if ! command -v tailscale &>/dev/null; then
    echo "STATUS: not_installed — https://tailscale.com/download"; exit 1
fi
TS_STATUS=$(tailscale status 2>&1)
if echo "$TS_STATUS" | grep -q "Logged out\|not running"; then
    echo "STATUS: disconnected — run: tailscale up"; exit 1
fi
echo "STATUS: connected ✓"
if echo "$TS_STATUS" | grep -q "$TS_IP"; then
    echo "Server visible in tailnet ✓"
else
    echo "Server NOT visible — wrong tailnet?"
    echo "See templates/fix-tailscale.md"; exit 1
fi
