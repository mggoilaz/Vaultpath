# vaultpath 🔑

> The secure path to your server — SSH and VPN connection toolkit with AI agent support.

Works on **Windows, Linux and macOS**.

---

## Quick start

### 1. Clone
```bash
git clone https://github.com/YOUR_USERNAME/vaultpath.git
cd vaultpath
```

### 2. Create `.env`
```bash
cp .env.example .env
# Fill in your server IPs and username
```

### 3. Setup (once per person)
```bash
bash scripts/setup.sh
```

### 4. Open in Cursor and activate
Paste `VAULTPATH.md` as system prompt, then type:
```
Open vaultpath
```

---

## What it does

- Detects LAN or Tailscale automatically
- Verifies VPN before connecting
- SSH connection with retry + circuit breaker
- Shows team folders table — pick yours and mount it
- Works on Windows, Linux and macOS
- Local session memory (Vault)

---

## Team folders

| User | Share | Drive |
|---|---|---|
| raul | Datos | R: |
| lumiora | Lumiora | L: |
| nexora | nexora | N: |
| waydra | waydra | W: |

---

## Scripts

| Script | Usage |
|---|---|
| `setup.sh` | First-time setup |
| `connect.sh` | SSH connection |
| `mount-unix.sh` | Mount drive Linux/Mac |
| `mount-windows.ps1` | Mount drive Windows |
| `monitor.sh` | Server status |
| `check-vpn.sh` | Verify Tailscale |

---

## License

MIT License — Copyright (c) 2026 Marco Gabriel Goitia Lazarte
