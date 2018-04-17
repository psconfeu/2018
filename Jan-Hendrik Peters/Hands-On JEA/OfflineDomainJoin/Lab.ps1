if (-not (Get-Module AutomatedLab -List)) { Install-Module AutomatedLab -AllowClobber -Force}

#region Lab deployment
# The building blocks for a lab: Definition, Machines and the Installation itself
New-LabDefinition -Name psconfJeaDJ -DefaultVirtualizationEngine HyperV

Add-LabDomainDefinition contoso.com -AdminUser install -AdminPassword Somepass1
Set-LabInstallationCredential -User install -Password Somepass1

Add-LabVirtualNetworkDefinition -Name psconfJeaDJInternal -AddressSpace 192.168.55.0/24
Add-LabVirtualNetworkDefinition -Name psconfJeaDJDMZ -AddressSpace 192.168.66.0/24

$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2016 Datacenter'
    'Add-LabMachineDefinition:Memory'          = 2GB
}

$postInstallActivity = @()
$postInstallActivity += Get-LabPostInstallationActivity -ScriptFileName 'New-ADLabAccounts 2.0.ps1' -DependencyFolder $labSources\PostInstallationActivities\PrepareFirstChildDomain
$postInstallActivity += Get-LabPostInstallationActivity -ScriptFileName PrepareRootDomain.ps1 -DependencyFolder $labSources\PostInstallationActivities\PrepareRootDomain

$adapters = @(
    New-LabNetworkAdapterDefinition -VirtualSwitch psconfJeaDJInternal -Ipv4Address 192.168.55.10
    New-LabNetworkAdapterDefinition -VirtualSwitch psconfJeaDJDMZ -Ipv4Address 192.168.66.10
)
Add-LabMachineDefinition -Name ODJDC01 -Roles RootDC -PostInstallationActivity $postInstallActivity -NetworkAdapter $adapters -DomainName contoso.com 

$role = Get-LabMachineRoleDefinition -Role DC @{
    IsReadOnly = 'true'
}
Add-LabMachineDefinition -Name ODJRD01 -Roles $role -Network psconfJeaDJDMZ -DomainName contoso.com -DnsServer1 192.168.55.10 -IpAddress 192.168.66.11
Add-LabMachineDefinition -Name ODJCL01 -OperatingSystem 'Windows Server 2016 Datacenter (Desktop Experience)' -Network psconfJeaDJDMZ -DnsServer1 192.168.66.11

Install-Lab
#endregion
break