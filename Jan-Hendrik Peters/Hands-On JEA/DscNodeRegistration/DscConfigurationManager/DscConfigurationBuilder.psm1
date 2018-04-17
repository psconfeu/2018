function Get-DscBuilderConfiguration
{
    param(
        [scriptblock]$ConfigurationName
    )
    
    if ($ConfigurationName)
    {
        Get-Command -Name "New-Dsc_$($ConfigurationName)" -Module DscConfigurationBuilder -ErrorAction SilentlyContinue
        if (-not $functions)
        {
            Write-Error "The function 'New-Dsc_$($ConfigurationName)' could not be found."
            return
        }
    }
    else
    {
        Get-Command -Name New-Dsc_* -Module DscConfigurationBuilder
    }
}

function Remove-DscLocalConfigurationManagerConfiguration
{
    param(
        [string[]]$ComputerName = 'localhost',
        
        [pscredential]$Credential
    )

    [DSCLocalConfigurationManager()]
    configuration LcmDefaultConfiguration
    {
        param(
            [string[]]$ComputerName = 'localhost'
        )
    
        Node $ComputerName
        {
            Settings
            {
                RefreshMode = 'Push'
                ConfigurationModeFrequencyMins = 15
                ConfigurationMode = 'ApplyAndMonitor'
                RebootNodeIfNeeded = $true
            }
        }
    }
    
    foreach ($c in $ComputerName)
    {
        $path = mkdir -Path "$([System.IO.Path]::GetTempPath())\$(New-Guid)"
        
        $param = @{
            ComputerName = $c
        }
        if ($Credential)
        {
            $param.Add('Credential', $Credential)
        }
        $session = New-CimSession @param -ErrorAction Stop
    
        Remove-DscConfigurationDocument -Stage Current, Pending -CimSession $session
        LcmDefaultConfiguration -ComputerName $c -OutputPath $path.FullName | Out-Null
        
        $param = @{
            Path =  $path.FullName
            ComputerName = $ComputerName
        }
        if ($Credential)
        {
            $param.Add('Credential', $Credential)
        }
        
        Set-DscLocalConfigurationManager @param

        Remove-Item -Path $path.FullName -Recurse -Force

        try
        {
            Test-DscConfiguration -ComputerName $ComputerName -ErrorAction Stop
            Write-Error 'There was a problem resetting the Local Configuration Manger configuration'
        }
        catch
        {
            Write-Host 'DSC Local Configuration Manger was reset to default values'
        }
        
        $session | Remove-CimSession
    }
}