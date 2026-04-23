# Flow: Connect to server

## LAN
```
1. bash scripts/check-network.sh
2. bash scripts/test-port.sh LAN_IP 22
3. bash scripts/connect.sh
```

## Remote (Tailscale)
```
1. bash scripts/check-vpn.sh
2. bash scripts/test-port.sh TS_IP 22
3. bash scripts/connect.sh
```
