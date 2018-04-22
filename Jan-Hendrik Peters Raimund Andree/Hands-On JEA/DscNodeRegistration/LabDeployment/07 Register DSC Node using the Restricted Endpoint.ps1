$labName = 'DscLab1'
if (-not (Get-Lab -ErrorAction SilentlyContinue).Name -eq $labName)
{
    Import-Lab -Name $labName -NoValidation
}

$pullServers = Get-LabVM -Role DSCPullServer
$nodes = Get-LabVM | Where-Object Name -like *Node*

#-------------------------------------------------------------------------------------------------

function Connect-DscRegistrationSession
{
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,
        
        [string]$EndpointName = 'DscRegistration'
    )

    $s = New-PSSession -ComputerName $ComputerName -ConfigurationName $EndpointName -ErrorAction SilentlyContinue

    if (-not $s)
    {
        Write-Error "The session to $ComputerName could not be created"
        return
    }

    Import-PSSession -Session $s | Out-Null

    Write-Host "Session to $ComputerName created and published the following commands:"
    $commands = Get-Command "*$ComputerName*"
    foreach ($command in $commands)
    {
        Write-Host $command.Name
    }
}

function Request-ClientDscNodeRegistration
{
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,
        
        [string]$EndpointName = 'DscRegistration'
    )
    
    $metaMofFolder = 'C:\Dsc'
    
    $InformationPreference = 2
    $VerbosePreference = 2

    $s = New-PSSession -ComputerName $ComputerName -ConfigurationName $EndpointName -ErrorAction SilentlyContinue

    if (-not $s)
    {
        Write-Error "The session to $ComputerName could not be created"
        return
    }
    
    $certificate = Get-ChildItem -Path Cert:\LocalMachine\My |
    Where-Object { $_.EnhancedKeyUsageList.FriendlyName -contains 'Document Encryption' } |
    Sort-Object -Property NotAfter -Descending |
    Select-Object -First 1
    
    $metaMofContent = Invoke-Command -Session $s -ScriptBlock {
        Register-ServerDscNode -ComputerName $args[0] -AgentId $args[1] -TimeZone $args[2] -Certificate $args[3]
    } -ArgumentList $env:COMPUTERNAME, (Get-DscLocalConfigurationManager).AgentId, (Get-TimeZone).Id, $certificate.RawData -Verbose
    
    if (-not (Test-Path -Path $metaMofFolder))
    {
        mkdir -Path $metaMofFolder | Out-Null
    }
    
    $metaMofContent | Set-Content -Path (Join-Path -Path $metaMofFolder -ChildPath "$($env:COMPUTERNAME).meta.mof")
    
    Set-DscLocalConfigurationManager -Path $metaMofFolder -Force -Verbose

    Update-DscConfiguration -Wait -Verbose
}

Invoke-LabCommand -ActivityName 'Register DSC Nodes with Pull Server' -ComputerName dsc1node01 -ScriptBlock {
    Request-ClientDscNodeRegistration -ComputerName $pullServers -Verbose
} -Variable (Get-Variable -Name pullServers) -Function (Get-Command -Name Request-ClientDscNodeRegistration, Connect-DscRegistrationSession) -ThrottleLimit 1