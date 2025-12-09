# 04-Config-WDS-MDT.ps1
# Configuration WDS (Services de déploiement) - Version Corrigée

Write-Host "--- CONFIGURATION WDS (DEPLOYMENT SERVICES) ---" -ForegroundColor Cyan

# 1. Installation du rôle WDS
Write-Host "Installation du rôle WDS..." -ForegroundColor Yellow
$InstallStatus = Install-WindowsFeature -Name WDS -IncludeManagementTools
if ($InstallStatus.Success) {
    Write-Host "Rôle WDS installé." -ForegroundColor Green
} else {
    Write-Host "Le rôle était déjà installé ou erreur." -ForegroundColor Yellow
}

# 2. Configuration WDS (Sur C: car D: est le CD-ROM)
$RemotePath = "C:\RemoteInstall"

# Création du dossier si nécessaire
if (-not (Test-Path $RemotePath)) { 
    New-Item -Path $RemotePath -ItemType Directory | Out-Null 
}

Write-Host "Initialisation du serveur WDS sur $RemotePath..." -ForegroundColor Yellow
Try {
    # Commande corrigée : Suppression de -NewDC qui bloquait
    Initialize-WdsServer -RemInst $RemotePath -Authorize -ErrorAction Stop
    Write-Host "WDS Initialisé avec succès." -ForegroundColor Green
} Catch {
    Write-Host "WDS est déjà configuré ou une erreur mineure est survenue." -ForegroundColor Yellow
}

# 3. Démarrage du service
Try {
    Start-Service WDSServer -ErrorAction Stop
    Write-Host "Service WDS démarré." -ForegroundColor Green
} Catch {
    Write-Host "Le service WDS n'a pas pu démarrer. Essayez de redémarrer le serveur." -ForegroundColor Red
}

# 4. Vérification MDT (Rappel manuel)
# Note : MDT s'installe via un fichier .msi externe, pas via ce script.
if (Get-Module -ListAvailable "MDTDB") {
    Write-Host "Module MDT détecté." -ForegroundColor Green
} else {
    Write-Host "---------------------------------------------------" -ForegroundColor Red
    Write-Host "ATTENTION : MDT (Microsoft Deployment Toolkit) n'est pas installé." -ForegroundColor Red
    Write-Host "Ce script a configuré WDS (le socle), mais pour utiliser MDT vous devez :" -ForegroundColor Yellow
    Write-Host "1. Télécharger et installer Windows ADK" -ForegroundColor Yellow
    Write-Host "2. Télécharger et installer ADK WinPE Add-on" -ForegroundColor Yellow
    Write-Host "3. Télécharger et installer Microsoft Deployment Toolkit (MDT)" -ForegroundColor Yellow
    Write-Host "---------------------------------------------------" -ForegroundColor Red
}