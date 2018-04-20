<#
	.SYNOPSIS
		Disable ActiveSync for all users NOT in AD group and enable it for all users in that same group
	.DESCRIPTION
    	Disable ActiveSync for all users NOT in AD group and enable it for all users in that same group
	.PARAMETER
	.INPUTS
	.OUTPUTS
	.EXAMPLE
	.NOTES
		NAME:  Set-ActiveSyncEnabled.ps1
		AUTHOR: Charles Downing
		LASTEDIT: 06/20/2012
		KEYWORDS:
	.LINK
#>

# Add Exchange Admin module
If ((Get-PSSnapin | where {$_.Name -match $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RQB4AGMAaABhAG4AZwBlAC4ATQBhAG4AYQBnAGUAbQBlAG4AdAA=')))}) -eq $null)
{
	Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
}

# Assign ALL USERS to a dynamic array
${_/\_____/==\_/===} = get-Mailbox -ResultSize:unlimited

# Assign all members of the ALLOWED GROUP to a dynamic array
${_/\_/\/\/==\/=\/\} = Get-DistributionGroupMember -Identity $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RQB4AGMAaABhAG4AZwBlACAAQQBjAHQAaQB2AGUAUwB5AG4AYwAgAEEAbABsAG8AdwBlAGQA')))

# Loop through array of all users
foreach (${____/\___/\/==\__} in ${_/\_____/==\_/===}) 
{
	${_/\__/\/===\/\_/\} = ""
	
	#get CAS attributes for current user
	${_/=\/\/\/\__/\___} = Get-CasMailbox -resultsize unlimited -identity ${____/\___/\/==\__}.Name
	
	#determine if current user is member of allowed group
	if((${_/\_/\/\/==\/=\/\} | where-object{$_.Name -eq ${____/\___/\/==\__}.Name}))
	{
		#if user already has ActiveSync enabled, do nothing
		if (${_/=\/\/\/\__/\___}.ActiveSyncEnabled -eq $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('dAByAHUAZQA='))))
		{
			${_/\__/\/===\/\_/\} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwB1AHIAcgBlAG4AdAAgAC0AIABlAG4AYQBiAGwAZQBkACAALQAgAA=='))) 
		}
		#if user does not have ActiveSync enabled, enable it
		else
		{
			${____/\___/\/==\__} | Set-CASMailbox –ActiveSyncEnabled $true
			${_/\__/\/===\/\_/\} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RQBuAGEAYgBsAGUAZAAgAC0AIAA=')))
		}
	}
	#if user is not member of allowed group, disable ActiveSync
	else
	{
		if (${_/=\/\/\/\__/\___}.ActiveSyncEnabled -eq $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('dAByAHUAZQA='))))
		{
			${____/\___/\/==\__} | Set-CASMailbox –ActiveSyncEnabled $false
			${_/\__/\/===\/\_/\} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RABpAHMAYQBiAGwAZQBkACAALQAgAA==')))
		}
		else
		{
			${_/\__/\/===\/\_/\} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwB1AHIAcgBlAG4AdAAgAC0AIABkAGkAcwBhAGIAbABlAGQAIAAtACAA')))
		}
	}

	${_/\__/\/===\/\_/\} += ${_/=\/\/\/\__/\___}.Name + "`n"
	echo ${_/\__/\/===\/\_/\}
}