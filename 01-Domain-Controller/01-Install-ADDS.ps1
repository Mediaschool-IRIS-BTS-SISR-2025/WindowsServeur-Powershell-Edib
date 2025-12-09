# 01-Install-ADDS.ps1 - Installation Active Directory
# Domaine: mediaschool.local

Write-Host "--- INSTALLATION AD DS ---" -ForegroundColor Cyan

# 1. Installation des Rôles
Install-WindowsFeature -Name AD-Domain-Services, DNS, DHCP, RSAT-AD-PowerShell -IncludeManagementTools

# 2. Variables
$DomainName = "mediaschool.local"
$NetbiosName = "MEDIASCHOOL"
# Mot de passe de restauration (DSRM) et Admin - À changer en prod !
$Pass = ConvertTo-SecureString "Mediaschool2025!" -AsPlainText -Force

# 3. Promotion
Write-Host "Promotion en cours... Le serveur va redémarrer." -ForegroundColor Yellow
Install-ADDSForest -DomainName $DomainName -DomainNetbiosName $NetbiosName -InstallDns:$true -SafeModeAdministratorPassword $Pass -Force:$true