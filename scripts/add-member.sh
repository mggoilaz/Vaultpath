#!/usr/bin/env bash
# add-member.sh — Add team member (admin only)
USERNAME="$1"; GROUP="${2:-}"
[ -z "$USERNAME" ] && echo "Usage: add-member.sh USERNAME [GROUP]" && exit 1
echo "=== Vaultpath Add Member: $USERNAME ==="
sudo adduser "$USERNAME" || exit 1
[ -n "$GROUP" ] && sudo usermod -aG "$GROUP" "$USERNAME"
sudo mkdir -p "/srv/datos/$USERNAME"
sudo chown "$USERNAME:$USERNAME" "/srv/datos/$USERNAME"
sudo chmod 750 "/srv/datos/$USERNAME"
sudo smbpasswd -a "$USERNAME"
echo "✓ Member $USERNAME created."
echo "PENDING: Invite to Tailscale at login.tailscale.com"
