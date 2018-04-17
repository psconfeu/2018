$labName = 'DscLab1' #THIS NAME MUST BE GLOBALLY UNIQUE

$azureResourceManagerProfile = 'C:\Users\raandree\Desktop\AL1.json' #IF YOU HAVE NO PROFILE FILE, CALL Save-AzureRmContext
$azureDefaultLocation = 'West Europe' #COMMENT OUT -DefaultLocationName BELOW TO USE THE FASTEST LOCATION

New-LabDefinition -Name $labName -DefaultVirtualizationEngine Azure

Add-LabAzureSubscription -Path $azureResourceManagerProfile -DefaultLocationName $azureDefaultLocation

Add-LabVirtualNetworkDefinition -Name $labName -AddressSpace 192.168.10.0/24

Add-LabDomainDefinition -Name contoso.com -AdminUser Install -AdminPassword Somepass1

Set-LabInstallationCredential -Username Install -Password Somepass1

$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network' = $labName
    'Add-LabMachineDefinition:Memory' = 1GB
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2016 SERVERDATACENTER'
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

#CA
Add-LabMachineDefinition -Name dsc1CASQL1 -Memory 4GB -Roles CaRoot, SQLServer2016

#DSC Pull Server
$role = Get-LabMachineRoleDefinition -Role DSCPullServer -Properties @{ DoNotPushLocalModules = 'true'; DatabaseEngine = 'mdb' }
Add-LabMachineDefinition -Name dsc1Pull1 -Memory 2GB -Roles $role

Install-Lab

$machines = Get-LabVM
Install-LabSoftwarePackage -ComputerName $machines -Path $labSources\SoftwarePackages\Notepad++.exe -CommandLine /S -AsJob
Install-LabSoftwarePackage -ComputerName $machines -Path $labSources\SoftwarePackages\winrar.exe -CommandLine /S -AsJob
Install-LabSoftwarePackage -ComputerName (Get-LabVM -Role DSCPullServer) -Path $labSources\SoftwarePackages\PBIDesktop_x64.msi -CommandLine 'ACCEPT_EULA=1'
Get-Job -Name 'Installation of*' | Wait-Job | Out-Null

Install-LabWindowsFeature -ComputerName (Get-LabVM -Role DSCPullServer) -FeatureName RSAT-AD-Tools

Enable-LabCertificateAutoenrollment -Computer -User

#Checkpoint-LabVM -All -SnapshotName 1

Get-ChildItem -Path $PSScriptRoot | Where-Object { $_.Name -match '^\d{2} [\w ]+\.ps1' } | ForEach-Object {
    Write-Host "Calling script $($_.Name)..."
    
    & $_.FullName

    Write-Host "Finished with script $($_.Name)"
    Write-Host
}

#Checkpoint-LabVM -All -SnapshotName 2

Stop-LabVM -All -Wait

Show-LabDeploymentSummary -Detailed