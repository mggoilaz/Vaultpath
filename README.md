# vaultpath 🔑

> The secure path to your server — SSH and VPN connection toolkit with AI agent support.

Works on **Windows, Linux and macOS**.

---

## What it does

- Detects automatically if you are on LAN or remote (Tailscale)
- Verifies VPN before connecting
- SSH connection with retry + circuit breaker
- Shows your team folders — pick yours and mount it
- Role-based access (admin / member / viewer)
- One question at a time — clean interactive UI in Cursor
- Local session memory (Vault)

---

## Requirements

| Tool | Purpose | Download |
|---|---|---|
| **Cursor** or any AI editor | Run the AI agent | [cursor.com](https://cursor.com) |
| **Tailscale** | VPN for remote access | [tailscale.com/download](https://tailscale.com/download) |
| **Git Bash** *(Windows only)* | Run bash scripts | [git-scm.com](https://git-scm.com) |
| SSH client | Connect to server | Built-in on Windows 10+, Linux, macOS |

---

## Quick start

### 1. Clone
```bash
git clone https://github.com/YOUR_USERNAME/vaultpath.git
cd vaultpath
```

### 2. Configure your team in `VAULTPATH.md`

Edit the team folders table with your actual users and shares:

```markdown
| your_user | YourShare | R: |
| member1   | Share1    | L: |
| member2   | Share2    | N: |
```

### 3. Create `.env`
```bash
cp .env.example .env
```

Fill in your server details:
```bash
SERVER_TS_IP=YOUR_TAILSCALE_IP
SERVER_LAN_IP=YOUR_LAN_IP
SSH_KEY=~/.ssh/vaultpath_id_ed25519
TAILSCALE_AUTH_KEY=YOUR_AUTH_KEY
```

> ⚠️ **Never commit `.env` to git.** Already in `.gitignore`.

### 4. Run setup (once per person)
```bash
bash scripts/setup.sh
```

### 5. Open in Cursor and activate

Paste `VAULTPATH.md` as system prompt, then type:
```
Open vaultpath
```

---

## How it works

The agent asks one question at a time using Cursor's interactive UI:

```
1. "What is your name?"
2. "Select your role:" → admin / member / viewer
3. "Select your server username:" → your team list
4. "What do you need?" → menu based on role
```

**Menu by role:**

| Option | member | admin |
|---|---|---|
| Mount my drive | ✅ | ✅ |
| Server status | ✅ | ✅ |
| Check VPN | ✅ | ✅ |
| Connect SSH | ❌ | ✅ |
| Add/remove member | ❌ | ✅ |

---

## Project structure

```
vaultpath/
├── VAULTPATH.md              # AI system prompt — paste into Cursor
├── README.md                 # This file
├── LICENSE                   # MIT License
├── .env.example              # Template — copy to .env
├── .gitignore                # Protects .env and SSH keys
├── scripts/
│   ├── setup.sh              # First-time setup
│   ├── connect.sh            # SSH connection
│   ├── ssh-connect.sh        # SSH with retry + circuit breaker
│   ├── vpn-connect.sh        # Connect Tailscale
│   ├── check-vpn.sh          # Verify VPN
│   ├── check-network.sh      # Detect LAN or remote
│   ├── test-port.sh          # Port test
│   ├── monitor.sh            # Server status
│   ├── add-member.sh         # Add team member (admin only)
│   ├── mount-unix.sh         # Mount Samba drive Linux/Mac
│   ├── mount-windows.ps1     # Mount Samba drive Windows
│   └── detect-os.sh          # Detect operating system
├── flows/
│   ├── connect.md            # SSH connection flow
│   ├── diagnose.md           # Troubleshooting flow
│   └── manage-team.md        # Team management
└── templates/
    ├── fix-tailscale.md      # Fix Tailscale issues
    └── setup-windows.md      # Windows setup guide
```

---

## Vault (local memory)

Session data stored only on your machine — never sent anywhere.

```
~/.vaultpath/
├── vault/team.json           # Team members and roles
└── sessions/YOUR_SERVER/
    ├── session.json          # Last connection metadata
    ├── history.log           # Event timeline
    └── last.md               # Last action summary
```

---

## Adapting to your team

Edit `VAULTPATH.md` to add your team members and shares:

```markdown
## Team folders
| User     | Share    | Drive |
|----------|----------|-------|
| user1    | Share1   | A:    |
| user2    | Share2   | B:    |
```

Also update the arrays in `scripts/mount-unix.sh` and `scripts/mount-windows.ps1`:

```bash
USERS=("user1" "user2")
SHARES=("Share1" "Share2")
```

---

## Security

- Passwords **never stored** in any file
- SSH keys live only on each person's machine
- `.env` excluded from git
- Vault stores only metadata — no credentials
- SSH access restricted to admin role only

---

## Troubleshooting

```bash
bash scripts/test-port.sh YOUR_SERVER_IP 22
bash scripts/check-vpn.sh
```

See `templates/fix-tailscale.md` for Tailscale issues.

**Start over:**
```bash
rm -rf ~/.vaultpath/
rm ~/.ssh/vaultpath_id_ed25519 ~/.ssh/vaultpath_id_ed25519.pub
bash scripts/setup.sh
```

---

## License

MIT License — Copyright (c) 2026 Marco Gabriel Goitia Lazarte

See [LICENSE](LICENSE) for details.
