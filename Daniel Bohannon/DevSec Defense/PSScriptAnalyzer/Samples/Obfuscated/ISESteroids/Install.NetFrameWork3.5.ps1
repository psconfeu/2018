<#
The sample scripts are not supported under any Microsoft standard support 
program or service. The sample scripts are provided AS IS without warranty  
of any kind. Microsoft further disclaims all implied warranties including,  
without limitation, any implied warranties of merchantability or of fitness for 
a particular purpose. The entire risk arising out of the use or performance of  
the sample scripts and documentation remains with you. In no event shall 
Microsoft, its authors, or anyone else involved in the creation, production, or 
delivery of the scripts be liable for any damages whatsoever (including, 
without limitation, damages for loss of business profits, business interruption, 
loss of business information, or other pecuniary loss) arising out of the use 
of or inability to use the sample scripts or documentation, even if Microsoft 
has been advised of the possibility of such damages.
#> 
Function Install-OSCNetFx3
{
<#
 	.SYNOPSIS
        Install-OSCNetFx3 is an advanced function which can be used to install .NET Framework 3.5 in Windows 8.
    .DESCRIPTION
        Install-OSCNetFx3 is an advanced function which can be used to install .NET Framework 3.5 in Windows 8.
	.PARAMETER  Online
		It will download .NET Framework 3.5 online and install it.
	.PARAMETER 	LocalSource
		The path of local source which includes .NET Framework 3.5 source.
	.PARAMETER	TemplateID
		The ID of the template in the template group
    .EXAMPLE
        C:\PS> Install-OSCNetFx3 -Online
		
		This command shows how to download .NET Framework 3.5 online and install it.
	.EXAMPLE
        C:\PS> Install-OSCNetFx3 -LocalSource G:\sources\sxs
		
		This command shows how to use local source to install .NET Framework 3.5.
				
#>
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$False,Position=0)][Switch]$Online,
		[Parameter(Mandatory=$False,Position=0)][String]$LocalSource
	)
	If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
	{
	    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
	    Break
	}
	Else
	{
		${__/\_/\/\/\_/\/\_} = (gwmi "win32_operatingsystem" | Select caption).Caption
		If(${__/\_/\/\/\_/\/\_} -match "Microsoft Windows 8")
		{
			${___/=\_/\__/==\/\} = Dism /online /get-featureinfo /featurename:NetFx3
			If(${___/=\_/\__/==\/\} -contains "State : Enabled")
			{
				Write-Warning ".Net Framework 3.5 has been installed and enabled."
			}
			Else 
			{
				if($LocalSource)
				{
					Write-Host "Installing .Net Framework 3.5, do not close this prompt..."
					DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:$LocalSource | Out-Null 
					${___/=\_/\__/==\/\} = Dism /online /Get-featureinfo /featurename:NetFx3
					If(${___/=\_/\__/==\/\} -contains "State : Enabled")
					{
						Write-Host "Install .Net Framework 3.5 successfully."
					}
					Else
					{
						Write-Host "Failed to install Install .Net Framework 3.5,please make sure the local source is correct."
					}
				}
				Else 
				{	
					Write-Host "Installing .Net Framework 3.5, do not close this prompt..." | 
					Dism /online /Enable-feature /featurename:NetFx3 /All | Out-Null 
					${___/=\_/\__/==\/\} = Dism /online /Get-featureinfo /featurename:NetFx3
					If(${___/=\_/\__/==\/\} -contains "State : Enabled")
					{
						Write-Host "Install .Net Framework 3.5 successfully."
					}
					Else
					{
						Write-Host "Failed to install Install .Net Framework 3.5, you can use local source to try again."
					}
				}
			}
		}
		Else
		{
			Write-Error "Please run this script in Windows 8"
		}
	}
}
