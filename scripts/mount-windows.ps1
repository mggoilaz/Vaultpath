# mount-windows.ps1 — Montar unidad Samba en Windows
# Uso: powershell -ExecutionPolicy Bypass -File scripts\mount-windows.ps1

param(
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 4)]
    [int]$Index,

    [Parameter(Mandatory = $false)]
    [ValidateSet("raul", "lumiora", "nexora", "waydra")]
    [string]$TeamUser
)

$envFile = Join-Path $PSScriptRoot "..\.env"
$config = @{}
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.+)$") { $config[$matches[1].Trim()] = $matches[2].Trim() }
    }
}

$TS_IP  = if ($config["SERVER_TS_IP"] -and $config["SERVER_TS_IP"] -notlike "*YOUR*")  { $config["SERVER_TS_IP"] }  else { "YOUR_TAILSCALE_IP" }
$LAN_IP = if ($config["SERVER_LAN_IP"] -and $config["SERVER_LAN_IP"] -notlike "*YOUR*") { $config["SERVER_LAN_IP"] } else { "" }

# Tabla del equipo
$TEAM = @(
    @{ user = "raul";    share = "Datos";   letra = "R" }
    @{ user = "lumiora"; share = "Lumiora"; letra = "L" }
    @{ user = "nexora";  share = "nexora";  letra = "N" }
    @{ user = "waydra";  share = "waydra";  letra = "W" }
)

Write-Host ""
Write-Host "===================================="
Write-Host "VAULTPATH - Mount network drive"
Write-Host "===================================="
Write-Host ""
if (-not $TeamUser -and -not $Index) {
    Write-Host ("  {0,-4} {1,-12} {2,-12} {3}" -f "#", "User", "Share", "Drive")
    Write-Host "  ----------------------------------"
    for ($i = 0; $i -lt $TEAM.Count; $i++) {
        $t = $TEAM[$i]
        Write-Host ("  {0})   {1,-12} {2,-12} {3}:" -f ($i+1), $t.user, $t.share, $t.letra)
    }
    Write-Host ""
}

if ($TeamUser) {
    $idx = -1
    for ($i = 0; $i -lt $TEAM.Count; $i++) {
        if ($TEAM[$i].user -eq $TeamUser) { $idx = $i; break }
    }
} elseif ($Index) {
    $idx = $Index - 1
} else {
    $opcion = Read-Host "Choose [1-$($TEAM.Count)]"
    $idx = [int]$opcion - 1
}

if ($idx -lt 0 -or $idx -ge $TEAM.Count) {
    Write-Host "Invalid option."; exit 1
}

$USER  = $TEAM[$idx].user
$SHARE = $TEAM[$idx].share
$LETRA = $TEAM[$idx].letra

Write-Host ""
Write-Host "User: $USER | Share: $SHARE | Drive: ${LETRA}:"

# Detectar red — evitar conflicto Windows con dos usuarios en la misma IP
$enLAN = $false
$ips = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue
foreach ($ip in $ips) {
    if ($ip.IPAddress -match "^192\.168\.") { $enLAN = $true; break }
}

$lanConflict = $false
if ($LAN_IP) {
    $lanConflict = (net use 2>$null | Select-String -SimpleMatch $LAN_IP) -ne $null
}
if ($lanConflict -or -not $enLAN -or -not $LAN_IP) {
    $IP = $TS_IP
    Write-Host "Network: Tailscale -> $IP"
} else {
    $IP = $LAN_IP
    Write-Host "Network: LAN -> $IP"
}

$RUTA = "\\$IP\$SHARE"
$credTarget = "vaultpath_$IP"

net use "${LETRA}:" /delete /yes 2>$null | Out-Null

# Check Windows Credential Manager for saved credentials
$savedCred = cmdkey /list:$credTarget 2>$null | Select-String "Target:"
$hasCred = $null -ne $savedCred

if ($hasCred) {
    Write-Host ""
    Write-Host "Saved credentials found. Mounting directly..."
    Write-Host ""

    $result = net use "${LETRA}:" "$RUTA" /user:$USER /persistent:yes 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK - Drive ${LETRA}: mounted successfully" -ForegroundColor Green
        Write-Host "Check File Explorer for drive ${LETRA}:"
    } else {
        Write-Host "Saved credentials failed. Removing and requesting new ones..." -ForegroundColor Yellow
        cmdkey /delete:$credTarget 2>$null | Out-Null
        $hasCred = $false
    }
}

if (-not $hasCred) {
    Write-Host ""
    Write-Host "Mounting $RUTA as ${LETRA}: ..."
    Write-Host "(A new window will open - enter your password there)"
    Write-Host ""

    $cmd = @"
Write-Host "Mounting $RUTA as ${LETRA}:" -ForegroundColor Cyan
Write-Host ""
`$pass = Read-Host "Enter password for $USER" -AsSecureString
`$plainPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR(`$pass))

cmdkey /add:$credTarget /user:$USER /pass:`$plainPass 2>`$null | Out-Null

net use ${LETRA}: "$RUTA" /user:$USER /persistent:yes 2>`$null
if (`$LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "OK - Drive ${LETRA}: mounted successfully" -ForegroundColor Green
    Write-Host "Credentials saved in Windows Credential Manager." -ForegroundColor Green
    Write-Host "Next time, no password will be required." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "ERROR - wrong password or network unavailable" -ForegroundColor Red
    cmdkey /delete:$credTarget 2>`$null | Out-Null
    Write-Host "Credentials NOT saved." -ForegroundColor Yellow
}
Write-Host ""
Read-Host "Press Enter to close"
"@
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $cmd

    Write-Host ""
    Write-Host "Check File Explorer for drive ${LETRA}:"
}
