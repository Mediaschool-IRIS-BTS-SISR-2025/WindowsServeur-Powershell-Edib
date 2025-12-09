# 02-Config-FSRM.ps1
# Configuration FSRM Complète (Installation + Config)

Write-Host "--- INSTALLATION & CONFIGURATION FSRM ---" -ForegroundColor Cyan

# 0. Installation du rôle FSRM (Le module manquant)
Write-Host "Vérification et installation du gestionnaire de ressources..." -ForegroundColor Yellow
Install-WindowsFeature -Name FS-Resource-Manager -IncludeManagementTools
Write-Host "Rôle FSRM installé/vérifié." -ForegroundColor Green

# 1. Création des dossiers (Sur C: au lieu de D:)
$Root = "C:\Donnees"
if (-not (Test-Path $Root)) { New-Item -Path $Root -ItemType Directory -Force | Out-Null }
if (-not (Test-Path "$Root\Homes")) { New-Item -Path "$Root\Homes" -ItemType Directory -Force | Out-Null }
Write-Host "Dossiers créés sur C:\Donnees" -ForegroundColor Green

# 2. Création de l'Action (Email)
$ActionEmail = New-FsrmAction -Type Email -MailTo "admin@mediaschool.local" -RunLimitInterval 60

# 3. Création du Seuil (Threshold)
$Threshold = New-FsrmQuotaThreshold -Percentage 85 -Action $ActionEmail

# 4. Création du Modèle de Quota "Modele-Eleves"
Try {
    New-FsrmQuotaTemplate -Name "Modele-Eleves" -SizeLimit 100MB -SoftLimit $False -Threshold $Threshold -ErrorAction Stop
    Write-Host "Modèle de quota 'Modele-Eleves' créé." -ForegroundColor Green
} Catch {
    Write-Host "Le modèle existe déjà." -ForegroundColor Yellow
}

# 5. Application du Quota Automatique
Try {
    New-FsrmAutoQuota -Path "$Root\Homes" -Template "Modele-Eleves" -ErrorAction Stop
    Write-Host "Quota Automatique appliqué sur $Root\Homes" -ForegroundColor Green
} Catch {
    Write-Host "Le quota automatique existe déjà." -ForegroundColor Yellow
}