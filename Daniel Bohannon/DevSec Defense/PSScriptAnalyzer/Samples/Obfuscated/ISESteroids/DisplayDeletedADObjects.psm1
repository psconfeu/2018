#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support 
#program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including,  
#without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  
#the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or 
#delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft 
#has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- 

#requires -Version 3.0

Import-module ActiveDirectory

Function Get-OSCDeletedADObjects
{
<#
 	.SYNOPSIS
        Get-OSCDeletedADObjects is an advanced function which can be used to display deleted objects in Active Directory.
    .DESCRIPTION
        Get-OSCDeletedADObjects is an advanced function which can be used to display deleted objects in Active Directory.
    .PARAMETER Name
		Specifies the name of the output object to retrieve output object.
    .PARAMETER StartTime
		Specifies the start time to retrieve output object.
    .PARAMETER EndTime
		Specifies the end time to retrieve output object.
    .PARAMETER Property
		Specifies the properties of the output object to retrieve from the server.
    .EXAMPLE
        C:\PS> Get-OSCDeletedADObjects
		
		This command shows all deleted objects in active directory.
    .EXAMPLE
	    C:\PS> Get-OSCDeletedADObjects -StartTime 2/20/2013 -EndTime 2/28/2013
		
		This command shows all deleted objects in active directory from 2/20/2013 to 2/28/2013
#>
	[Cmdletbinding()]
	Param
	(
		[Parameter(Mandatory=$false,Position=0,ParameterSetName='Name')]
		[String]$Name,
		[Parameter(Mandatory,Position=1,ParameterSetName='Time')]
		[DateTime]$StartTime,
		[Parameter(Mandatory,Position=2,ParameterSetName='Time')]
		[DateTime]$EndTime,
		[Parameter(Mandatory=$false,Position=0)]
		[String[]]$Property="*"
	)
	
	${_/\_/\_/\__/\/=\_} = Get-ADObject -Filter {(isdeleted -eq $true) -and (name -ne "Deleted Objects")} -includeDeletedObjects -property $Property
					
	If($StartTime -and $EndTime) 
	{
		${_/\_/\_/\__/\/=\_} | ?{$_.whenChanged -ge $StartTime -and $_.whenChanged -le $EndTime}	
	}
	ElseIf($Name)
	{
		${_/\_/\_/\__/\/=\_} | ?{$_."msDS-LastKnownRDN" -like $Name}
	}
	Else
	{
		${_/\_/\_/\__/\/=\_}
	}
}