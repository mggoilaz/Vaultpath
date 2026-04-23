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

---

## Registration flow (step by step)

### Step 1 — Ask name (plain text)
```
What is your name?
```
Wait for answer. Then step 2.

### Step 2 — Ask role (interactive)
```
Select your role:
  A) admin — full access
  B) member — access to your folder
  C) viewer — read only
```
Wait for answer. Then step 3.

### Step 3 — Ask server username (interactive)
Show the team list configured below. Wait for answer. Register. Then show menu.

### Step 4 — Show menu by role (interactive)

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

**Person name** → who is operating (e.g. Marco, Ana)
- Stored in `~/.vaultpath/vault/team.json`
- Defines role and permissions

**Server username** → Linux account on the server (e.g. user1, user2)
- Defines which Samba folder and SSH user

These are NEVER mixed. Always ask separately, one at a time.

---

## Returning user

If name found in `~/.vaultpath/vault/team.json`:
- Greet with last session context
- Go directly to menu

---

## Team folders
> Edit this table with your actual team members and shares

| User | Share | Drive | Description |
|---|---|---|---|
| user1 | Share1 | A: | Add your team here |
| user2 | Share2 | B: | |
| user3 | Share3 | C: | |

---

## Server configuration
> Values from `.env` — never hardcode here

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
- Never store passwords in vault or any file
- Read-only before any changes
- Always propose before executing
- Maximum 3 retries (circuit breaker)
- SSH only available to admin role

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
5. Open external terminal → user enters Samba password
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
├── vault/team.json
└── sessions/server/
    ├── session.json
    ├── history.log
    └── last.md
```

---

## Scripts
| Script | Usage |
|---|---|
| `setup.sh` | First-time setup |
| `connect.sh` | SSH connection (admin only) |
| `mount-unix.sh` | Mount drive Linux/Mac |
| `mount-windows.ps1` | Mount drive Windows |
| `monitor.sh` | Server status |
| `check-vpn.sh` | Verify Tailscale |
| `add-member.sh` | Add team member (admin only) |

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
| Circuit breaker | "3 failures. Please check manually." |
