param(
$searchBase = "OU=Organisation,DC=uza,DC=local",
$NewOUs = @(Import-csv -Path "d:\\projects\\AD\\departments.csv" -Delimiter ";"),
$SubOUs = @("Computers","Users"),
[switch]$ProtectOU
)
$Protect = $false
If ($ProtectOU){$Protect = $true}

foreach ($NewOU in $NewOUs){
New-ADOrganizationalUnit -Name $NewOU.name -Description $NewOU.description -City "Antwerp" -Country "BE" -ManagedBy $NewOU.manager -State "Antwerp" -Path $searchBase -ProtectedFromAccidentalDeletion $Protect
$SubOUPath = "OU=" + $Newou.Name + "," + $searchBase
foreach ($SubOU in $SubOUs){
New-ADOrganizationalUnit -Name $SubOU -Path $SubOUPath -ProtectedFromAccidentalDeletion $Protect
}
}
