rmo *
$labName = 'DscLab1'

#--------------------------------------------------------------------------------------------------------------------
#----------------------- CHANGING ANYTHING BEYOND THIS LINE SHOULD NOT BE REQUIRED ----------------------------------
#----------------------- + EXCEPT FOR THE LINES STARTING WITH: REMOVE THE COMMENT TO --------------------------------
#----------------------- + EXCEPT FOR THE LINES CONTAINING A PATH TO AN ISO OR APP   --------------------------------
#--------------------------------------------------------------------------------------------------------------------

New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV

Add-LabVirtualNetworkDefinition -Name External -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'Wi-Fi' }
Add-LabVirtualNetworkDefinition -Name $labName

Add-LabDomainDefinition -Name contoso.com -AdminUser Install -AdminPassword Somepass1

Add-LabIsoImageDefinition -Name SQLServer2016 -Path $labSources\ISOs\en_sql_server_2016_enterprise_x64_dvd_8701793.iso
Add-LabIsoImageDefinition -Name TFS2017 -Path $labsources\ISOs\en_team_foundation_server_2017_x64_dvd_9579548.iso

Set-LabInstallationCredential -Username Install -Password Somepass1

$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network' = $labName
    'Add-LabMachineDefinition:Memory' = 1GB
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2016 Datacenter (Desktop Experience)'
    'Add-LabMachineDefinition:UserLocale' = 'en-US'
    'Add-LabMachineDefinition:DomainName' = 'contoso.com'
}

Add-LabMachineDefinition -Name dsc1DC1 -Roles RootDC

1..5 | ForEach-Object {
    $machineName = 'dsc1Node{0:D2}' -f $_
    Add-LabDiskDefinition -Name "$($machineName)Drive1" -DiskSizeInGb 40 -SkipInitialize
    Add-LabDiskDefinition -Name "$($machineName)Drive2" -DiskSizeInGb 40 -SkipInitialize

    Add-LabMachineDefinition -Name $machineName -DiskName "$($machineName)Drive1", "$($machineName)Drive2"
}

#CA, SQL and Router
$netAdapter = @()
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch $labName #-Ipv4Address "$nextIp/$prefix"
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch External -UseDhcp
Add-LabMachineDefinition -Name dsc1CASQL1 -Memory 4GB -Roles CaRoot, SQLServer2016, Routing -NetworkAdapter $netAdapter

#DSC Pull Server
$role = Get-LabMachineRoleDefinition -Role DSCPullServer -Properties @{ DoNotPushLocalModules = 'true'; DatabaseEngine = 'mdb' }
Add-LabMachineDefinition -Name dsc1Pull1 -Memory 2GB -Roles $role

# Build Server
Add-LabMachineDefinition -Name dsc1Tfs1 -Memory 2GB -Roles Tfs2017

Install-Lab

$machines = Get-LabVM
Install-LabSoftwarePackage -ComputerName $machines -Path $labSources\SoftwarePackages\Notepad++.exe -CommandLine /S -AsJob
Install-LabSoftwarePackage -ComputerName $machines -Path $labSources\SoftwarePackages\winrar.exe -CommandLine /S -AsJob
Install-LabSoftwarePackage -ComputerName (Get-LabVM -Role DSCPullServer) -Path $labSources\SoftwarePackages\PBIDesktop_x64.msi -CommandLine 'ACCEPT_EULA=1'
Get-Job -Name 'Installation of*' | Wait-Job | Out-Null

Install-LabWindowsFeature -ComputerName (Get-LabVM -Role DSCPullServer) -FeatureName RSAT-AD-Tools

Enable-LabCertificateAutoenrollment -Computer -User

Checkpoint-LabVM -All -SnapshotName 1

Get-ChildItem -Path $PSScriptRoot | Where-Object { $_.Name -match '^\d{2} [\w ]+\.ps1' } | ForEach-Object {
    Write-Host "Calling script $($_.Name)..."
    
    & $_.FullName

    Write-Host "Finished with script $($_.Name)"
    Write-Host
}

Checkpoint-LabVM -All -SnapshotName 2

Show-LabDeploymentSummary -Detailed