#$certificateLocation = 'C:\DscMofEncryptionCertificates'

$configurationData = Import-DscConfigurationData -Path $PSScriptRoot\Config -GlobalConfigurationFileName GlobalConfigurationData.psd1 -ErrorAction Stop

<#foreach ($node in $configurationData.AllNodes | Where-Object NodeName -ne '*')
{
    $certificateFile = Get-ChildItem -Path $certificateLocation -Filter "$($node.NodeName)-*.cer"
    $node.CertificateFile = $certificateFile.FullName
}#>

. "$PSScriptRoot\01.1 Dsc Config.ps1"

$configurationData
#Publish-DscConfiguration -ComputerName $configurationData.AllNodes.NodeName -ConfigurationData $configurationData -Configuration (Get-Command -Name DemoConfig1) -OutputPath C:\DscMofs