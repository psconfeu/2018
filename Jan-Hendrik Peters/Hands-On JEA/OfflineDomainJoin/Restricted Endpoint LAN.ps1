function New-ADOfflineDomainJoin
{
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,
 
        [string]$SiteName,
 
        [string]$OrganizationalUnit,
 
        [switch]$PrepopulatePassword
    )
     
    $domain = Get-ADDomain -Current LocalComputer
    Write-Host "Current domain is '$($domain.DNSRoot)'"
    $rodcs = $domain.ReadOnlyReplicaDirectoryServers
    Write-Host "$($rodcs.Count) Read-Only Domain Controllers found: $($rodcs -join ', ')"
    $writableDC = (Get-ADDomainController -Writable -Discover).HostName[0]
    Write-Host "Writable Domain Controller is '$writableDC'"
 
    if ($SiteName)
    {
        try
        {
            Get-ADReplicationSite -Identity $SiteName | Out-Null
        }
        catch
        {
            Write-Error "The Active Directory site '$SiteName' could not be found"
            return
        }
    }
 
    if ($OrganizationalUnit)
    {
        try
        {
            Get-ADOrganizationalUnit -Identity $OrganizationalUnit | Out-Null
        }
        catch
        {
            Write-Error "The Active Directory OU '$OrganizationalUnit' could not be found"
            return
        }
    }
 
    Write-Host
    $tempFile = [System.IO.Path]::GetTempFileName()
    Remove-Item -Path $tempFile
    Write-Host "Calling DJOIN.EXE..." -NoNewline
 
    $cmd = 'djoin.exe /provision /domain "{0}" /MACHINE {1} /SAVEFILE {2} /DCName {3}' -f $domain.DNSRoot, $ComputerName, $tempFile, $writableDC
    if ($OrganizationalUnit)
    {
        $cmd += " /MACHINEOU $OrganizationalUnit"
    }
    if ($SiteName)
    {
        $cmd += " /PSITE $SiteName"
    }
 
    Write-Host 'Running the following djoin.exe command:'
    Write-Host $cmd
     
    $djoinResult = &([scriptblock]::Create($cmd))
 
    if ($djoinResult -like '*Computer provisioning completed successfully*')
    {
        Write-Host 'successfull'
    }
    else
    {
        Write-Host "there was an error: $($djoinResult[-2])"
        return
    }
    Write-Host
     
    $computer = Get-ADComputer -Identity $ComputerName -Server $writableDC
    Write-Host "Adding computer account '$ComputerName' to group 'Allowed RODC Password Replication Group'"
    Add-ADGroupMember -Members $computer -Identity 'Allowed RODC Password Replication Group' -Server $writableDC
    Write-Host
 
    if ($PrepopulatePassword)
    {
        foreach ($rodc in $rodcs)
        {
            Write-Host "Prepopulating password for account '$($($computer.DistinguishedName))' to RODC '$rodc' from writable DC '$writableDC'..." -NoNewline
            $repadminResult = repadmin.exe /rodcpwdrepl $rodc $writableDC ""$($computer.DistinguishedName)""
 
            if ($repadminResult -like '*Successfully replicated secrets*')
            {
                Write-Host 'successfull'
            }
            else
            {
                Write-Host 'error'
 
                Write-Error ($repadminResult -join '. ')
                return
            }
        }
        Write-Host
    }
 
    Get-Content -Path $tempFile
    Remove-Item -Path $tempFile
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
     
    $endpointName = 'OfflineDomainJoin'
     
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
            Name        = 'New-ADOfflineDomainJoin'
            ScriptBlock = (Get-Command -Name New-ADOfflineDomainJoin).ScriptBlock
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
 
Register-SupportPSSessionConfiguration -RunAsUser contoso\OfflineDomainJoin -RunAsUserPassword Password1 -AllowedPrincipals contoso\zMgmtRodcs$ -Force