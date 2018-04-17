$lcmConfigPath = 'C:\DscClientConfig'

$configurationData = Import-DscConfigurationData $PSScriptRoot\Config -GlobalConfigurationFileName GlobalConfigurationData.psd1 -ErrorAction Stop

. "$PSScriptRoot\02.1 LCM Meta Config.ps1"

$computerName = $configurationData.AllNodes.NodeName
foreach ($node in $configurationData.AllNodes | Where-Object NodeName -ne '*')
{
    $certificateFile = Get-ChildItem -Path C:\MofEncCertificates -Filter "$($node.NodeName)*"
    if ($certificateFile)
    {
        $node.CertificateFile = $certificateFile.FullName
    }
}

$registrationKey = Get-Content -Path 'C:\Program Files\WindowsPowerShell\DscService\RegistrationKeys.txt'

foreach ($node in $configurationData.AllNodes | Where-Object NodeName -ne '*')
{
    $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($node.CertificateFile)
    LcmConfiguration -OutputPath $lcmConfigPath -PullServer dsc1Pull1.contoso.com -RegistrationKey $registrationKey -MofCertificateThumbprint $certificate.Thumbprint -ComputerName $node.NodeName | Out-Null
}

Set-DscLocalConfigurationManager -Path $lcmConfigPath -Credential $cred -Force -Verbose

Update-DscConfiguration -ComputerName $computerName -Credential $cred -Wait -Verbose