 




Import-LocalizedData -BindingVariable Messages

Function __/=\/\/\/\/=\____
{
	
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true,Position=1)][String]$ExceptionString,
		[Parameter(Mandatory=$true,Position=2)][String]$ErrorID,
		[Parameter(Mandatory=$true,Position=3)][System.Management.Automation.ErrorCategory]$ErrorCategory,
		[Parameter(Mandatory=$true,Position=4)][PSObject]$TargetObject
	)
	Process
	{
		${__/===\_/=====\__} = New-Object System.Management.Automation.RuntimeException($ExceptionString)
		${/=\__/\_/\/===\/=} = New-Object System.Management.Automation.ErrorRecord(${__/===\_/=====\__},$ErrorID,$ErrorCategory,$TargetObject)
		return ${/=\__/\_/\/===\/=}
	}
}

Function Get-OSCEXMailboxUsageReport
{
	
	
	[CmdletBinding()]
	Param
	(
		
		[Parameter(Mandatory=$true,Position=1)]
		[string]$Filter,
		[Parameter(Mandatory=$false,Position=2)]
		[string[]]$MailboxProperty,
		[Parameter(Mandatory=$false,Position=3)]
		[string[]]$MailboxStatisticsProperty
	)
	Process
	{
		${__/\_/=\/==\/\_/=} = @{}
		${___/\/\/=\/\_____} = @{}
		${__/==\_/\/\__/=\_} = @{}
		
		${_/\___/==\/\___/=} = Get-Mailbox -Filter 'Alias -like "Discover*"' -Verbose:$false
		${_/\___/==\/\___/=} | Get-Member -MemberType Property | %{${___/\/\/=\/\_____}.Add($_.Name,"")}
		${_/\___/==\/\___/=} | Get-MailboxStatistics -Verbose:$false | Get-Member -MemberType Property | %{${__/==\_/\/\__/=\_}.Add($_.Name,"")}
		
		if ($MailboxProperty -ne $null) {
			foreach (${/=\/\/\/=\______/} in $MailboxProperty) {
				if (-not ${___/\/\/=\/\_____}.ContainsKey(${/=\/\/\/=\______/})) {
					${_/=\/=\___/=\___/} = $Messages.MailboxPropertyNameIsNotValid
					${_/=\/=\___/=\___/} = ${_/=\/=\___/=\___/} -f ${/=\/\/\/=\______/}
					$pscmdlet.WriteWarning(${_/=\/=\___/=\___/})
				}
			}
		}				
		if ($MailboxStatisticsProperty -ne $null) {
			foreach (${__/\/===========\} in $MailboxStatisticsProperty) {
				if (-not ${__/==\_/\/\__/=\_}.ContainsKey(${__/\/===========\})) {
					${_/=\/=\___/=\___/} = $Messages.MailboxStatisticsPropertyNameIsNotValid
					${_/=\/=\___/=\___/} = ${_/=\/=\___/=\___/} -f ${__/\/===========\}
					$pscmdlet.WriteWarning(${_/=\/=\___/=\___/})
				}
			}
		}		
		
		${___/\__/\_/\/\/\/} = Get-Mailbox -Filter $Filter -ResultSize unlimited -Verbose:$false
		if (${___/\__/\_/\/\/\/} -ne $null) {
			
			${_/=\_________/=\/} = $Messages.ActivityName
			${/=\__/\/\/=\_/===} = $Messages.StatusDesc
			${_/\/=\_/\_/=\___/} = New-Object System.Management.Automation.ProgressRecord(1,${_/=\_________/=\/},${/=\__/\/\/=\_/===})
			${__/\/\/\/==\_/==\} = (${___/\__/\_/\/\/\/} | Measure-Object).Count
			foreach (${_/\__/=\/==\_/\/=} in ${___/\__/\_/\/\/\/}) {
				
				$counter++
				${_/\/\_/\/\/\/\___} = [int]($counter / ${__/\/\/\/==\_/==\} * 100)
				${_/\/=\_/\_/=\___/}.CurrentOperation = $verboseMsg
				${_/\/=\_/\_/=\___/}.PercentComplete = ${_/\/\_/\/\/\/\___}
				$pscmdlet.WriteProgress(${_/\/=\_/\_/=\___/})				
				
				${__/====\_/\/\/\/=} = New-Object System.Management.Automation.PSObject
				${_/\/=\_/\__/=====} = Get-MailboxStatistics -Identity ${_/\__/=\/==\_/\/=}.Alias -WarningAction SilentlyContinue -Verbose:$false
				if (${_/\/=\_/\__/=====} -ne $null) {
					${__/=\/\/\/=\/\_/\} = ${_/\/=\_/\__/=====}.TotalItemSize.Value.ToBytes()
				} else {
					${__/=\/\/\/=\/\_/\} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TgAvAEEA')))
				}
				
				${__/====\_/\/\/\/=} | Add-Member -MemberType NoteProperty -Name Alias -Value ${_/\__/=\/==\_/\/=}.Alias
				
				if (-not ${_/\__/=\/==\_/\/=}.UseDatabaseQuotaDefaults) {
					
					if (-not ${_/\__/=\/==\_/\/=}.IssueWarningQuota.IsUnlimited) {
						${___/==\___/\___/\} = ${_/\__/=\/==\_/\/=}.IssueWarningQuota.Value.ToBytes()
					} else {
						${___/==\___/\___/\} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VQBuAGwAaQBtAGkAdABlAGQA')))
					}
					${__/====\_/\/\/\/=} | Add-Member -MemberType NoteProperty -Name IssueWarningQuota -Value ${_/\__/=\/==\_/\/=}.IssueWarningQuota
					${__/====\_/\/\/\/=} | Add-Member -MemberType NoteProperty -Name IssueWarningQuotaFrom -Value $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBhAGkAbABiAG8AeAA=')))				
				} else {
					
					
					${/=\/\/\/\/\/=\/\/} = ${_/\__/=\/==\_/\/=}.Database
					${/==\/\/===\/====\} = Get-MailboxDatabase -Identity ${/=\/\/\/\/\/=\/\/} -Verbose:$false
					if (-not ${__/\_/=\/==\/\_/=}.Contains(${/=\/\/\/\/\/=\/\/})) {
						${__/\_/=\/==\/\_/=}.Add(${/=\/\/\/\/\/=\/\/},${/==\/\/===\/====\}.IssueWarningQuota)
					}
					if (-not (${__/\_/=\/==\/\_/=}[${/=\/\/\/\/\/=\/\/}].IsUnlimited)) {
						${___/==\___/\___/\} = ${__/\_/=\/==\/\_/=}[${/=\/\/\/\/\/=\/\/}].Value.ToBytes()
					} else {
						${___/==\___/\___/\} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VQBuAGwAaQBtAGkAdABlAGQA')))
					}
					${__/====\_/\/\/\/=} | Add-Member -MemberType NoteProperty -Name IssueWarningQuota -Value ${__/\_/=\/==\/\_/=}[${/=\/\/\/\/\/=\/\/}]
					${__/====\_/\/\/\/=} | Add-Member -MemberType NoteProperty -Name IssueWarningQuotaFrom -Value $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RABhAHQAYQBiAGEAcwBlAA==')))
				}
				
				if ((${__/=\/\/\/=\/\_/\} -ne $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TgAvAEEA')))) -and (${___/==\___/\___/\} -ne $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VQBuAGwAaQBtAGkAdABlAGQA'))))) {
					${__/=\_/==\/==\__/} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ewAwADoAUAAyAH0A'))) -f (${__/=\/\/\/=\/\_/\} / ${___/==\___/\___/\})
				} else {
					${__/=\_/==\/==\__/} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TgAvAEEA')))
				}
				${__/====\_/\/\/\/=} | Add-Member -MemberType NoteProperty -Name UsagePercent -Value ${__/=\_/==\/==\__/}
				
				if ($MailboxProperty -ne $null) {
					foreach (${/=\/\/\/=\______/} in $MailboxProperty) {
						if (${___/\/\/=\/\_____}.ContainsKey(${/=\/\/\/=\______/})) {
							if (${/=\/\/\/=\______/} -match $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UAByAG8AaABpAGIAaQB0AFMAZQBuAGQAUQB1AG8AdABhAHwAUAByAG8AaABpAGIAaQB0AFMAZQBuAGQAUgBlAGMAZQBpAHYAZQBRAHUAbwB0AGEAfABSAHUAbABlAHMAUQB1AG8AdABhAA==')))) {
								if (-not ${_/\__/=\/==\_/\/=}.UseDatabaseQuotaDefaults) {
									
									${__/====\_/\/\/\/=} | Add-Member -MemberType NoteProperty -Name ${/=\/\/\/=\______/} -Value $(${_/\__/=\/==\_/\/=}.${/=\/\/\/=\______/})				
								} else {
									
									
									${__/====\_/\/\/\/=} | Add-Member -MemberType NoteProperty -Name ${/=\/\/\/=\______/} -Value $(${/==\/\/===\/====\}.${/=\/\/\/=\______/})
								}								
							} else {
								${__/====\_/\/\/\/=} | Add-Member -MemberType NoteProperty -Name ${/=\/\/\/=\______/} -Value $(${_/\__/=\/==\_/\/=}.${/=\/\/\/=\______/})
							}
						}
					}
				}				
				
				if ($MailboxStatisticsProperty -ne $null) {
					foreach (${__/\/===========\} in $MailboxStatisticsProperty) {
						if (${__/==\_/\/\__/=\_}.ContainsKey(${__/\/===========\})) {
							if (${_/\/=\_/\__/=====} -ne $null) {
								${__/====\_/\/\/\/=} | Add-Member -MemberType NoteProperty -Name ${__/\/===========\} -Value $(${_/\/=\_/\__/=====}.${__/\/===========\}) -Force
							} else {
								${__/====\_/\/\/\/=} | Add-Member -MemberType NoteProperty -Name ${__/\/===========\} -Value $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TgAvAEEA')))
							}
						}
					}
				}
				$pscmdlet.WriteObject(${__/====\_/\/\/\/=})
			}
		} else {
			${_/\/\/\__/\__/=\_} = $Messages.CannotFindMailbox
			${_/\/\/\__/\__/=\_} = ${_/\/\/\__/\__/=\_} -f $Filter
			${/=\__/\_/\/===\/=} = __/=\/\/\/\/=\____ `
			-ExceptionString ${_/\/\/\__/\__/=\_} `
			-ErrorCategory NotSpecified -ErrorID 1 -TargetObject $pscmdlet
			$pscmdlet.ThrowTerminatingError(${/=\__/\_/\/===\/=})		
		}
	}
}

