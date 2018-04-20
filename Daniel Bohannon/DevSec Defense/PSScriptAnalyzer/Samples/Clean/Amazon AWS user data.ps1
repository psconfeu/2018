<powershell>

$ComputerName = $env:COMPUTERNAME
$user = [adsi]"WinNT://$ComputerName/Administrator,user"
$user.setpassword("Password")

</powershell>
