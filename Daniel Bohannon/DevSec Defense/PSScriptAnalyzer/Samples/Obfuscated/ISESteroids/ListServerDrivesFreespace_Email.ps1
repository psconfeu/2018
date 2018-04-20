<#
 .SYNOPSIS
    List for several machines the drives with size, free size and the percentage of free space (E-Mail).
 .DESCRIPTION
    An important duty of a DBA is to check frequently the free space of the drives the SQL Server is using to avoid a database crash if a drive is full.    
    With this PowerShell script you can easily check all drives for all servers in the given list. You can configure threshold value for Warning & Alarm level.
    Requires permission to connect to and fetch WMI data from the machine(s).
    The report is then send as an e-mail, eighter as plain text or as html content.
 .PARAMETERS
   $servers: A list of server names.
   $levelWarn: Warn-level in percent.
   $levelAlarm: Alarm-level in percent.
   $smtpServer: The name of your SMTP mail server.
   $sender: The e-mail address of the sender.
   $receiver: The e-mail address of the receiver of the e-mail.
   $subject: The subject line for the e-mail.
   $asHtml: If set to $true, the content is formatted as Html, otherwise as plain text.
 .NOTES
    Author  : Olaf Helper
    Requires: PowerShell Version 1.0
 .LINK
    TechNet Get-WmiObject
        http://technet.microsoft.com/en-us/library/dd315295.aspx
    MSDN SmtpClient
        http://msdn.microsoft.com/en-us/library/system.net.mail.smtpclient.aspx
    MSDN MailMessage
        http://msdn.microsoft.com/en-us/library/system.net.mail.mailmessage.aspx
#>
# Configuration data.
# Add your machine names to check for to the list:
[String[]] ${____/\/===\_/\/==}   = @($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBlAHIAdgBlAHIAMQA='))) `
                         ,$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBlAHIAdgBlAHIAMgA='))) `
                         ,$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBlAHIAdgBlAHIAMwA='))));
[float]  ${__/\/\_____/\/\_/}   = 20.0;
[float]  ${/=\/\_/=\/\/===\_}  = 10.0;
[string] ${/=\_/\/\_/======\}  = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('WQBvAHUAUwBtAHQAcABTAGUAcgB2AGUAcgBOAGEAbQBlAA==')));
[string] ${/==\__/=======\__}      = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cwBlAG4AZABlAHIAQABlAG0AYQBpAGwAYQBkAGQAcgBlAHMAcwAuAGMAbwBtAA==')));
[string] ${___/\_/==\____/\/}    = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cgBlAGMAZQBpAHYAZQByAEAAZQBtAGEAaQBsAGEAZABkAHIAZQBzAHMALgBjAG8AbQA=')));
[string] ${_/\_/\/=\_/==\/=\}     = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RABpAHMAawAgAHUAcwBhAGcAZQAgAHIAZQBwAG8AcgB0AA==')));
[bool]   ${___/==\___/\__/==}      = $true;
[string] ${__/=\/=\/\/\/\/\/} = [String]::Empty;
if (${___/==\___/\__/==})
{
	${__/=\/=\/\/\/\/\/} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('PABoAGUAYQBkAD4APAB0AGkAdABsAGUAPgBEAGkAcwBrACAAdQBzAGEAZwBlACAAcgBlAHAAbwByAHQAPAAvAHQAaQB0AGwAZQA+ADwAcwB0AHkAbABlACAAdAB5AHAAZQA9ACIAdABlAHgAdAAvAGMAcwBzACIAPgANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAC4AdABhAGIAbABlACAAewBiAG8AcgBkAGUAcgAtAGMAbwBsAGwAYQBwAHMAZQA6ACAAYwBvAGwAbABhAHAAcwBlADsAIAAgAGIAbwByAGQAZQByADoAIAAxAHAAeAAgAHMAbwBsAGkAZAAgACMAOAAwADgAMAA4ADAAOwB9AA0ACgAJAAkACQAgACAALgBwAGEAcgBhAGcAcgBhAHAAaAAgACAAewBmAG8AbgB0AC0AZgBhAG0AaQBsAHkAOgAgAEEAcgBpAGEAbAA7AGYAbwBuAHQALQBzAGkAegBlADoAbABhAHIAZwBlADsAdABlAHgAdAAtAGEAbABpAGcAbgA6ACAAbABlAGYAdAA7AGIAbwByAGQAZQByAH0ADQAKAAkACQAJACAAIAAuAGIAbwBsAGQATABlAGYAdAAgACAAIAB7AGYAbwBuAHQALQBmAGEAbQBpAGwAeQA6ACAAQQByAGkAYQBsADsAZgBvAG4AdAAtAHMAaQB6AGUAOgBsAGEAcgBnAGUAOwB0AGUAeAB0AC0AYQBsAGkAZwBuADoAIABsAGUAZgB0ADsAYgBvAHIAZABlAHIAOgAgADEAcAB4ACAAcwBvAGwAaQBkACAAIwA4ADAAOAAwADgAMAA7AH0ADQAKAAkACQAJACAAIAAuAGIAbwBsAGQAUgBpAGcAaAB0ACAAIAB7AGYAbwBuAHQALQBmAGEAbQBpAGwAeQA6ACAAQQByAGkAYQBsADsAZgBvAG4AdAAtAHMAaQB6AGUAOgBsAGEAcgBnAGUAOwB0AGUAeAB0AC0AYQBsAGkAZwBuADoAIAByAGkAZwBoAHQAOwBiAG8AcgBkAGUAcgA6ACAAMQBwAHgAIABzAG8AbABpAGQAIAAjADgAMAA4ADAAOAAwADsAfQANAAoAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAC4AcwBtAGEAbABsAEwAZQBmAHQAIAAgAHsAZgBvAG4AdAAtAGYAYQBtAGkAbAB5ADoAIABBAHIAaQBhAGwAOwB0AGUAeAB0AC0AYQBsAGkAZwBuADoAIABsAGUAZgB0ADsAYgBvAHIAZABlAHIAOgAgADEAcAB4ACAAcwBvAGwAaQBkACAAIwA4ADAAOAAwADgAMAA7AH0ADQAKAAkACQAJACAAIAAuAHMAbQBhAGwAbABSAGkAZwBoAHQAIAB7AGYAbwBuAHQALQBmAGEAbQBpAGwAeQA6ACAAQQByAGkAYQBsADsAdABlAHgAdAAtAGEAbABpAGcAbgA6ACAAcgBpAGcAaAB0ADsAYgBvAHIAZABlAHIAOgAgADEAcAB4ACAAcwBvAGwAaQBkACAAIwA4ADAAOAAwADgAMAA7AH0ADQAKACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAA8AC8AcwB0AHkAbABlAD4APAAvAGgAZQBhAGQAPgA8AGIAbwBkAHkAPgA=')));
}
else
{
	${__/=\/=\/\/\/\/\/} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RABpAHMAawAgAHUAcwBhAGcAZQAgAHIAZQBwAG8AcgB0AAoACgA=')));
}
Clear-Host;
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwB0AGEAcgB0AGUAZAA=')));
### Functions.
function ___/\_/=\/\___/===
{
    [String] ${__/==\_/\_/\_/\/\} = [String]::Empty;
	${__/==\_/\_/\_/\/\} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RAByAHYAIAA=')));
	${__/==\_/\_/\_/\/\} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VgBvAGwAIABOAGEAbQBlACAAIAAgACAAIAAgACAAIAA=')));
	${__/==\_/\_/\_/\/\} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('IAAgACAAIAAgAFMAaQB6AGUAIABNAEIAIAA=')));
	${__/==\_/\_/\_/\/\} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('IAAgACAAIAAgAEYAcgBlAGUAIABNAEIAIAA=')));
	${__/==\_/\_/\_/\/\} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('IAAgACAAIABGAHIAZQBlACAAJQAgAA==')));
	${__/==\_/\_/\_/\/\} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBlAHMAcwBhAGcAZQAgACAAIAAgACAAIAAKAA==')));
	${__/==\_/\_/\_/\/\} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('LQAtAC0AIAA=')));
	${__/==\_/\_/\_/\/\} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('LQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0AIAA=')));
	${__/==\_/\_/\_/\/\} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('LQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0AIAA=')));
	${__/==\_/\_/\_/\/\} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('LQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0AIAA=')));
	${__/==\_/\_/\_/\/\} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('LQAtAC0ALQAtAC0ALQAtAC0ALQAgAA==')));
	${__/==\_/\_/\_/\/\} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('LQAtAC0ALQAtAC0ALQAtAC0ALQAtAC0AIAAKAA==')));
	return ${__/==\_/\_/\_/\/\};
}
function ___/\______/\_/\_/
{
    param([object[]] ${_____/=\/\/\__/=\_})
    [String] ${_____/\_/=\/=\/==} = [String]::Empty;
    ${_____/\_/=\/=\/==} += ${_____/=\/\/\__/=\_}[0].ToString().PadRight(4);
	${_____/\_/=\/=\/==} += ${_____/=\/\/\__/=\_}[1].ToString().PadRight(16);
	${_____/\_/=\/=\/==} += ${_____/=\/\/\__/=\_}[2].ToString("N0").PadLeft(12) + " ";
	${_____/\_/=\/=\/==} += ${_____/=\/\/\__/=\_}[3].ToString("N0").PadLeft(12) + " ";
	${_____/\_/=\/=\/==} += ${_____/=\/\/\__/=\_}[4].ToString("N1").PadLeft(10) + " ";
	${_____/\_/=\/=\/==} += ${_____/=\/\/\__/=\_}[5].ToString().PadRight(13);
	return ${_____/\_/=\/=\/==};
}
function __/\_/=\/\/\_____/
{
	[String] ${/===\______/=====} = [String]::Empty;
	${/===\______/=====} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('PAB0AGEAYgBsAGUAIABzAHQAeQBsAGUAPQAiAHcAaQBkAHQAaAA6ACAAMQAwADAAJQAiACAAYwBsAGEAcwBzAD0AIgB0AGEAYgBsAGUAIgA+ADwAdAByACAAYwBsAGEAcwBzAD0AIgBiAG8AbABkAEwAZQBmAHQAIgA+AA0ACgAJAAkAIAAgACAAIAAgACAAIAAgADwAdABoACAAYwBsAGEAcwBzAD0AIgBiAG8AbABkAEwAZQBmAHQAIgA+AEQAcgB2ADwALwB0AGgAPgANAAoACQAJACAAIAAgACAAIAAgACAAIAA8AHQAaAAgAGMAbABhAHMAcwA9ACIAYgBvAGwAZABMAGUAZgB0ACIAPgBWAG8AbAAgAE4AYQBtAGUAPAAvAHQAaAA+AA0ACgAJAAkAIAAgACAAIAAgACAAIAAgADwAdABoACAAYwBsAGEAcwBzAD0AIgBiAG8AbABkAFIAaQBnAGgAdAAiAD4AUwBpAHoAZQAgAE0AQgA8AC8AdABoAD4ADQAKAAkACQAgACAAIAAgACAAIAAgACAAPAB0AGgAIABjAGwAYQBzAHMAPQAiAGIAbwBsAGQAUgBpAGcAaAB0ACIAPgBGAHIAZQBlACAATQBCADwALwB0AGgAPgANAAoACQAJACAAIAAgACAAIAAgACAAIAA8AHQAaAAgAGMAbABhAHMAcwA9ACIAYgBvAGwAZABSAGkAZwBoAHQAIgA+AEYAcgBlAGUAIAAlADwALwB0AGgAPgANAAoACQAJACAAIAAgACAAIAAgACAAIAA8AHQAaAAgAGMAbABhAHMAcwA9ACIAYgBvAGwAZABMAGUAZgB0ACIAPgBNAGUAcwBzAGEAZwBlADwALwB0AGgAPgA8AC8AdAByAD4A')));
	return ${/===\______/=====};
}
function __/=\/\_/=\_/=\/\_
{
    param([object[]] ${_____/=\/\/\__/=\_})
    [String] ${_____/\_/=\/=\/==} = [String]::Empty;
    ${_____/\_/=\/=\/==} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('PAB0AHIAIABjAGwAYQBzAHMAPQAiAHMAbQBhAGwAbABMAGUAZgB0ACIAPgANAAoACQAJADwAdABkACAAYwBsAGEAcwBzAD0AIgBzAG0AYQBsAGwATABlAGYAdAAiAD4A')))  + ${_____/=\/\/\__/=\_}[0].ToString()     + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('PAAvAHQAZAA+AA0ACgAJAAkAPAB0AGQAIABjAGwAYQBzAHMAPQAiAHMAbQBhAGwAbABMAGUAZgB0ACIAPgA=')))  + ${_____/=\/\/\__/=\_}[1].ToString()     + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('PAAvAHQAZAA+AA0ACgAJAAkAPAB0AGQAIABjAGwAYQBzAHMAPQAiAHMAbQBhAGwAbABSAGkAZwBoAHQAIgA+AA=='))) + ${_____/=\/\/\__/=\_}[2].ToString("N0") + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('PAAvAHQAZAA+AA0ACgAJAAkAPAB0AGQAIABjAGwAYQBzAHMAPQAiAHMAbQBhAGwAbABSAGkAZwBoAHQAIgA+AA=='))) + ${_____/=\/\/\__/=\_}[3].ToString("N0") + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('PAAvAHQAZAA+AA0ACgAJAAkAPAB0AGQAIABjAGwAYQBzAHMAPQAiAHMAbQBhAGwAbABSAGkAZwBoAHQAIgA+AA=='))) + ${_____/=\/\/\__/=\_}[4].ToString("N1") + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('PAAvAHQAZAA+AA0ACgAJAAkAPAB0AGQAIABjAGwAYQBzAHMAPQAiAHMAbQBhAGwAbABMAGUAZgB0ACIAPgA=')))  + ${_____/=\/\/\__/=\_}[5].ToString()     + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('PAAvAHQAZAA+ADwALwB0AHIAPgA=')));
	return ${_____/\_/=\/=\/==};
}
foreach(${____/\__/==\____/} in ${____/\/===\_/\/==})
{
    ${_/==\/\_/\__/=\/\} = Get-WmiObject -ComputerName ${____/\__/==\____/} -Class Win32_LogicalDisk -Filter "DriveType = 3";
	if (${___/==\___/\__/==})
	{   ${__/=\/=\/\/\/\/\/} += ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('PABwACAAYwBsAGEAcwBzAD0AIgBwAGEAcgBhAGcAcgBhAHAAaAAiAD4AUwBlAHIAdgBlAHIAOgAgAHsAMAB9AAkARAByAGkAdgBlAHMAIAAjADoAIAB7ADEAfQA8AC8AcAA+AAoA'))) -f ${____/\__/==\____/}, ${_/==\/\_/\__/=\/\}.Count);
	 	${__/=\/=\/\/\/\/\/} += __/\_/=\/\/\_____/;
	}
	else
	{	${__/=\/=\/\/\/\/\/} += ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBlAHIAdgBlAHIAOgAgAHsAMAB9AAkARAByAGkAdgBlAHMAIAAjADoAIAB7ADEAfQAKAA=='))) -f ${____/\__/==\____/}, ${_/==\/\_/\__/=\/\}.Count);
		${__/=\/=\/\/\/\/\/} += ___/\_/=\/\___/===;
	}
	foreach (${___/\_/\/\__/\_/\} in ${_/==\/\_/\__/=\/\})
	{
		[String] ${__/\/=\____/==\_/} = [String]::Empty;
		if (100.0 * ${___/\_/\/\__/\_/\}.FreeSpace / ${___/\_/\/\__/\_/\}.Size -le ${/=\/\_/=\/\/===\_})
		{   ${__/\/=\____/==\_/} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QQBsAGEAcgBtACAAIQAhACEA')));   }
		elseif (100.0 * ${___/\_/\/\__/\_/\}.FreeSpace / ${___/\_/\/\__/\_/\}.Size -le ${__/\/\_____/\/\_/})
		{   ${__/\/=\____/==\_/} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VwBhAHIAbgBpAG4AZwAgACEA')));   }
		[Object[]] ${/===\_/\_/\/\/\/=} = @(${___/\_/\/\__/\_/\}.DeviceID, `
			                 ${___/\_/\/\__/\_/\}.VolumeName, `
			                 [Math]::Round((${___/\_/\/\__/\_/\}.Size / 1048576), 0), `
							 [Math]::Round((${___/\_/\/\__/\_/\}.FreeSpace / 1048576), 0), `
							 [Math]::Round((100.0 * ${___/\_/\/\__/\_/\}.FreeSpace / ${___/\_/\/\__/\_/\}.Size), 1), `
							 ${__/\/=\____/==\_/})
		if (${___/==\___/\__/==})
		{	${__/=\/=\/\/\/\/\/} += __/=\/\_/=\_/=\/\_ -_____/=\/\/\__/=\_ ${/===\_/\_/\/\/\/=};    }
		else
		{	${__/=\/=\/\/\/\/\/} += ___/\______/\_/\_/ -_____/=\/\/\__/=\_ ${/===\_/\_/\/\/\/=};	}
	    ${__/=\/=\/\/\/\/\/} += "`n";
	}
	if (${___/==\___/\__/==})
	{   ${__/=\/=\/\/\/\/\/} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('PAAvAHQAYQBiAGwAZQA+AAoA')));	}
	else
	{	${__/=\/=\/\/\/\/\/} += "`n";	}
}
if (${___/==\___/\__/==})
{   ${__/=\/=\/\/\/\/\/} += $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('PAAvAGIAbwBkAHkAPgA=')));	}
# Init Mail address objects
${/=\/====\/====\/=} = New-Object Net.Mail.SmtpClient(${/=\_/\/\_/======\});
${_/==\_/\_/==\/\_/}  = New-Object Net.Mail.MailAddress ${/==\__/=======\__}, ${/==\__/=======\__};
${_/\___/===\/=\/=\}    = New-Object Net.Mail.MailAddress ${___/\_/==\____/\/} , ${___/\_/==\____/\/};
${__/====\_______/\}    = New-Object Net.Mail.MailMessage(${_/==\_/\_/==\/\_/}, ${_/\___/===\/=\/=\}, ${_/\_/\/=\_/==\/=\}, ${__/=\/=\/\/\/\/\/});
${__/====\_______/\}.IsBodyHtml = ${___/==\___/\__/==};
${/=\/====\/====\/=}.Send(${__/====\_______/\})
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RgBpAG4AaQBzAGgAZQBkAA==')));