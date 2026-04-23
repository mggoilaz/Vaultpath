#!/usr/bin/env bash
source "$(dirname "$0")/../.env" 2>/dev/null || true
IN_LAN=false
command -v ip &>/dev/null && ip route 2>/dev/null | grep -q "192.168" && IN_LAN=true
command -v netstat &>/dev/null && netstat -rn 2>/dev/null | grep -q "192.168" && IN_LAN=true
if $IN_LAN && [ -n "$SERVER_LAN_IP" ] && [[ "$SERVER_LAN_IP" != *"YOUR"* ]]; then
    export NETWORK="lan"; export TARGET_IP="$SERVER_LAN_IP"
    echo "Network: LAN → $SERVER_LAN_IP"
else
    export NETWORK="remote"; export TARGET_IP="${SERVER_TS_IP:-}"
    echo "Network: Tailscale → ${SERVER_TS_IP:-}"
fi
