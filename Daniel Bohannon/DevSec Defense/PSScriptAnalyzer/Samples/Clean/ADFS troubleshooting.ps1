<#
This Script will check the MSOnline Office 365 setup. It will prompt the user running it to specify the 
credentials. It will then check compare the onsite information with the online information and inform the 
user if it is out of sync. 
#>

$PSAdmin = Read-host "This script needs to be run as Administrator, have you done this? Y or N..."
If($PSAdmin -eq 'Y' -or 'y'){
Add-PSSnapin Microsoft.Adfs.Powershell 
Import-Module MSOnline

$cred = Get-Credential 
Connect-MsolService -credential:$cred

Write-host "Below are the URLs Office 365 uses to connect, these URLs MUST be the same (if they are not then see article http://support.microsoft.com/kb/2647020)..." -foreground "Green"
Get-MsolFederationProperty -domainname:'DomainName.com' | Select-Object 'FederationMetadataUrl'

Write-Host "Below is the certificate information for ADFS, the top section is the onsite information showing the current certificate with serial number. The bottom section shows the Office 365 online certificate details. The serial number MUST be the same. If they are not see article http://support.microsoft.com/kb/2647020..." -foreground 'Green'
Get-MsolFederationProperty -domainname:'DomainName.com' | Select-Object 'TokenSigningCertificate' | fl | Out-Default 

}	Else{
	Write-host "Please close Powershell and re-run it as adminstrator" -foreground "Red"
	Break}

