configuration DemoConfig1
{
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, CompositeResourceSample
    
    $selectedNode = $ConfigurationData.AllNodes.Where({ $_.NodeName -eq $ComputerName })
    Node $selectedNode.NodeName
    {
        BaseConfig base1
        {
            ConfigData = $ConfigurationData
            Node = $Node
        }
        
        if ($Node.Role -eq 'FileServer')
        {
            FileServerConfig file
            {
                DependsOn = '[BaseConfig]base1'
                ConfigData = $configurationData
            } 
        }
        
        if ($Node.Role -eq 'WebServer')
        {
            WebServerConfig web
            {
                DependsOn = '[BaseConfig]base1'
                ConfigData = $configurationData
            }
        }
        
        # For reporting  testing
        1..25 | ForEach-Object {
            File "TestFile_$_"
            {
                Ensure = 'Present'
                DestinationPath = "C:\ReportingTest\TestFile$_.txt"
                Contents = "123"
            }
        }
    }
}