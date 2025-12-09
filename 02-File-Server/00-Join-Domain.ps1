# 00-Join-Domain.ps1
# Jonction au domaine

$Domain = "mediaschool.local"
Write-Host "Jonction au domaine $Domain..." -ForegroundColor Yellow

# Demande les identifiants (Entrer: MEDIASCHOOL\Administrateur + Mdp)
$Cred = Get-Credential

Add-Computer -DomainName $Domain -Credential $Cred -Restart -Force