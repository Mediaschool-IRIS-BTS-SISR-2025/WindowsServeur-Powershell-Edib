# 00-Bootstrap.ps1 - Configuration Initiale SRV-FS1
# IP: 192.168.100.20 / DNS: 192.168.100.10

Write-Host "--- BOOTSTRAP SRV-FS1 ---" -ForegroundColor Cyan

# 1. Variables
$ServerName = "SRV-FS1"
$IPAddress  = "192.168.100.20"
$DNS        = "192.168.100.10" # Pointe vers le DC
$Gateway    = "192.168.100.1"

# 2. Renommer
Rename-Computer -NewName $ServerName -ErrorAction SilentlyContinue

# 3. Réseau
$Adapter = Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object -First 1
if ($Adapter) {
    Remove-NetIPAddress -InterfaceAlias $Adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
    New-NetIPAddress -InterfaceAlias $Adapter.Name -IPAddress $IPAddress -PrefixLength 24 -DefaultGateway $Gateway -Confirm:$false
    Set-DnsClientServerAddress -InterfaceAlias $Adapter.Name -ServerAddresses $DNS -Confirm:$false
    Write-Host "Réseau Configuré." -ForegroundColor Green
}

# 4. Reboot
Start-Sleep -Seconds 5
Restart-Computer -Force