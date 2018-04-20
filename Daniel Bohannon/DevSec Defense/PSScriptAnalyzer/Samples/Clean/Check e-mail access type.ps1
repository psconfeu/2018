$ErrorActionPreference = "silentlycontinue"

$login = read-host -prompt "Type the user login"

$Status = @( Get-ADuser $login | select SamAccountName).count 

If($Status -eq 0) {

Write-Host No such user exists! -FOREGROUNDCOLOR RED

./the_script_name.ps1

} Else {Write-Host Working on it! -FOREGROUNDCOLOR GREEN

 
}


Get-Mailbox $login | Get-CASMailbox
