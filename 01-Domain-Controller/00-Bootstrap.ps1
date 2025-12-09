# 00-Bootstrap.ps1 - Configuration Initiale SRV-DC1
# IP: 192.168.100.10 / GW: 192.168.100.1

Write-Host "--- BOOTSTRAP SRV-DC1 ---" -ForegroundColor Cyan

# 1. Variables
$ServerName = "SRV-DC1"
$IPAddress  = "192.168.100.10"
$Prefix     = 24
$Gateway    = "192.168.100.1"
$DNS        = "127.0.0.1"

# 2. Renommer
Rename-Computer -NewName $ServerName -ErrorAction SilentlyContinue

# 3. Réseau
$Adapter = Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object -First 1
if ($Adapter) {
    # Nettoyage et Application
    Remove-NetIPAddress -InterfaceAlias $Adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
    New-NetIPAddress -InterfaceAlias $Adapter.Name -IPAddress $IPAddress -PrefixLength $Prefix -DefaultGateway $Gateway -Confirm:$false
    Set-DnsClientServerAddress -InterfaceAlias $Adapter.Name -ServerAddresses $DNS -Confirm:$false
    Write-Host "IP Configurée : $IPAddress" -ForegroundColor Green
} else {
    Write-Host "ERREUR : Pas de carte réseau !" -ForegroundColor Red
    Exit
}

# 4. Reboot
Write-Host "Redémarrage dans 5 secondes..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
Restart-Computer -Force