# PSConf EU 2018

# AutomatedLab
New-LabDefinition -Name Small -DefaultVirtualizationEngine HyperV
Add-LabMachineDefinition -Name SizeZero -OperatingSystem 'Windows Server 2016 Datacenter'
Install-Lab

# What about passwords to log into the machines?
Connect-LabVm SizeZero # Not required
Enter-LabPSSession SizeZero # Also not required
Invoke-LabCommand SizeZero -ScriptBlock {
    "From $env:COMPUTERNAME with love!"
} -PassThru # This also does not prompt you

# Can I automate installing stuff there?
Install-LabWindowsFeature -ComputerName SizeZero `
                          -FeatureName FS-DFS-Replication `
                          -IncludeManagementTools
Install-LabSoftwarePackage -Path $labsources\SoftwarePackages\Notepad++.exe -CommandLine /S

# You can also download stuff and use this with Install-LabSoftwarePackage
$file = Get-LabInternetFile -PassThru -uri 'https://github.com/AutomatedLab/AutomatedLab/releases/download/v5.0.2.4/AutomatedLab.msi'
$file.Fullname

# What is this labsources folder?
Get-ChildItem $labsources
New-LabSourcesFolder -Force

# Working with labs
Import-Lab ALLovesLinux -NoValidation

Get-LabVM -All -IncludeLinux
Start-LabVm -All
Invoke-LabCommand LINCN1,LINDC1 -ScriptBlock {
    $PSVersionTable | Out-Host
} -PassThru

Checkpoint-LabVM -SnapshotName IAmAfraid -All

Restart-LabVM -Wait LINDC1

# In case an installation executes a reboot, you can wait for it
Wait-LabVMRestart -ComputerName LINDC1 -TimeoutInMinutes 1337

# Our Roles
[enum]::GetValues([AutomatedLab.Roles])

# Extend it with custom role definitions
start $labsources\CustomRoles
Get-LabPostInstallationActivity -CustomRole DemoCustomRole

# Common functionality you can use without a lab
Get-Command –Module AutomatedLab.Common
$param = @{ 
    Path = "D:\temp"
    DoesNot = "Compute"
    }
$fixedParameters = Sync-Parameter -Command (Get-Command new-Item) -Parameters $param
New-Item @fixedParameters -Name someFile

$s = New-LabPSSession -ComputerName LINDC1
$s.GetType().FullName # Standard Session
$good = "Stuff"
Add-VariableToPSSession -Session $s -PSVariable (Get-Variable good)
Add-FunctionToPSSession -Session $s -FunctionInfo (Get-Command Sync-Parameter)
Send-ModuleToPSSession -Session $s -Module (Get-Module dbatools -ListAvailable | Select -First 1)

Invoke-Command -Session $s -ScriptBlock {
    $good # No using necessary
    
    $param = @{  # Works as well
    Path = "C:\"
    DoesNot = "Compute"
    Force = $true
    }
    $fixedParameters = Sync-Parameter -Command (Get-Command new-Item) -Parameters $param
    New-Item @fixedParameters -Name someFile

    (Get-Command -Module dbatools).Count # Hell yeah
}
