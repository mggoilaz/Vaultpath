# Flow: Manage team

## Add member
```bash
bash scripts/add-member.sh USERNAME
# Then invite to Tailscale: login.tailscale.com → Invite
```

## Remove member
```bash
sudo usermod -L USERNAME
sudo smbpasswd -d USERNAME
# Revoke in Tailscale admin
```
