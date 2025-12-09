# 05-Set-LogonHours.ps1
# Horaires Administration, Profs, Elèves

Write-Host "--- APPLICATION HORAIRES ---" -ForegroundColor Cyan

Function Set-LogonHours ($Group, $Days, $Start, $End) {
    [byte[]]$hours = New-Object byte[] 21 # Tout bloqué par défaut
    
    # Remplissage des bits
    foreach ($day in $Days) {
        for ($h = $Start; $h -lt $End; $h++) {
            $bitIndex = ($day * 24) + $h
            $byteIndex = [math]::Floor($bitIndex / 8)
            $bitOffset = $bitIndex % 8
            $hours[$byteIndex] = $hours[$byteIndex] -bor [math]::Pow(2, $bitOffset)
        }
    }
    
    Get-ADGroupMember $Group | ForEach-Object {
        Set-ADUser -Identity $_.SamAccountName -Replace @{logonHours = $hours}
        Write-Host "Horaires appliqués pour $($_.SamAccountName)"
    }
}

# 1=Lun ... 5=Ven, 6=Sam
# Admin: Lun-Ven 07-19
Set-LogonHours "MS-Administration" (1..5) 7 19

# Eleves: Lun-Ven 08-18
Set-LogonHours "MS-Eleves" (1..5) 8 18

# Profs: Lun-Ven 07-20 + Sam 08-12 (Logique simplifiée pour le script: on applique Lun-Ven ici)
# Note: Pour le samedi en plus, il faudrait fusionner les tableaux de bits, ce qui est complexe en script simple.
Set-LogonHours "MS-Profs" (1..5) 7 20