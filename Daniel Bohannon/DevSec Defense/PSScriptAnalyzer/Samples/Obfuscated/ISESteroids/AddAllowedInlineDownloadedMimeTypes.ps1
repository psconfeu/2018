 




Import-LocalizedData -BindingVariable Messages

if ((Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null) {Add-PSSnapin Microsoft.SharePoint.PowerShell}

Function New-OSCPSCustomErrorRecord
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
		${/=\____/=\_/====\} = New-Object System.Management.Automation.RuntimeException($ExceptionString)
		${_/\/\_____/\/\__/} = New-Object System.Management.Automation.ErrorRecord(${/=\____/=\_/====\},$ErrorID,$ErrorCategory,$TargetObject)
		return ${_/\/\_____/\/\__/}
	}
}

Function Get-OSCSPWebAppMimeTypes
{
	
	
	[CmdletBinding()]
	Param
	(
		
		[Parameter(Mandatory=$true,Position=1)]
		[string]$Identity
	)
	Process
	{
		Try
		{
			${/===\___/\/=\_/\/} = Get-SPWebApplication -Identity $Identity
		}
		Catch
		{
			$pscmdlet.WriteError($Error[0])
		}
		${_/=\_/\/==\/\_/==} = $Messages.ExistedMIMETypes
		${_/=\_/\/==\/\_/==} = ${_/=\_/\/==\/\_/==} -replace $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UABsAGEAYwBlAGgAbwBsAGQAZQByADAAMQA='))),$(${/===\___/\/=\_/\/}.Name)
		$pscmdlet.WriteObject(${_/=\_/\/==\/\_/==})
		${___/=\___/\___/=\} = ${/===\___/\/=\_/\/}.AllowedInlineDownloadedMimeTypes
		return ${___/=\___/\___/=\}
	}
}

Function Add-OSCSPWebAppMimeTypes
{
	
	
	[CmdletBinding()]
	Param
	(
		
		[Parameter(Mandatory=$true,Position=1)]
		[string]$Identity,
		[Parameter(Mandatory=$true,Position=2)]
		[string[]]$MIMEType	
	)
	Process
	{
		
		${/===\_/\/=\/=\_/=} = $Messages.SecurityWarningTitle
		${_/=\/\/=\_/=\_/\/} = $Messages.SecurityWarning
		${_/=\/\/=\_/=\_/\/} = ${_/=\/\/=\_/=\_/\/} -replace $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UABsAGEAYwBlAGgAbwBsAGQAZQByADAAMQA='))),$MIMEType
		${__/\_/\_/==\/=\/\} = New-Object System.Management.Automation.Host.ChoiceDescription $($Messages.ChoiceYes),$($Messages.ChoiceYesMsg01)
		${/=\__/===\/=\/\__} = New-Object System.Management.Automation.Host.ChoiceDescription $($Messages.ChoiceNo),$($Messages.ChoiceNoMsg01)
		${_/\_/\_/====\_/\_} = [System.Management.Automation.Host.ChoiceDescription[]](${__/\_/\_/==\/=\/\}, ${/=\__/===\/=\/\__})
		${/====\/\_/=====\/} = $host.ui.PromptForChoice(${/===\_/\/=\/=\_/=}, ${_/=\/\/=\_/=\_/\/}, ${_/\_/\_/====\_/\_}, 1)
		switch (${/====\/\_/=====\/})
		{
			0 {${/=\/=\_/=\__/===\} = $true}
			1 {${/=\/=\_/=\__/===\} = $false}
		}		
		if (${/=\/=\_/=\__/===\}) {
			Try
			{
				${/===\___/\/=\_/\/} = Get-SPWebApplication -Identity $Identity -Verbose:$false
			}
			Catch
			{
				$pscmdlet.WriteError($Error[0])
			}
			foreach (${/=\_/\/\/\/\/\/==} in $MIMEType) {
				if (${/===\___/\/=\_/\/}.AllowedInlineDownloadedMimeTypes -notcontains ${/=\_/\/\/\/\/\/==}) {
					${__/\__/\__/=\/=\/} = $Messages.AddMIMEType
					${__/\__/\__/=\/=\/} = ${__/\__/\__/=\/=\/} -replace $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UABsAGEAYwBlAGgAbwBsAGQAZQByADAAMQA='))),${/=\_/\/\/\/\/\/==}
					$pscmdlet.WriteVerbose(${__/\__/\__/=\/=\/})
					${/===\___/\/=\_/\/}.AllowedInlineDownloadedMimeTypes.Add(${/=\_/\/\/\/\/\/==})
					${/===\___/\/=\_/\/}.Update()
				} else {
					${____/=\/==\/\/===} = $Messages.ExistedType
					${____/=\/==\/\/===} = ${____/=\/==\/\/===} -replace $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UABsAGEAYwBlAGgAbwBsAGQAZQByADAAMQA='))),${/=\_/\/\/\/\/\/==}
					$pscmdlet.WriteWarning(${____/=\/==\/\/===})
				}
			}
		} else {
			return $null
		}
	}
}

