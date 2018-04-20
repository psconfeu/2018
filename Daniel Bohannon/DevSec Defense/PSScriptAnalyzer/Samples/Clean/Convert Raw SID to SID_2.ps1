#For intel concerning how to convert raw hex SID to Standard  SID got to
#http://blogs.msdn.com/b/oldnewthing/archive/2004/03/15/89753.aspx

#to convert Hex to Dec
function Convert-HEXtoDEC
{
param($HEX)
ForEach ($value in $HEX)
{
[string][Convert]::ToInt32($value,16)
}
}

#to reassort decimal values to correct hex in order to cenvert them
function Reassort
{
param($chaine)
$a = $chaine.substring(0,2)
$b = $chaine.substring(2,2)
$c = $chaine.substring(4,2)
$d = $chaine.substring(6,2)
$d+$c+$b+$a
}

# this is the main function
# it splits the waxw sid into different parts and then converts the values
# finally it brings the converted SID value.
# you can supply an array of raw sid
function ConvertSID
{
param($chaine32)
foreach($chaine in $chaine32) {
    [INT]$SID_Revision = $chaine.substring(0,2)
    [INT]$Identifier_Authority = $chaine.substring(2,2)
    [INT]$Security_NT_Non_unique = Convert-HEXtoDEC(Reassort($chaine.substring(16,8)))
    $chaine1 = $chaine.substring(24,8)
    $chaine2 = $chaine.substring(32,8)
    $chaine3 = $chaine.substring(40,8)
    $chaine4 = $chaine.substring(48,8)
    [string]$MachineID_1=Convert-HextoDEC(Reassort($chaine1))
    [string]$MachineID_2=Convert-HextoDEC(Reassort($chaine2))
    [string]$MachineID_3=Convert-HextoDEC(Reassort($chaine3))
    [string]$UID=Convert-HextoDEC(Reassort($chaine4))
    #"S-1-5-21-" + $MachineID_1 + "-" + $MachineID_2 + "-" + $MachineID_3 + "-" + $UID
    "S-$SID_revision-$Identifier_Authority-$Security_NT_Non_unique-$MachineID_1-$MachineID_2-$MachineID_3-$UID"
    }
}
