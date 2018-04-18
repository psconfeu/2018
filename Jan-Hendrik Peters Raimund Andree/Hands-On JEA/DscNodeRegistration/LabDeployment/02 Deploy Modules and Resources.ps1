$labName = 'DscLab1'
if (-not (Get-Lab -ErrorAction SilentlyContinue).Name -eq $labName)
{
    Import-Lab -Name $labName -NoValidation
}

$pullServers = Get-LabVM -Role DSCPullServer
$sqlServer = Get-LabVM -Role SQLServer2016 | Select-Object -First 1

#-------------------------------------------------------------------------------------------------

Copy-LabFileItem -Path $PSScriptRoot\..\DscConfigurationManager -DestinationFolder 'C:\Program Files\WindowsPowerShell\Modules' -ComputerName $pullServers -UseAzureLabSourcesOnAzureVm $false
Copy-LabFileItem -Path $PSScriptRoot\..\CompositeResourceSample -DestinationFolder 'C:\Program Files\WindowsPowerShell\Modules' -ComputerName $pullServers -UseAzureLabSourcesOnAzureVm $false
Copy-LabFileItem -Path "$PSScriptRoot\..\DscScripts" -ComputerName $pullServers -UseAzureLabSourcesOnAzureVm $false

$isLabOnline = Test-LabMachineInternetConnectivity $pullServers[0] -Count 2
$requiredDscModules = 'xDscDiagnostics', 'xPendingReboot', 'xTimezone', 'xSmbShare', 'xStorage', 'xNetworking', 'xComputerManagement', 'xWebAdministration', 'ISESteroids', 'ReportingServicesTools', 'xPSDesiredStateConfiguration'

if ($isLabOnline)
{
    Invoke-LabCommand -ActivityName 'Install required DSC Resources' -ComputerName $pullServers -ScriptBlock {

        Install-PackageProvider -Name NuGet -Force | Out-Null
        Install-Module -Name $requiredDscModules -Force

    } -Variable (Get-Variable -Name requiredDscModules)
}
else
{
    #check for the required modules locally
    if ((Get-Module -ListAvailable -Name $requiredDscModules).Count -eq $requiredDscModules.Count)
    {
        Write-ScreenInfo "The required DSC resource modules ($($requiredDscModules -join ', ')) are found in PSModulePath"
    }
    else
    {
        Install-PackageProvider -Name NuGet -Force | Out-Null
        Install-Module -Name $requiredDscModules -AllowClobber -Confirm:$false
    }
    
    #then copy all of them to the pull servers
    $modules = Get-Module -Name $requiredDscModules -ListAvailable
    foreach ($module in $modules)
    {
        Copy-LabFileItem -Path $module.ModuleBase -ComputerName $pullServers -DestinationFolder "C:\Program Files\WindowsPowerShell\Modules\$($module.Name)" -Recurse -UseAzureLabSourcesOnAzureVm $false
    }
}