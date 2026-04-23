# mount-windows.ps1 — Mount Samba network drive on Windows
# Edit $TEAM array below with your actual team members
# Usage: powershell -ExecutionPolicy Bypass -File scripts\mount-windows.ps1

$envFile = Join-Path $PSScriptRoot "..\.env"
$config = @{}
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.+)$") { $config[$matches[1].Trim()] = $matches[2].Trim() }
    }
}

$TS_IP  = if ($config["SERVER_TS_IP"] -and $config["SERVER_TS_IP"] -notlike "*YOUR*")  { $config["SERVER_TS_IP"] }  else { "YOUR_TAILSCALE_IP" }
$LAN_IP = if ($config["SERVER_LAN_IP"] -and $config["SERVER_LAN_IP"] -notlike "*YOUR*") { $config["SERVER_LAN_IP"] } else { "" }

# ─── CONFIGURE YOUR TEAM HERE ───────────────────────────────────────
$TEAM = @(
    @{ user = "user1"; share = "Share1"; letra = "A" }
    @{ user = "user2"; share = "Share2"; letra = "B" }
    @{ user = "user3"; share = "Share3"; letra = "C" }
)
# ────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "╔══════════════════════════════════╗"
Write-Host "║        VAULTPATH 🔑              ║"
Write-Host "║     Mount network drive          ║"
Write-Host "╚══════════════════════════════════╝"
Write-Host ""
Write-Host ("  {0,-4} {1,-12} {2,-12} {3}" -f "#", "User", "Share", "Drive")
Write-Host "  ──────────────────────────────────"
for ($i = 0; $i -lt $TEAM.Count; $i++) {
    $t = $TEAM[$i]
    Write-Host ("  {0})   {1,-12} {2,-12} {3}:" -f ($i+1), $t.user, $t.share, $t.letra)
}
Write-Host ""

$opcion = Read-Host "Choose [1-$($TEAM.Count)]"
$idx = [int]$opcion - 1

if ($idx -lt 0 -or $idx -ge $TEAM.Count) {
    Write-Host "Invalid option."; exit 1
}

$USER  = $TEAM[$idx].user
$SHARE = $TEAM[$idx].share
$LETRA = $TEAM[$idx].letra

Write-Host ""
Write-Host "User: $USER | Share: $SHARE | Drive: ${LETRA}:"

$enLAN = $false
$ips = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue
foreach ($ip in $ips) {
    if ($ip.IPAddress -match "^192\.168\.") { $enLAN = $true; break }
}

$lanConflict = net use 2>$null | Select-String $LAN_IP
if ($lanConflict -or -not $enLAN -or -not $LAN_IP) {
    $IP = $TS_IP
    Write-Host "Network: Tailscale → $IP"
} else {
    $IP = $LAN_IP
    Write-Host "Network: LAN → $IP"
}

$RUTA = "\\$IP\$SHARE"
net use "${LETRA}:" /delete /yes 2>$null | Out-Null

Write-Host ""
Write-Host "Mounting $RUTA as ${LETRA}: ..."
Write-Host "(A new window will open — enter your password there)"

$cmd = "Write-Host 'Mounting $RUTA as ${LETRA}:' -ForegroundColor Cyan; net use ${LETRA}: '$RUTA' /user:$USER /persistent:yes; if (`$LASTEXITCODE -eq 0) { Write-Host '✓ Drive ${LETRA}: mounted' -ForegroundColor Green } else { Write-Host 'ERROR — wrong password or network unavailable' -ForegroundColor Red }; Read-Host 'Press Enter to close'"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $cmd -Wait

Write-Host ""
Write-Host "Check File Explorer for drive ${LETRA}:"
