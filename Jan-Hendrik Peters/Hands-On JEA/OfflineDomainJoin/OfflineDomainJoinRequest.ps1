param(
    [Parameter(Mandatory)]
    [string]$Server,
 
    [Parameter(Mandatory)]
    [pscredential]$Credential,
 
    [string]$SiteName,
 
    [string]$OrganizationalUnit,
 
    [switch]$PrepopulatePassword,
 
    [switch]$DoNotRestart
)
 
Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $Server -Force
 
$computerName = $env:COMPUTERNAME
$s = New-PSSession -ComputerName $Server -ConfigurationName OfflineDomainJoinProxy -Credential $Credential -ErrorAction Stop
$blob = Invoke-Command -Session $s -ScriptBlock {
    $param = @{
        ComputerName = $using:ComputerName
    }
    
    if ($using:SiteName) { $param.Add('SiteName', $using:SiteName) }
    if ($using:OrganizationalUnit) { $param.Add('OrganizationalUnit', $using:OrganizationalUnit) }
    if ($using:PrepopulatePassword) { $param.Add('PrepopulatePassword', $true) }
 
    Request-ADOfflineDomainJoin @param
}
 
if (-not $blob)
{
    Write-Error 'Failed to retreive blob for offline domain join'
    return
}
 
$tempFile = [System.IO.Path]::GetTempFileName()
$blob | Set-Content -Path $tempFile -Encoding Unicode
 
cmd /c DJOIN /REQUESTODJ /LOADFILE $tempFile /WINDOWSPATH %windir% /LOCALOS
 
Remove-Item -Path $tempFile
 
if (-not $DoNotRestart)
{
    Restart-Computer -Force
}