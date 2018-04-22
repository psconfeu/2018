if (-not (Get-Module AutomatedLab -List)) { Install-Module AutomatedLab -AllowClobber -Force}

Set-Location $PSScriptRoot
break
#region Lab deployment
# The building blocks for a lab: Definition, Machines and the Installation itself
New-LabDefinition -Name psconfJeaPw -DefaultVirtualizationEngine HyperV

Add-LabDomainDefinition contoso.com -AdminUser install -AdminPassword Somepass1
Set-LabInstallationCredential -User install -Password Somepass1

$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2016 Datacenter'
    'Add-LabMachineDefinition:DomainName'      = 'contoso.com'
    'Add-LabMachineDefinition:Memory'          = 2GB
}

$postInstallActivity = @()
$postInstallActivity += Get-LabPostInstallationActivity -ScriptFileName 'New-ADLabAccounts 2.0.ps1' -DependencyFolder $labSources\PostInstallationActivities\PrepareFirstChildDomain
$postInstallActivity += Get-LabPostInstallationActivity -ScriptFileName PrepareRootDomain.ps1 -DependencyFolder $labSources\PostInstallationActivities\PrepareRootDomain
Add-LabMachineDefinition -Name DC01 -Roles RootDC -PostInstallationActivity $postInstallActivity
Add-LabMachineDefinition -Name CA01 -Roles CARoot
Add-LabMachineDefinition -Name PW01 # Our member server which will host the endpoint
Add-LabMachineDefinition -Name CL01 -OperatingSystem 'Windows Server 2016 Datacenter (Desktop Experience)' # The client we'll use

Install-Lab

Show-LabDeploymentSummary
#endregion

Checkpoint-LabVm -All -SnapshotName BeforeCustomization
break

Import-Lab psconfjeapw -NoValidation
Start-LabVm -All
Install-LabWindowsFeature -FeatureName RSAT-AD-Tools -ComputerName PW01 -IncludeAllSubFeature -NoDisplay

#region Post-Deployment tasks
Invoke-LabCommand -ComputerName DC01 -ScriptBlock {
    New-ADGroup -Name PasswordReader -GroupScope Global -PassThru | Add-ADGroupMember -Members dev
    New-ADGroup -Name PasswordWriter -GroupScope Global -PassThru | Add-ADGroupMember -Members install    
}

New-LabCATemplate -TemplateName CmsDocEnc `
    -SourceTemplateName 'CEPEncryption' `
    -ApplicationPolicy 'Document Encryption' `
    -KeyUsage KEY_AGREEMENT, KEY_ENCIPHERMENT, DATA_ENCIPHERMENT `
    -EnrollmentFlags Autoenrollment -SamAccountName 'Domain Computers','Domain Users' -ComputerName CA01 -ErrorAction Stop

Enable-LabCertificateAutoenrollment -Computer -User

$client = Get-LabVm -ComputerName CL01
$server = Get-LabVm -ComputerName PW01
$serverCertificate = Request-LabCertificate -Subject "CN=$($server.FQDN)" -TemplateName CmsDocEnc -PassThru -ComputerName $server
$clientCertificate = Request-LabCertificate -Subject "CN=install,CN=Users,DC=contoso,DC=com" -TemplateName CmsDocEnc -PassThru -ComputerName $client

Invoke-LabCommand -ActivityName 'Storing Certificate' -ComputerName PW01 -ScriptBlock {
    [System.IO.File]::WriteAllBytes('C:\CmsCert.cer', $clientCertificate.RawData)
    Import-Certificate -FilePath C:\CmsCert.cer -CertStoreLocation Cert:\LocalMachine\My

} -Variable (Get-Variable -Name clientCertificate) -PassThru

Invoke-LabCommand -ActivityName 'Storing Certificate' -ComputerName CL01 -ScriptBlock {
    [System.IO.File]::WriteAllBytes('C:\CmsCert.cer', $serverCertificate.RawData)
    Import-Certificate -FilePath C:\CmsCert.cer -CertStoreLocation Cert:\LocalMachine\My
} -Variable (Get-Variable -Name serverCertificate) -PassThru

#endregion

break

#region JEA endpoint configuration

<# Prequisites
- Both client and remote system are in possession of DocumentEncryption certificates capable of KeyEncipherment,DataEncipherment, KeyAgreement
- Client and server need to be in possession of the public keys for each other's certificates
#>

# Copy module and role-capabilities to remote session
$sessionToRestrict = New-LabPSSession -ComputerName PW01
Send-ModuleToPSSession -Module (Get-Module PasswordEndpoint -ListAvailable) `
-Session $sessionToRestrict

# New Session configuration
Invoke-Command -Session $sessionToRestrict -ScriptBlock {
    $roleDefinitions =  @{
        'contoso\PasswordReader' = @{RoleCapabilities = 'Reader'}
        'contoso\PasswordWriter' = @{RoleCapabilities = 'Writer'}
    }

    New-PSSessionConfigurationFile -Path C:\PasswordEndpoint.pssc -RoleDefinitions $roleDefinitions `
    -ModulesToImport PasswordEndpoint -SessionType RestrictedRemoteServer -LanguageMode Full -ExecutionPolicy Unrestricted -Full -VisibleProviders FileSystem
    Register-PSSessionConfiguration -Path C:\PasswordEndpoint.pssc -Name PasswordEndpoint -Force
}

# Try out the new endpoint from our Client
$labCredential = (Get-Lab).Domains[0].GetCredential()
$clientSession = New-LabPSSession -ComputerName CL01
Add-VariableToPSSession -Session $clientSession -PSVariable (Get-Variable labCredential)

Enter-PSSession $clientSession

$passwordSession = New-PSSession -ComputerName PW01 -ConfigurationName PasswordEndpoint -Credential $labCredential -Authentication Credssp

Import-PSSession -Session $passwordSession -CommandName Get-Password,Set-Password,Remove-Password,Get-ServerThumbprint

# None yet
Get-Password -ObjectName server01connectionstring -Prefix a.contoso.com

# There is always a little gap when handling passwords. Secure strings cannot be transported, so you would
# have to decrypt them either way before wrapping in a CMS message. Storing passwords is never a great idea...
$encryptedMessage = Protect-CmsMessage -To cn=PW01.contoso.com -Content 'Server=server01;User Id=User;Password=HighSecure!'
Set-Password -ObjectName server01connectionstring -Prefix a.contoso.com `
            -CmsMessage $encryptedMessage -Verbose
$protectedDatum = Get-Password -ObjectName server01connectionstring -Prefix a.contoso.com
$protectedDatum | Unprotect-CmsMessage
#endregion
