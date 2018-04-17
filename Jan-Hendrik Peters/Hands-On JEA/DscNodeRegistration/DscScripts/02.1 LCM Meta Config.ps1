[DSCLocalConfigurationManager()]
Configuration LcmConfiguration
{
    param(
        [Parameter(Mandatory)]
        [string]$PullServer,

        [Parameter(Mandatory)]
        [string]$RegistrationKey,

        [Parameter(Mandatory)]
        [string]$ComputerName,
        
        [string]$MofCertificateThumbprint
    )
    
    Node $ComputerName
    {
        if ($MofCertificateThumbprint)
        {
            Settings
            {
                RefreshMode          = 'Pull'
                RefreshFrequencyMins = 30
                ConfigurationModeFrequencyMins = 15
                ConfigurationMode = 'ApplyAndAutoCorrect'
                RebootNodeIfNeeded   = $true
                CertificateID = $MofCertificateThumbprint
            }
        }
        else
        {
            Settings
            {
                RefreshMode          = 'Pull'
                RefreshFrequencyMins = 30
                ConfigurationModeFrequencyMins = 15
                ConfigurationMode = 'ApplyAndAutoCorrect'
                RebootNodeIfNeeded   = $true
            }
        }
        
        ConfigurationRepositoryWeb PullServer
        {
            ServerURL          = "https://$($PullServer):8080/PSDSCPullServer.svc"
            RegistrationKey    = $RegistrationKey
            ConfigurationNames = "DemoConfig1_$($NodeName.Split('.')[0])"
            #AllowUnsecureConnection = $true
        }
        
        ReportServerWeb ReportServer
        {
            ServerURL       = "https://$($PullServer):8080/PSDSCPullServer.svc"
            RegistrationKey = $RegistrationKey
            #AllowUnsecureConnection = $true
        }
    }
}