# 03-Config-DHCP.ps1 - CORRIGÉ
[cite_start]# [cite: 10, 49-57] Scope 50-200, Bail 6h

Import-Module DhcpServer
Write-Host "--- CONFIGURATION DHCP ---" -ForegroundColor Cyan

$ScopeName = "SCOPE-SALLE-INFO"
$ScopeID   = "192.168.100.0"

# 1. Autorisation AD
# Note : Si le serveur est déjà autorisé, cette commande peut afficher une erreur rouge (ignorable)
Add-DhcpServerInDC -DnsName "SRV-DC1.mediaschool.local" -IPAddress "192.168.100.10" -ErrorAction SilentlyContinue

# 2. Création Scope
# On vérifie si le scope existe déjà pour éviter l'erreur
if (-not (Get-DhcpServerv4Scope -ScopeId $ScopeID -ErrorAction SilentlyContinue)) {
    Add-DhcpServerv4Scope -Name $ScopeName -StartRange "192.168.100.50" -EndRange "192.168.100.200" -SubnetMask 255.255.255.0 -State Active -LeaseDuration (New-TimeSpan -Hours 6)
    Write-Host "Scope créé avec succès." -ForegroundColor Green
} else {
    Write-Host "Le scope existe déjà." -ForegroundColor Yellow
}

# 3. Options du Scope
Set-DhcpServerv4OptionValue -ScopeId $ScopeID -OptionId 3 -Value "192.168.100.1"      # Routeur
Set-DhcpServerv4OptionValue -ScopeId $ScopeID -OptionId 6 -Value "192.168.100.10"     # DNS
Set-DhcpServerv4OptionValue -ScopeId $ScopeID -OptionId 15 -Value "mediaschool.local" # Domaine

# 4. MAJ DNS Dynamique (CORRECTION ICI)
# On utilise Set-DhcpServerv4DnsSetting au lieu de Set-DhcpServerv4Scope
Set-DhcpServerv4DnsSetting -ScopeId $ScopeID -DynamicUpdates "Always" -DeleteDnsRROnLeaseExpiry $true

Write-Host "Configuration DHCP terminée." -ForegroundColor Green