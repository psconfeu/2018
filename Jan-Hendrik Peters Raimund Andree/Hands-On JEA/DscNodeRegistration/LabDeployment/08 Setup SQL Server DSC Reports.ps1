$labName = 'DscLab1'
if (-not (Get-Lab -ErrorAction SilentlyContinue).Name -eq $labName)
{
    Import-Lab -Name $labName -NoValidation
}

$sqlServer = Get-LabVM -Role SQLServer2016 | Select-Object -First 1

#-------------------------------------------------------------------------------------------------

Install-LabSoftwarePackage -Path $labsources\SoftwarePackages\ReportBuilder3.msi -ComputerName $sqlServer
$s = New-LabPSSession -ComputerName $sqlServer
Send-ModuleToPSSession -Module (Get-Module -Name ReportingServicesTools -ListAvailable) -Session $s

Copy-LabFileItem -Path $PSScriptRoot\Reports -ComputerName $sqlServer -DestinationFolderPath C:\ -Recurse -UseAzureLabSourcesOnAzureVm $false

Invoke-LabCommand -ActivityName 'Add DSC Reports to Reporting Server' -ComputerName $sqlServer -ScriptBlock {

    New-RsFolder -ReportServerUri http://localhost/ReportServer -Path / -Name DSC -Verbose
    Write-RsFolderContent -ReportServerUri http://localhost/ReportServer -Path C:\Reports -Destination /DSC -Verbose

    New-RsDataSource -Name DSCDS -ConnectionString 'Server=localhost;Database=DSC;Trusted_Connection=True;' -RsFolder /DSC -Extension SQL -CredentialRetrieval Integrated
    New-RsDataSource -Name DSCDS -ConnectionString 'Server=localhost;Database=DSC;Trusted_Connection=True;' -RsFolder / -Extension SQL -CredentialRetrieval Integrated
}