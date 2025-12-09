# 04-Deploy-GPO.ps1
# GPO PowerShell

Import-Module GroupPolicy
Write-Host "--- DEPLOIEMENT GPO ---" -ForegroundColor Cyan

$GPOs = @("GPO-ADM-Poste", "GPO-PROF-Poste", "GPO-ELEVE-Poste")

# 1. Création
foreach ($gpo in $GPOs) {
    if (-not (Get-GPO -Name $gpo -ErrorAction SilentlyContinue)) { 
        New-GPO -Name $gpo 
        Write-Host "Création de la GPO : $gpo" -ForegroundColor Green
    }
}

# 2. Liaisons
# (Le paramètre ErrorAction évite l'erreur si le lien existe déjà)
New-GPLink -Name "GPO-ADM-Poste" -Target "OU=Administration,OU=Comptes-Utilisateurs,OU=ECOLE,DC=mediaschool,DC=local" -ErrorAction SilentlyContinue
New-GPLink -Name "GPO-PROF-Poste" -Target "OU=Profs,OU=Comptes-Utilisateurs,OU=ECOLE,DC=mediaschool,DC=local" -ErrorAction SilentlyContinue
New-GPLink -Name "GPO-ELEVE-Poste" -Target "OU=Eleves,OU=Comptes-Utilisateurs,OU=ECOLE,DC=mediaschool,DC=local" -ErrorAction SilentlyContinue

# 3. Sécurité (Force Logoff) 
$Key = "HKLM\Software\Policies\Microsoft\Windows\LanmanWorkstation"
foreach ($gpo in $GPOs) {
    # CORRECTION : Suppression de "-Context Computer"
    Set-GPRegistryValue -Name $gpo -Key $Key -ValueName "ForceLogoffWhenLogonHoursExpire" -Value 1 -Type DWord
}

Write-Host "GPO Déployées. Configurez le mappage lecteur H: manuellement via GPMC." -ForegroundColor Yellow