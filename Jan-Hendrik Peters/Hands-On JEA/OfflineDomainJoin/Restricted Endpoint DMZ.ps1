function Request-ADOfflineDomainJoin
{
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,
 
        [string]$SiteName,
 
        [string]$OrganizationalUnit,
 
        [string]$Server = 'zMgmtLan.contoso.com',
 
        [switch]$PrepopulatePassword
    )
 
    $s = New-PSSession -ComputerName $Server -ConfigurationName OfflineDomainJoin
    $blob = Invoke-Command -Session $s -ScriptBlock {
 
        $param = @{
            ComputerName = $using:ComputerName
        }
        if ($using:SiteName) { $param.Add('SiteName', $using:SiteName) }
        if ($using:OrganizationalUnit) { $param.Add('OrganizationalUnit', $using:OrganizationalUnit) }
        if ($using:PrepopulatePassword) { $param.Add('PrepopulatePassword', $true) }
 
        New-ADOfflineDomainJoin @param
    }
 
    $blob
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
 
    $modulesToImport = 'ActiveDirectory'
     
    $path = [System.IO.Path]::GetTempFileName()
    Remove-Item -Path $path
    $path = [System.IO.Path]::ChangeExtension($path, '.pssc')
     
    $endpointName = 'OfflineDomainJoinProxy'
     
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
            Name        = 'Request-ADOfflineDomainJoin'
            ScriptBlock = (Get-Command -Name Request-ADOfflineDomainJoin).ScriptBlock
        }
    )
    New-PSSessionConfigurationFile @param
 
    if ($RunAsUser)
    {
        $cred = New-Object pscredential($RunAsUser, ($RunAsUserPassword | ConvertTo-SecureString -AsPlainText -Force))
    }
     
    $param = @{
        Name  = $endpointName
        Path  = $path
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
        $psscSd.DiscretionaryAcl.AddAccess($accessType, $account.Translate([System.Security.Principal.SecurityIdentifier]), $accessMask, $inheritanceFlags, $propagationFlags)
    }
 
    Set-PSSessionConfiguration -Name $endpointName -SecurityDescriptorSddl $psscSd.GetSddlForm("All") -Force
} 
 
Register-SupportPSSessionConfiguration -UseVirtualAccount -AllowedPrincipals contoso\JoinUser -Force