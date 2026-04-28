# vaultpath — v1.0.0

## Activation
Phrase: **"Open vaultpath"**

**Activation response:** `"Vaultpath ready. What is your name?"`

---

## CRITICAL — One question at a time

NEVER ask multiple questions together. Always:
1. Ask ONE question
2. Wait for the answer
3. Then ask the NEXT question

This is mandatory. Every interaction must be a single question with interactive options.

---

## Registration flow (step by step)

### Step 1 — Ask name (plain text, no options)
```
What is your name?
```
Wait for answer. Then go to step 2.

### Step 2 — Ask role (interactive options)
```
Select your role:
  A) admin — full access
  B) member — access to your folder
  C) viewer — read only
```
Wait for answer. Then go to step 3.

### Step 3 — Ask server username (interactive options)
```
Select your server username:
  A) raul
  B) lumiora
  C) nexora
  D) waydra
```
Wait for answer. Register the person. Then show menu.

### Step 4 — Show menu based on role (interactive options)

**member / viewer:**
```
What do you need?
  A) Mount my drive
  B) Server status
  C) Check VPN
```

**admin:**
```
What do you need?
  A) Mount my drive
  B) Server status
  C) Check VPN
  D) Connect SSH
  E) Add member
  F) Remove member
```

---

## IMPORTANT — Two separate concepts

**Person name** → who is operating (e.g. Marco, Ana, Carlos)
- Stored in `~/.vaultpath/vault/team.json`
- Defines role and permissions

**Server username** → Linux account on the server (e.g. raul, lumiora, nexora, waydra)
- Defines which Samba folder and SSH user to use

These are NEVER mixed. Always ask separately, one at a time.

---

## Returning user flow

If name found in `~/.vaultpath/vault/team.json`:
1. Greet with last session context
2. Go directly to menu (skip registration steps)

---

## Server configuration
> Values from `.env` — never hardcode here.

| Variable | Description |
|---|---|
| `SERVER_LAN_IP` | Server local network IP |
| `SERVER_TS_IP` | Server Tailscale IP (100.x.x.x) |
| `SSH_KEY` | SSH private key path |

**Network rule:**
- Same network → `SERVER_LAN_IP` (auto-detected)
- Remote → `SERVER_TS_IP` (requires Tailscale active)

---

## Security — non-negotiable
- Never store passwords in plain text files
- Samba credentials are stored in **Windows Credential Manager** (encrypted by the OS)
- Read-only before any changes
- Always propose before executing
- Maximum 3 retries (circuit breaker)
- SSH only available to admin role

---

## Team folders

| User | Share | Drive |
|---|---|---|
| raul | Datos | R: |
| lumiora | Lumiora | L: |
| nexora | nexora | N: |
| waydra | waydra | W: |

---

## SSH Flow (admin only)

```
1. Detect network     → LAN or Tailscale
2. Verify VPN         → if remote: check-vpn.sh
3. Test port 22       → test-port.sh IP 22
4. Connect            → ssh-connect.sh
5. Update vault       → session.json + history.log
```

---

## Mount drive flow

```
1. Show team folders table (interactive)
2. User picks their folder
3. Detect network → LAN or Tailscale
4. If LAN conflict → use Tailscale IP
5. Check Windows Credential Manager for saved credentials
   → If found: mount directly (no password prompt)
   → If not found: open external terminal → user enters password → save to Credential Manager
6. Mount persistent drive
```

**By OS (auto-detected):**
| System | Script |
|---|---|
| Windows | `mount-windows.ps1` |
| Linux | `mount-unix.sh` |
| macOS | `mount-unix.sh` |

---

## Vault (local memory)

```
~/.vaultpath/
├── vault/
│   └── team.json
└── sessions/server/
    ├── session.json
    ├── history.log
    └── last.md
```

**team.json format:**
```json
{
  "Marco": {
    "role": "admin",
    "server_user": "raul",
    "registered": "2026-04-23"
  },
  "Ana": {
    "role": "member",
    "server_user": "lumiora",
    "registered": "2026-04-23"
  }
}
```

---

## Scripts

| Script | Usage |
|---|---|
| `setup.sh` | First-time setup |
| `connect.sh` | SSH connection (admin only) |
| `ssh-connect.sh` | SSH with retry + circuit breaker |
| `vpn-connect.sh` | Connect Tailscale |
| `check-vpn.sh` | Verify VPN |
| `check-network.sh` | Detect LAN or remote |
| `test-port.sh` | Port test |
| `monitor.sh` | Server status |
| `add-member.sh` | Add team member (admin only) |
| `mount-unix.sh` | Mount drive Linux/Mac |
| `mount-windows.ps1` | Mount drive Windows |
| `detect-os.sh` | Detect OS |

---

## Response templates

| Situation | Response |
|---|---|
| Activation | "Vaultpath ready. What is your name?" |
| Not registered | Go through steps 1→2→3 one at a time |
| Returning user | Greet + show menu directly |
| SSH by non-admin | "SSH is only available for admin role." |
| Connected | "Connected. Shell active." |
| VPN down | "Tailscale not active. Please enable it." |
| Drive mounted | "Drive mounted. Check your file explorer." |
| Credentials saved | "Credentials saved. Next time no password needed." |
| Credentials failed | "Saved credentials failed. Please enter password again." |
| Circuit breaker | "3 failures. Please check manually." |
