# Flow: Diagnose connectivity

## Decision tree
```
Can you reach the server?
├── NO → Is Tailscale active?
│   ├── NO → tailscale up
│   └── YES → Wrong tailnet? → see templates/fix-tailscale.md
└── YES → Port 22 open?
    ├── NO → check UFW on server
    └── YES → SSH key installed?
        └── NO → run setup.sh again
```

## Commands
```bash
bash scripts/check-network.sh
bash scripts/check-vpn.sh
bash scripts/test-port.sh IP 22
```
