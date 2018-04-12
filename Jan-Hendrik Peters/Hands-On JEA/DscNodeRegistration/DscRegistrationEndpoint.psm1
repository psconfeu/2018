function Register-ServerDscNode
{
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,
        
        [Parameter(Mandatory)]
        [string]$AgentId,
        
        [Parameter(Mandatory)]
        [string]$TimeZone,
        
        #[Parameter(Mandatory)]
        [byte[]]$Certificate
    )
    
    $VerbosePreference = 2
    $InformationPreference = 2
    
    Import-Module -Name DscConfigurationManager
    
    $certificateLocation = 'C:\DscMofEncryptionCertificates'
    $dscConfigurationFile = 'C:\DscScripts\01.1 Dsc Config.ps1'
    $dscMetaConfigurationFile = 'C:\DscScripts\02.1 LCM Meta Config.ps1'
    $dscConfigurationName = 'DemoConfig1'
    $dscConfigurationDataLocation = 'C:\DscScripts\Config'
    
    '{0};{1};{2}' -f $PSSenderInfo.ConnectedUser, (Get-Date), $MyInvocation.MyCommand.Name | Out-File C:\log.txt -Append
  
    
    if (-not (Test-Path -Path $certificateLocation))
    {
        mkdir -Path $certificateLocation | Out-Null
    }
    
    $certificateFileName = '{0}-{1}.cer' -f $ComputerName, $AgentId
    $certificateFileName = Join-Path -Path $certificateLocation -ChildPath $certificateFileName
    $x509Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(,$Certificate)
    [System.IO.File]::WriteAllBytes($certificateFileName, $x509Certificate.RawData)
    Write-Verbose "Certificate was written to '$certificateFileName'"

    Write-Verbose "Importing configuration from '$dscConfigurationFile'..."
    . $dscConfigurationFile
    Write-Verbose 'finished importing the configuration'
    
    $data = Import-DscConfigurationData -Path $dscConfigurationDataLocation -GlobalConfigurationFileName GlobalConfigurationData.psd1 -ErrorAction Stop
    
    ($data.AllNodes | Where-Object NodeName -eq $ComputerName).CertificateFile = $certificateFileName
    
    Publish-DscConfiguration -ComputerName $ComputerName -ConfigurationData $data -Configuration (Get-Command -Name $dscConfigurationName) -OutputPath C:\DscMofs -Confirm:$false
    
    #--------------------------------------------------------------------------------------
    
    $pullServer = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName

    . $dscMetaConfigurationFile
    $registrationKey = Get-Content -Path 'C:\Program Files\WindowsPowerShell\DscService\RegistrationKeys.txt'
    
    $metaMofFile = LcmConfiguration -OutputPath c:\DscClientConfig -PullServer $pullServer -RegistrationKey $registrationKey -MofCertificateThumbprint $x509Certificate.Thumbprint -ComputerName $computerName
    $metaMofFile | Get-Content
    
    #--------------------------------------------------------------------------------------
            
    '{0};{1};{2}' -f $PSSenderInfo.ConnectedUser, (Get-Date), $MyInvocation.MyCommand.Name | Out-File C:\log.txt -Append
}

function Register-SupportPSSessionConfiguration
{
    param(
        [Parameter(Mandatory, ParameterSetName = 'UserAccount')]
        [string]$RunAsUser,

        [Parameter(Mandatory, ParameterSetName = 'UserAccount')]
        [string]$RunAsUserPassword,
        
        [Parameter(Mandatory, ParameterSetName = 'VirtualAccount')]
        [switch]$UseVirtualAccount,

        [string[]]$AllowedPrincipals,
        
        [switch]$Force
    )
    
    $path = [System.IO.Path]::GetTempFileName()
    Remove-Item -Path $path
    $path = [System.IO.Path]::ChangeExtension($path, '.pssc')
    
    $modulesToImport = 'PSScheduledJob', 'Microsoft.PowerShell.Management', 'DscConfigurationBuilder', 'xPSDesiredStateConfiguration', 'PSDesiredStateConfiguration', 'Microsoft.PowerShell.Archive'
    $endpointName = 'DscRegistration'
    
    if ($Force -and (Get-PSSessionConfiguration -Name $endpointName -ErrorAction SilentlyContinue))
    {
        Get-PSSessionConfiguration -Name $endpointName | Unregister-PSSessionConfiguration
    }

    $param = @{}
    $param.Add('Path', $path)
    $param.Add('ModulesToImport', $modulesToImport)
    $param.Add('SessionType', 'Default')
    $param.Add('LanguageMode', 'FullLanguage')
    $param.Add('VisibleProviders', 'FileSystem')
    $param.Add('ExecutionPolicy', 'Unrestricted')
    $param.Add('Full', $true)
    
    if ($UseVirtualAccount) { $param.Add('RunAsVirtualAccount', $true) }
    $param.Add('FunctionDefinitions', @{
            Name = 'Register-ServerDscNode'
            ScriptBlock = (Get-Command -Name Register-ServerDscNode).ScriptBlock
        }
    )
    New-PSSessionConfigurationFile @param

    if ($RunAsUser)
    {
        $cred = New-Object pscredential($RunAsUser, ($RunAsUserPassword | ConvertTo-SecureString -AsPlainText -Force))
    }
    
    $param = @{
        Name = $endpointName
        Path = $path
        Force = $Force
    }
    if ($RunAsUser) { $param.Add('RunAsCredential', $cred) }
    try
    {
        Register-PSSessionConfiguration @param -ErrorAction Stop
    }
    catch
    {
        Write-Error -Exception $_.Exception
        return
    }
    finally
    {
        Remove-Item -Path $path
    }

    $pssc = Get-PSSessionConfiguration -Name $endpointName
    $psscSd = New-Object System.Security.AccessControl.CommonSecurityDescriptor($false, $false, $pssc.SecurityDescriptorSddl)

    foreach ($allowedPrincipal in $AllowedPrincipals)
    {
        $account = New-Object System.Security.Principal.NTAccount($allowedPrincipal)
        $accessType = "Allow"
        $accessMask = 268435456
        $inheritanceFlags = "None"
        $propagationFlags = "None"
        $psscSd.DiscretionaryAcl.AddAccess($accessType,$account.Translate([System.Security.Principal.SecurityIdentifier]),$accessMask,$inheritanceFlags,$propagationFlags)
    }

    Set-PSSessionConfiguration -Name $endpointName -SecurityDescriptorSddl $psscSd.GetSddlForm("All") -Force
}