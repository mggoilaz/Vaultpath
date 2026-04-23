# Windows setup

## Install
- Git Bash: git-scm.com/download/win
- Tailscale: tailscale.com/download

## Setup
1. Right-click on vaultpath folder → "Git Bash Here"
2. Run: `bash scripts/setup.sh`

## If ssh-copy-id not available
```powershell
type "$HOME\.ssh\vaultpath_id_ed25519.pub" | ssh USER@SERVER_IP "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```
