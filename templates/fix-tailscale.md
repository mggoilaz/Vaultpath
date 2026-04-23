# Fix: Tailscale issues

## Server not visible in tailnet

### Option A — Switch tailnet in app
Open Tailscale → Switch account → select team network

### Option B — Accept invitation again
Admin sends invite → open link → accept

### Option C — Auth key
```bash
tailscale up --auth-key=tskey-auth-XXXXXXXXX
```
Generate at: login.tailscale.com → Settings → Auth keys

### Verify
```bash
tailscale status
bash scripts/test-port.sh YOUR_TS_IP 22
```
