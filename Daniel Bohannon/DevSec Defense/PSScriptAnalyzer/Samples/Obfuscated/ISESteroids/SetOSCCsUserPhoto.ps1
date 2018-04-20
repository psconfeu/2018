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

#requires -Version 2

#Import Localized Data
Import-LocalizedData -BindingVariable Messages
#Import Active Directory Module
if ((gmo -Name ActiveDirectory -ListAvailable) -ne $null) {
	if ((gmo -Name ActiveDirectory) -eq $null) {
		ipmo ActiveDirectory
	}
} else {
	${20} = $Messages.InstallADModule
	throw ${20}
}
#Add Assembly
Add-Type -AssemblyName System.Drawing
#Use nested hash table to cache all policies
#Nested hash table structure: $cachedPolicies=@{"PolicyType"=@{"PolicyIdentity"=PolicyObject}}
${11} = @{}
#Cache site objects
${16} = Get-CsSite

Function f1
{
	#.EXTERNALHELP Test-OSCCsUserPhoto-Help.xml

	[CmdletBinding()]
	Param
	(
		#Define parameters
		[Parameter(Mandatory=$true,Position=1)]
		[string]$Path
	)
	Process
	{
		#Try to get photo file
		Try
		{
			${19} = ls -Path $Path
		}
		Catch
		{
			$pscmdlet.ThrowTerminatingError($Error[0])
		}
		#Check photo size
		#The recommended thumbnail photo size in pixels is 96x96 pixels.
		#The size of thumbnail photo should be less than 100KB.
		${17} = [System.Drawing.Image]::FromFile(${19}.FullName)
		${18} = ${19}.Length
		if ((${18} -gt 100KB) -or (${17}.Width -ne 96) -or (${17}.Height -ne 96)) {
			return $false
		} else {
			return $true
		}
		${17}.Dispose()
	}
}

Function f2
{
	#.EXTERNALHELP Get-OSCCsUserEffectiveClientPolicy-Help.xml

	[CmdletBinding()]
	Param
	(
		#Define parameters
		[Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true)]
		[string]$Identity
	)
	Process
	{
		#Get user object, registrar pool, site
		Try
		{
			${7} = Get-CsUser -Identity $Identity -Verbose:$false
		}
		Catch
		{
			$pscmdlet.ThrowTerminatingError($Error[0])
		}
		if (${7} -ne $null) {
			${15} = ${7}.RegistrarPool.FriendlyName
			${12} = (${16} | ? {$_.Pools -contains ${15}}).Identity	
			#Cache all client policies
			if (${11}.Count -eq 0) {
				${14} = Get-CsClientPolicy -Verbose:$false
				foreach (${9} in ${14}) {
					${13} = ${9}.Identity
					if (-not ${11}.ContainsKey("ClientPolicy")) {
						${11}.Add("ClientPolicy",@{${13}=${9}})
					} else {
						${11}["ClientPolicy"].Add(${13},${9})
					}
				}
			}
			#Get effective policy name
			if (${7}.ClientPolicy -ne $null) {
				${10} = "Tag:" + ${7}.ClientPolicy.FriendlyName
			} else {
				if (${11}["ClientPolicy"].ContainsKey(${12})) {
					${10} = ${12}
				} else {
					${10} = "Global"
				}
			}
			#Return effective policy object
			${9} = ${11}["ClientPolicy"].${10}
			return ${9}
		}
	}
}

Function Set-OSCCsUserPhoto
{
	#.EXTERNALHELP Set-OSCCsUserPhoto-Help.xml

	[CmdletBinding(SupportsShouldProcess=$true)]
	Param
	(
		#Define parameters
		[Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true)]
		[string[]]$Identity,
		[Parameter(Mandatory=$true,Position=2)]
		[string]$PhotoFolder
	)
	Process
	{
		foreach (${8} in $Identity) {
			Try
			{
				${7} = Get-CsUser -Identity ${8}
			}
			Catch
			{
				$pscmdlet.WriteError($Error[0])
			}
			if (${7} -ne $null) {
				#Check Client Polciy
				${2} = ${7}.SamAccountName
				${6} = f2 -Identity ${2}
				if (${6}.DisplayPhoto -eq "NoPhoto") {
					${4} = $Messages.NoPhotoWarning
					${4} = ${4} -replace "Placeholder01",${2}
					$pscmdlet.WriteWarning(${4})
					break
				}
				#Try to get user photo by using SAM Account Name
				Try
				{
					${5} = ls -Path $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('JABQAGgAbwB0AG8ARgBvAGwAZABlAHIAXAAkAHsAMgB9AC4AagBwAGcA')))	
				}
				Catch
				{
					$pscmdlet.WriteError($Error[0])
				}
				if (${5} -ne $null) {
					#Test photo size.
					#If photo meets the requirement of thumbnail photo, convert the content to System.Byte[]
					#Otherwise, displays a warning message.
					if (f1 -Path ${5}.FullName) {
						${1} = [byte[]](gc ${5}.FullName -Encoding byte)
					} else {
						${4} = $Messages.UseRecommendedSize
						${4} = ${4} -replace "Placeholder01",${2}
						$pscmdlet.WriteWarning(${4})
					}
					#Try to populate thumbnailPhoto attribute in Active Directory
					if (${1} -ne $null) {
						if ($pscmdlet.ShouldProcess(${2})) {
							${3} = $Messages.SettingPhoto
							${3} = ${3} -replace "Placeholder01",${2}
							$pscmdlet.WriteVerbose(${3})
							Set-ADUser -Identity ${2} -Replace @{thumbnailPhoto=${1}}
						}
					}
				}
			}
		}
	}
}

