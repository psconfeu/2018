configuration FileServerConfig
{
    param(
        [Parameter(Mandatory)]
        [hashtable]$ConfigData
    )
    
    Import-DscResource -ModuleName xSmbShare
    
    $currentConfigName = $ExecutionContext.SessionState.Module.Name
    File "ConfigAppliedFile_$currentConfigName"
    {
        DestinationPath = "C:\dsc $currentConfigName applied.txt"
        Contents = Get-Date
        Type = 'File'
        Ensure = 'Present'
    }
    
    File DataShareFolder
    {
        DestinationPath = $ConfigData.SharePath
        Ensure = 'Present'
        Type = 'Directory'
    }

    xSmbShare DataShare
    {
        Name = $ConfigData.ShareName
        Path = $ConfigData.SharePath
        FullAccess = 'Everyone'
        DependsOn = '[File]DataShareFolder'
    }

    foreach ($share in $ConfigData.Roles.FileServers.Shares)
    {
        File "DataShareFolder_$($share.Name)"
        {
            DestinationPath = $Share.Path
            Ensure = 'Present'
            Type = 'Directory'
        }

        xSmbShare "DataShare_$($share.Name)"
        {
            Name = $Share.Name
            Path = $Share.Path
            FullAccess = 'Everyone'
            DependsOn = "[File]DataShareFolder_$($share.Name)"
        }
    }
}