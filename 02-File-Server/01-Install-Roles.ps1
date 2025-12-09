# 01-Install-Roles.ps1
# FSRM, WSUS, WDS

Write-Host "Installation des rôles (Patience...)" -ForegroundColor Cyan
Install-WindowsFeature -Name File-Services, FS-Resource-Manager, UpdateServices, WDS -IncludeManagementTools
Write-Host "Installation terminée." -ForegroundColor Green