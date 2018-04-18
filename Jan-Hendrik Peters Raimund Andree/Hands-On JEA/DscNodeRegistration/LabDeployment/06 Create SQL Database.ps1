$labName = 'DscLab1'
if (-not (Get-Lab -ErrorAction SilentlyContinue).Name -eq $labName)
{
    Import-Lab -Name $labName -NoValidation
}

$pullServers = Get-LabVM -Role DSCPullServer
$sqlServer = Get-LabVM -Role SQLServer2016 | Select-Object -First 1

#-------------------------------------------------------------------------------------------------

Copy-LabFileItem -Path "$labSources\PostInstallationActivities\SetupDscPullServer\CreateDscSqlDatabase.ps1" -ComputerName $sqlServer

$pullServerNames = $pullServers | ForEach-Object { '{0}\{1}' -f $_.DomainName.Split('.')[0], $_.Name }
Invoke-LabCommand -ComputerName $sqlServer -ActivityName 'Creating DSC Database' -ScriptBlock {
    
    C:\CreateDscSqlDatabase.ps1 -DomainAndComputerName $pullServerNames
    
} -Variable (Get-Variable -Name pullServerNames)