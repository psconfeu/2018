#######################
<#
.SYNOPSIS
Adds a SQL Server Client Alias by setting registry key. 
.DESCRIPTION
Provides same functionality as cliconfg.exe GUI. Although there is a WMI provider to add client network aliases, the differences between SQL version make it diffult to use. This method creates the registry key.
.EXAMPLE
./add-sqlclientalias.ps1 -ServerAlias Z001\\sql2 -ServerName Z001XA\\sql2 -Protocol TCP -Port 5658
This command add a SQL client alias
.NOTES
Version History
v1.0   - Chad Miller - 9/24/2012 - Initial release
.LINK
http://social.msdn.microsoft.com/Forums/sa/sqldataaccess/thread/39fe3b15-96a1-454f-b3bd-da6b1f74700a
#>
param(
[Parameter(Position=0, Mandatory=$true)]
[string]
$ServerAlias,
[Parameter(Position=1, Mandatory=$true)]
[string]
$ServerName,
[ValidateSet("NP", "TCP")]
[Parameter(Position=2, Mandatory=$true)]
[string]
$Protocol="TCP",
[Parameter(Position=3, Mandatory=$false)]
[int]
$PortNumber
)

if ($Protocol="TCP") {
    if ($PortNumber) {
        $value = "DBMSSOCN,{0},{1}" -f $ServerName,$PortNumber
    }
    else {
        $value = "DBMSSOCN,{0}" -f $ServerName
    }
}
else {
    $value = "DBNMPNTW,\\\\{0}\\pipe\\sql\\query" -f $ServerName
}

Set-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\MSSQLServer\\Client\\ConnectTo' -Name $ServerAlias -Value $value
