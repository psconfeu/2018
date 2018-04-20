

${___/=\/\/\/=\___/} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RAA6AFwATwB1AHQAcAB1AHQALgBoAHQAbQA=')))
${/=\____/\/\_/===\}=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('SwBBAFcASgBBAFoAWgBWAE0AUwBRAEwAMAAyAA==')))

if ((Get-PSSnapin | ? {$_.Name -eq $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBpAGMAcgBvAHMAbwBmAHQALgBFAG4AdABlAHIAcAByAGkAcwBlAE0AYQBuAGEAZwBlAG0AZQBuAHQALgBPAHAAZQByAGEAdABpAG8AbgBzAE0AYQBuAGEAZwBlAHIALgBDAGwAaQBlAG4AdAA=')))}) -eq $null) 
{ 
	Add-PSSnapin Microsoft.EnterpriseManagement.OperationsManager.Client -ErrorAction SilentlyContinue
} 

if ((Get-ManagementGroupConnection | ? {$_.ManagementServerName -eq ${/=\____/\/\_/===\}}) -eq $null) 
{ 
	New-ManagementGroupConnection ${/=\____/\/\_/===\} -ErrorAction SilentlyContinue
}
 
if ((gdr | ? {$_.Name -eq $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBvAG4AaQB0AG8AcgBpAG4AZwA=')))}) -eq $null) 
{ 
	ndr -Name: Monitoring -PSProvider: OperationsManagerMonitoring -Root: \ -ErrorAction SilentlyContinue -ErrorVariable Err
	if ($Err) { $(throw write-Host $Err) } 
} 

cd Monitoring:\${/=\____/\/\_/===\} 

${___/\_____/=\/=\_} = @()
${_____/=\/==\__/\_} = get-alert -Criteria $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UgBlAHMAbwBsAHUAdABpAG8AbgBTAHQAYQB0AGUAIAAhAD0AIAAyADUANQA='))) | sort Severity -Descending
foreach (${/=\/\_/=\/\/\/===} in ${_____/=\/==\__/\_}) 
    {     
        ${___/\_____/=\/=\_} +=  ${/=\/\_/=\/\/\/===} | Select PrincipalName,Name,Description,TimeRaised,Severity
	} 

"Total Active Alerts: $(${___/\_____/=\/=\_}.Length)"

if(${___/\_____/=\/=\_} -ne $null)
{
	${_/=\/=\_/======\/} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('PABzAHQAeQBsAGUAIAB0AHkAcABlAD0AIgB0AGUAeAB0AC8AYwBzAHMAIgA+AA0ACgAJACMASABlAGEAZABlAHIAewBmAG8AbgB0AC0AZgBhAG0AaQBsAHkAOgAiAFQAcgBlAGIAdQBjAGgAZQB0ACAATQBTACIALAAgAEEAcgBpAGEAbAAsACAASABlAGwAdgBlAHQAaQBjAGEALAAgAHMAYQBuAHMALQBzAGUAcgBpAGYAOwB3AGkAZAB0AGgAOgAxADAAMAAlADsAYgBvAHIAZABlAHIALQBjAG8AbABsAGEAcABzAGUAOgBjAG8AbABsAGEAcABzAGUAOwB9AA0ACgAJACMASABlAGEAZABlAHIAIAB0AGQALAAgACMASABlAGEAZABlAHIAIAB0AGgAIAB7AGYAbwBuAHQALQBzAGkAegBlADoAMQA0AHAAeAA7AGIAbwByAGQAZQByADoAMQBwAHgAIABzAG8AbABpAGQAIAAjADkAOABiAGYAMgAxADsAcABhAGQAZABpAG4AZwA6ADMAcAB4ACAANwBwAHgAIAAyAHAAeAAgADcAcAB4ADsAfQANAAoACQAjAEgAZQBhAGQAZQByACAAdABoACAAewBmAG8AbgB0AC0AcwBpAHoAZQA6ADEANABwAHgAOwB0AGUAeAB0AC0AYQBsAGkAZwBuADoAbABlAGYAdAA7AHAAYQBkAGQAaQBuAGcALQB0AG8AcAA6ADUAcAB4ADsAcABhAGQAZABpAG4AZwAtAGIAbwB0AHQAbwBtADoANABwAHgAOwBiAGEAYwBrAGcAcgBvAHUAbgBkAC0AYwBvAGwAbwByADoAIwBBADcAQwA5ADQAMgA7AGMAbwBsAG8AcgA6ACMAZgBmAGYAOwB9AA0ACgAJACMASABlAGEAZABlAHIAIAB0AHIALgBhAGwAdAAgAHQAZAAgAHsAYwBvAGwAbwByADoAIwAwADAAMAA7AGIAYQBjAGsAZwByAG8AdQBuAGQALQBjAG8AbABvAHIAOgAjAEUAQQBGADIARAAzADsAfQANAAoACQA8AC8AUwB0AHkAbABlAD4A')))

    ${_/=\/=\_/======\/} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('PABIAFQATQBMAD4APABCAE8ARABZAD4APABUAGEAYgBsAGUAIABiAG8AcgBkAGUAcgA9ADEAIABjAGUAbABsAHAAYQBkAGQAaQBuAGcAPQAwACAAYwBlAGwAbABzAHAAYQBjAGkAbgBnAD0AMAAgAHcAaQBkAHQAaAA9ADEAMAAwACUAIABpAGQAPQBIAGUAYQBkAGUAcgA+AA0ACgAJAAkAPABUAFIAPgANAAoACQAJAAkAPABUAEgAPgA8AEIAPgBDAG8AbQBwAHUAdABlAHIAIABOAGEAbQBlADwALwBCAD4APAAvAFQASAA+AA0ACgAJAAkACQA8AFQASAA+ADwAQgA+AEEAbABlAHIAdAAgAFQAaQB0AGwAZQA8AC8AQgA+ADwALwBUAEQAPgANAAoACQAJAAkAPABUAEgAPgA8AEIAPgBBAGwAZQByAHQAIABEAGUAcwBjAHIAaQBwAHQAaQBvAG4APAAvAEIAPgA8AC8AVABIAD4ADQAKAAkACQAJADwAVABIAD4APABCAD4AVABpAG0AZQAgAFIAYQBpAHMAZQBkADwALwBCAD4APAAvAFQASAA+AA0ACgAJAAkACQA8AFQASAA+ADwAQgA+AFMAZQB2AGUAcgBpAHQAeQA8AC8AQgA+ADwALwBUAEgAPgANAAoACQAJADwALwBUAFIAPgA=')))

	Foreach(${/=\_/=\/=\/\/=\__} in ${___/\_____/=\/=\_})
    {
        ${_/=\/=\_/======\/} += "<TR>
					<TD>$(${/=\_/=\/=\/\/=\__}.PrincipalName)</TD>
					<TD>$(${/=\_/=\/=\/\/=\__}.Name)</TD>
					<TD>$(${/=\_/=\/=\/\/=\__}.Description)</TD>
					<TD>$(${/=\_/=\/=\/\/=\__}.TimeRaised)</TD>
					<TD>$(${/=\_/=\/=\/\/=\__}.Severity)</TD>
				</TR>"
    }
    ${_/=\/=\_/======\/} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('PAAvAFQAYQBiAGwAZQA+ADwALwBCAE8ARABZAD4APAAvAEgAVABNAEwAPgA=')))

	${_/=\/=\_/======\/} | Out-File ${___/=\/\/\/=\___/}
}