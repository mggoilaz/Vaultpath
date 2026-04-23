#!/usr/bin/env bash
# monitor.sh — Server status (run via SSH on the server)
echo "=== Vaultpath Server Monitor === $(date)"
echo ""
echo "=== RAM ==="
free -m | awk '/Mem:/{printf "Available: %dMB of %dMB\n", $7, $2}'
echo ""
echo "=== DISK ==="
df -h / | awk 'NR==2{printf "Root: %s used of %s (%s)\n", $3, $2, $5}'
df -h /srv/datos 2>/dev/null || true
echo ""
echo "=== LOAD ==="
uptime | awk -F'load average:' '{print "Load:" $2}'
echo ""
echo "=== ACTIVE SSH SESSIONS ==="
who
echo ""
echo "=== TAILSCALE ==="
tailscale status 2>/dev/null | head -5 || echo "Not available"
echo ""
echo "=== FIREWALL ==="
ufw status 2>/dev/null || echo "Needs sudo"
