Configuration WindowsFeatures {
    Param(
        [Parameter(Mandatory)]
        [string[]]$Name
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    #File 'TestFile_WindowsFeatures' {
    #    Ensure          = 'Present'
    #    DestinationPath = 'C:\TestFile_WindowsFeatures.txt'
    #    Contents        = ''
    #}

    $ensure = 'Present'
    foreach ($n in $Name) {
        if ($n[0] -in '-', '+') {
            if ($n[0] -eq '-') {
                $ensure = 'Absent'
            }
            $n = $n.Substring(1)
        }
        WindowsFeature $n {
            Name                 = $n
            Ensure               = $ensure
            IncludeAllSubFeature = $true
        }
    }
}