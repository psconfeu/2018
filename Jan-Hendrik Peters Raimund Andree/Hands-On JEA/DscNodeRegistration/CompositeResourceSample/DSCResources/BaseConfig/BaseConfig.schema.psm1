configuration BaseConfig
{
    param(
        [Parameter(Mandatory)]
        [hashtable]$ConfigData,

        [Parameter(Mandatory)]
        [psobject]$Node
    )

    Import-DscResource -ModuleName xTimeZone, xNetworking, xComputerManagement, xPendingreboot
    
    $currentConfigName = $ExecutionContext.SessionState.Module.Name
    File "ConfigAppliedFile_$currentConfigName"
    {
        DestinationPath = "C:\dsc $currentConfigName applied.txt"
        Contents = Get-Date
        Type = 'File'
        Ensure = 'Present'
    }
        
    xDnsConnectionSuffix NetSettings
    {
        InterfaceAlias = 'Ethernet'
        RegisterThisConnectionsAddress = $true
        ConnectionSpecificSuffix = $ConfigData.DnsSuffix
    }
        
    xTimeZone tz
    {
        IsSingleInstance = 'Yes'
        TimeZone = $Node.Timezone
        DependsOn = '[xDnsConnectionSuffix]NetSettings'
    }
    
    xComputer JoinDomain
    {
        DependsOn = '[xTimeZone]tz'
        Name = $Node.NodeName
        DomainName = $Node.Domain
        Credential = ($ConfigData.Domains.GetEnumerator() | Where-Object Name -eq $Node.Domain).Value.QueryCredentials
    }
    
    Script RebootAfterDomainJoin
    {
        DependsOn = '[xComputer]JoinDomain'
        TestScript = {
            return (Test-Path -Path 'HKLM:\SOFTWARE\DscDcDeployment\RebootAfterDomainJoin')
        }
        SetScript = {
            New-Item -Path 'HKLM:\SOFTWARE\DscDcDeployment\RebootAfterDomainJoin' -Force
            $global:DSCMachineStatus = 1
        }
        GetScript = {
            return @{ result = 'result' }
        }
    }
        
    xPendingReboot WaitFor_RebootAfterDomainJoin
    {
        DependsOn = '[Script]RebootAfterDomainJoin'
        Name = 'WaitFor_RebootAfterDomainJoin'
    }
}