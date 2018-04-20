<#
.Synopsis
   Does a backup of a single UCS target.
   
.Description
   Uses the UCS PowerTool cmdlet 'Backup-Ucs' and does all four types of UCS backup.
   Filenames include the UCS name, date/time stamp, and backup type.
   The backup directory is set by a variable in the script.  If it doesn't exist the script will create.  Since the backup files are XML I recommend enabling compression on the directory.

.Parameter Ucs
    The UCS environment to backup.  This can be either an IP address or the DNS name.
	
.Parameter CredentialFile
    The location of the credential file to log on to the UCSM with.  Defaults to the current directory.

.Example
 	Backup-mUcs.ps1 -Ucs ucspoc -CredentialPath C:\\Temp\\credentials.enc.xml

.Notes
    NAME: Backup-mUcs.ps1
    AUTHOR: Chris Monahan
    LASTEDIT: 10/2/2012
    KEYWORDS: UCS, PowerTool

.Link
    http://batchlife.wordpress.com/2012/11/14/powershell-script-to-backup/

Requires -Powershell Version 2.0
Requires -Cisco PowerTool Version 0.99
Requires -Hal Rottenberg's PsCredential functions: http://poshcode.org/501 & http://halr9000.com/article/531

#>

<# Instructions for one time setup are at the bottom of the script #>


param($Ucs=$null, $CredentialFile=$null)

if ($Ucs -eq $null)            { Write-Host "Enter the name/address of the UCS you're backing up" -BackgroundColor DarkYellow -ForegroundColor DarkRed; break }
if ($CredentialFile -eq $null) { Write-Host "Enter path to the credential file." -BackgroundColor DarkYellow -ForegroundColor DarkRed; break }


#-----------------------------
# Prep
#-----------------------------
#Static parameters
Set-Variable -Name ScriptDir   -Value "\\\\server\\share" -Scope Local
Set-Variable -Name BackupPath  -Value "C:\\Backups\\UCSM_Configuration_Backups" -Scope Local
Set-Variable -Name BackupTypes -Value ('config-system','config-logical','config-all','full-state')
Write-Verbose "`nStatic parameters`n-----------------`nScriptDir = $($ScriptDir)`nBackupPath = $($BackupPath)`nBackupTypes = $($BackupTypes)`n"
$errmailTo = "name@address"
$errmailFrom = "name@address"
$errmailSMTP = "emailserver"

If ( !(Test-Path $BackupPath) ) { mkdir $BackupPath }
. $ScriptDir\\Hals_PSCredentials.ps1


$UcsCred = Import-PsCredential -Path $CredentialFile


#-----------------------------
# Start doing the real work.
#-----------------------------

# Connect to the UCS
Connect-Ucs -Name $Ucs -Credential $UcsCred  -ErrorVariable errConnectingUcs| select Ucs,UserName,Version
if ($errConnectingUcs -ne $null) {
	$errmailBody = @()
    $errmailBody += "$(Get-Now) - Error connecting to UCS`n`n"
    $errmailBody += $errConnectingUcs
    Send-MailMessage  -From $errmailFrom -To $errmailTo -Subject "Backup-mUcs Error-- Failed connecting to $($Ucs)" -Body ($errmailBody | Out-String) -SmtpServer $errmailSMTP
	break
}

# Get one of each type of UCS backup.
ForEach ($type in $backuptypes) {
	Backup-Ucs -Type $type  -PreservePooledValues -PathPattern ($BackupPath + '\\${ucs}_${yyyy}${MM}${dd}_${HH}${mm}_' + $type + '.xml') -ErrorVariable errBackupUcs
	if ($errBackupUcs -ne $null) {
		$errmailBody = @()
		$errmailBody += "$(Get-Now) - Error running backup of type $($type)`n`n"
		$errmailBody += $error[0]
		Send-MailMessage  -From $errmailFrom -To $errmailTo -Subject "Backup-mUcs Error-- On $($Ucs) backup of type $($type) failed" -Body ($errmailBody | Out-String) -SmtpServer $errmailSMTP
	}
}

# Don't leave a stale session on the UCS
Disconnect-Ucs


<# One time setup

1- Copy script to SCRIPTHOST server for the datacenter you're working in.
  $> copy \\\\server\\share\\Hals_PSCredentials.ps1 C:\\Scripts

2- Log on locally to the SCRIPTHOST with the service account the script will run under in Task Scheduler.

3- If necessary install the Cisco PowerTool module and configure it to load automatically in the PowerShell profile.
  a- The PowerTool module can be copied from \\\\server\\share\\Modules to the same directory on the local scripthost.
  b- The PowerShell profile may not exist yet.  If it doesn't create file in the path specified by the "$profile" variable.
    $> notepad $profile
	1- Add the line "Import-Module C:\\Ops\\Modules\\CiscoUCSPowerTool\\CiscoUcsPS.psd1"
	2- Save and exit the file
	
4- Create the credential file containing the UCS login credentials to use in the script.  The credential file can only opened by the Windows user account that created it.  That's why you have to log on with the Windows service account used to run the task in Task Scheduler.  The Windows credentials encrypt the file, and inside the file are the UCS login username and password.  You can store the credential files in any directory you want.  The directory in the example is for demonstration.
  $> mkdir C:\\Scripts\\CredentialFiles
  $> . \\\\server\\share\\Hals_PSCredentials.ps1
  $> $creds = Get-Credential  # Username/password to login to the UCS with.
  $> Export-PSCredential -Credential $creds -Path C:\\Scripts\\CredentialFiles\\somename.enc.xml

5- Copy \\\\vmscripthost201\\C$\\Scripts\\Run_Backup-mUcs.ps1 to the vmscripthost you're setting up.
  a- This is the wrapper script that will be put into Task Scheduler.  It will call Backup-mUcs.ps1 for each UCS environment to be backed up.
  b- Edit the script so that it has the correct UCS DNS name(s) or IP address(es) for the datacenter you're configuring this for.

6- Test the script interactively first by running Backup-mUcs.ps1 and then by running Run_Backup-mUcs.ps1.

7- Add Run_Backup-mUcs.ps1 into Task Scheduler and test.
  a- For now copy the Task Scheduler settings for the job from what's in the \\\\server Task Scheduler.  May put the full instructions in later.

8- Verify the scripthost server is getting backed up somehow.  Preferably as a normal OS level full backup by the backup group.  The size of the backups for our UCS's so far for four UCS environments is 12MB a day.

#>


