if (-not (Get-Module AutomatedLab -List)) { Install-Module AutomatedLab -AllowClobber -Force}

#region Lab deployment
# The building blocks for a lab: Definition, Machines and the Installation itself
New-LabDefinition -Name psconfJeaDJ -DefaultVirtualizationEngine HyperV

Add-LabDomainDefinition contoso.com -AdminUser install -AdminPassword Somepass1
Set-LabInstallationCredential -User install -Password Somepass1

$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2016 Datacenter'
    'Add-LabMachineDefinition:Memory'          = 2GB
}

$postInstallActivity = @()
$postInstallActivity += Get-LabPostInstallationActivity -ScriptFileName 'New-ADLabAccounts 2.0.ps1' -DependencyFolder $labSources\PostInstallationActivities\PrepareFirstChildDomain
$postInstallActivity += Get-LabPostInstallationActivity -ScriptFileName PrepareRootDomain.ps1 -DependencyFolder $labSources\PostInstallationActivities\PrepareRootDomain

Add-LabMachineDefinition -Name ODJDC01 -Roles RootDC -PostInstallationActivity $postInstallActivity -DomainName contoso.com 

$role = Get-LabMachineRoleDefinition -Role DC @{
    IsReadOnly = 'true'
}
Add-LabMachineDefinition -Name ODJRD01 -Roles $role -DomainName contoso.com
Add-LabMachineDefinition -Name ODJCL01 -OperatingSystem 'Windows Server 2016 Datacenter (Desktop Experience)'

Install-Lab
#endregion
break

Invoke-LabCommand ODJDC01 -ScriptBlock {
    New-ADUser -Name JoinUser -AccountPassword ('Password1' | ConvertTo-SecureString -AsPlainText -Force) -Enabled $true
 
    dsacls "CN=Allowed RODC Password Replication Group,CN=Users,DC=contoso,DC=com" /G "contoso\JoinUser:WP;member;"
    dsacls "OU=Test,DC=contoso,DC=com" /G "contoso\JoinUser:GRGE;computer"
    dsacls "CN=Computers,DC=contoso,DC=com" /G "contoso\JoinUser:GRGE;computer"
} -passthru

Invoke-LabCommand -FilePath '.\Restricted Endpoint LAN.ps1' -ComputerName ODJDC01
Invoke-LabCommand -FilePath '.\Restricted Endpoint DMZ.ps1' -ComputerName ODJRD01
Copy-LabFileItem -Path '.\Restricted Endpoint DMZ.ps1' -ComputerName ODJRD01
Copy-LabFileItem -Path '.\Restricted Endpoint LAN.ps1' -ComputerName ODJDC01
Copy-LabFileItem -Path .\OfflineDomainJoinRequest.ps1 -ComputerName ODJCL01