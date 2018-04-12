$labCredential = Get-Credential

# Copy module and role-capabilities to remote session
$sessionToRestrict = New-PSSession -ComputerName Restricted01 -Credential $labCredential -Authentication Credssp
Send-ModuleToPSSession -Module (Get-Module PasswordEndpoint -ListAvailable) -Session $sessionToRestrict

# New Session configuration
Invoke-Command -Session $sessionToRestrict -ScriptBlock {
    $roleDefinitions =  @{
        'contoso\PasswordReader' = @{RoleCapabilities = 'Reader'}
        'contoso\PasswordWriter' = @{RoleCapabilities = 'Writer'}
    }

    New-PSSessionConfigurationFile -Path C:\PasswordEndpoint.pssc -RoleDefinitions $roleDefinitions -ModulesToImport PasswordEndpoint -SessionType RestrictedRemoteServer -LanguageMode Full -ExecutionPolicy Unrestricted -Full
    Register-PSSessionConfiguration -Path C:\PasswordEndpoint.pssc -Name PasswordEndpoint -Force
}

<# Prequisites
- Both client and remote system are in possession of DocumentEncryption certificates capable of KeyEncipherment,DataEncipherment, KeyAgreement
- Client and server need to be in possession of the public keys for each other's certificates
#>

# Try out the new endpoint
$passwordSession = New-PSSession -ComputerName Restricted01 -ConfigurationName PasswordEndpoint -Credential $labCredential -Authentication Credssp

Import-PSSession -Session $passwordSession -CommandName Get-Password,Set-Password,Remove-Password,Get-ServerThumbprint
Get-Password # None yet

# There is always a little gap when handling passwords. Secure strings cannot be transported, so you would
# have to decrypt them either way before wrapping in a CMS message. Storing passwords is never a great idea...
Set-Password -ObjectName server01connectionstring -Prefix a.contoso.com -CmsMessage (Protect-CmsMessage -To cn=Restricted01 -Content 'Server=server01;User Id=User;Password=HighSecure!')
$protectedDatum = Get-Password -ObjectName server01connectionstring -Prefix a.contoso.com 
$protectedDatum | Unprotect-CmsMessage
