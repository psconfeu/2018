Configuration WindowsServices {
    Param(
        [Parameter(Mandatory)]
        [hashtable[]]$Services
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    #File 'TestFile_WindowsServices' {
    #    Ensure          = 'Present'
    #    DestinationPath = 'C:\TestFile_WindowsServices.txt'
    #    Contents        = ''
    #}

    foreach ($service in $Services) {
        Service $Service.Name {
            Name        = $service.Name
            Ensure      = 'Present'
            Credential  = New-Object pscredential('Install', ('Somepass1' | ConvertTo-SecureString -AsPlainText -Force))
            DisplayName = $service.DisplayName
            StartupType = $service.StartupType
            State       = 'Running'
            Path        = 'C:\DummyService.exe'
        }
    }
}