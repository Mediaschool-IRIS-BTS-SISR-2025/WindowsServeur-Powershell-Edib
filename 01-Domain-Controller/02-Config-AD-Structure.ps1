# 02-Config-AD-Structure.ps1
# Structure OU et Groupes

Import-Module ActiveDirectory
Write-Host "--- STRUCTURE ACTIVE DIRECTORY ---" -ForegroundColor Cyan

# 1. Zone DNS Inverse 
Add-DnsServerPrimaryZone -NetworkID "192.168.100.0/24" -ReplicationScope Forest -ErrorAction SilentlyContinue

# 2. Structure OU
$Base = "DC=mediaschool,DC=local"
New-ADOrganizationalUnit -Name "ECOLE" -Path $Base
New-ADOrganizationalUnit -Name "Comptes-Utilisateurs" -Path "OU=ECOLE,$Base"
New-ADOrganizationalUnit -Name "Comptes-Ordinateurs" -Path "OU=ECOLE,$Base"
New-ADOrganizationalUnit -Name "Pilotes" -Path "OU=Comptes-Ordinateurs,OU=ECOLE,$Base"
New-ADOrganizationalUnit -Name "Production" -Path "OU=Comptes-Ordinateurs,OU=ECOLE,$Base"

# 3. Départements et Groupes
$Depts = @("Administration", "Profs", "Eleves")
foreach ($d in $Depts) {
    $Path = "OU=Comptes-Utilisateurs,OU=ECOLE,$Base"
    New-ADOrganizationalUnit -Name $d -Path $Path
    New-ADGroup -Name "MS-$d" -GroupScope Global -Path "OU=$d,$Path"
}

# 4. Utilisateurs de Test 
Function New-TestUser ($Name, $OU, $Group) {
    $Pass = ConvertTo-SecureString "Mediaschool2025!" -AsPlainText -Force
    New-ADUser -Name $Name -GivenName $Name -SamAccountName $Name -UserPrincipalName "$Name@mediaschool.local" -Path "OU=$OU,OU=Comptes-Utilisateurs,OU=ECOLE,DC=mediaschool,DC=local" -AccountPassword $Pass -Enabled $true
    Add-ADGroupMember -Identity $Group -Members $Name
}

New-TestUser "Admin1" "Administration" "MS-Administration"
New-TestUser "Prof1" "Profs" "MS-Profs"
New-TestUser "Eleve1" "Eleves" "MS-Eleves"

Write-Host "Utilisateurs créés (Mdp: Mediaschool2025!)" -ForegroundColor Green
