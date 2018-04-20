Add-PSSnapin Microsoft.Adfs.Powershell 
Import-Module MSOnline

$cred = Get-Credential 
$AdfsServer = Read-Host "Please type the name of the ADFS server"

Write-Host "Connecting to MSOnline..."
Connect-MsolService -credential:$cred
Write-Host "Setting the local ADFS server..."
Set-MSOLADFSContext -Computer:$AdfsServer
Write-Host "Updating the ADFS server configuration..."
Update-MSOLFederatedDomain -DomainName:Domain.com

Write-host "Below is a list of the Federated domains..." -foreground "Green"
Get-MsolDomain 
