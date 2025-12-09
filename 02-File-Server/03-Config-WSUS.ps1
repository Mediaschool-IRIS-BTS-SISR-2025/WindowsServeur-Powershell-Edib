# 03-Config-WSUS.ps1
# Configuration WSUS Corrigée (C: au lieu de D:)

Write-Host "--- INSTALLATION & CONFIGURATION WSUS ---" -ForegroundColor Cyan

# 1. Installation du rôle WSUS
Write-Host "Installation du rôle WSUS et des outils (Patience, c'est long...)" -ForegroundColor Yellow
Install-WindowsFeature -Name UpdateServices -IncludeManagementTools
Write-Host "Rôle installé." -ForegroundColor Green

# 2. Création du dossier de stockage (CORRECTION : Sur C:\WSUS)
$WsusContentPath = "C:\WSUS"
if (-not (Test-Path $WsusContentPath)) {
    New-Item -Path $WsusContentPath -ItemType Directory -Force | Out-Null
}
Write-Host "Dossier de stockage créé : $WsusContentPath" -ForegroundColor Green

# 3. Post-Installation (Étape CRITIQUE pour initialiser la base de données)
Write-Host "Lancement de la post-installation (Configuration de la base)..." -ForegroundColor Yellow
$WsusUtil = "$env:ProgramFiles\Update Services\Tools\WsusUtil.exe"
# Cette commande initialise WSUS dans le dossier C:\WSUS
Start-Process -FilePath $WsusUtil -ArgumentList "postinstall CONTENT_DIR=$WsusContentPath" -Wait -NoNewWindow

# 4. Connexion et Configuration
Write-Host "Connexion au serveur WSUS..." -ForegroundColor Yellow
try {
    $Wsus = Get-WsusServer -Name "localhost" -PortNumber 8530 -ErrorAction Stop
    
    # Création des groupes
    Write-Host "Création des groupes..."
    try { $Wsus.CreateComputerTargetGroup("WSUS-Pilote") } catch {}
    try { $Wsus.CreateComputerTargetGroup("WSUS-Production") } catch {}
    
    # Configuration de la source (Microsoft Update)
    $Config = $Wsus.GetConfiguration()
    $Config.SyncFromMicrosoftUpdate = $true
    $Config.Save()
    
    Write-Host "WSUS configuré avec succès !" -ForegroundColor Green
}
catch {
    Write-Host "Erreur lors de la configuration finale. Vérifiez que le service est bien lancé." -ForegroundColor Red
    Write-Error $_
}