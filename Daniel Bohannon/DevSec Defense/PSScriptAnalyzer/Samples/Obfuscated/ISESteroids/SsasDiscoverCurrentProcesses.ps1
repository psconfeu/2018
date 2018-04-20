<#
  .SYNOPSIS
    SSAS Discover Current Processes

  .DESCRIPTION
    For the SQL Server database engine there is an Activity Monitor available in SSMS by default, for
	SSAS Analysis Services there is only a project "Activity Viewer" at CodePlex available; see links.
    In version 2008 of SSAS DMV (dynamic management views) where introduced, which can be used to query
    current connections and activities. Unfortunally you can't "join" 2 or more DMV in one MDX query to
	a get a complete overview at once.
	This Powershell queries the SSAS DMV for current connections, session and commands and prompts the results
	as a formatted list to give a quick overview of activities.
	Additional it returns an overview with cummulated values like count of session, total send bytes and so on.

  .NOTES
    Author  : Olaf Helper
	Version : 1.0
	Release : 2011-12-30

  .REQUIREMENTS
    Powershell 1.0 or higher version.
	SSAS 2008 or higher version.
	AdoMd Client for SSAS 2008 or higher.
 
 .REMARKS
    All date time values are in UTC.
    Works with SSAS 2008 and higher versions.

  .LINKS
    AS AdoMd Client from SQL Server 2008 Feature Pack
	  http://www.microsoft.com/download/en/details.aspx?id=6375
    CodePlex Microsoft SQL Server Community Samples: Analysis Services => Activity Viewer
	  http://sqlsrvanalysissrvcs.codeplex.com/
	$SYSTEM.DISCOVER_CONNECTIONS
	  http://msdn.microsoft.com/en-us/library/bb934105.aspx
	$SYSTEM.DISCOVER_SESSIONS
	  http://msdn.microsoft.com/en-us/library/bb934101.aspx
	$SYSTEM.DISCOVER_COMMANDS
	  http://msdn.microsoft.com/en-us/library/bb934103.aspx
#>
# Please modify the server name.
[string] ${__/\_/===\/\____/} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBlAHIAdgBlAHIATgBhAG0AZQBcAEkAbgBzAHQAYQBuAGMAZQBOAGEAbQBlAA==')));
[bool] ${_/=\/\/\/==\/\___} = $false;
cls;
# Format definitions for the table outputs.
${/=====\/==\__/=\_} = (@{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwBvAG4AbgBJAEQA'))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cgBpAGcAaAB0AA=='))) ; Width=9 ; Expression={$_.ConnID} ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TABhAHMAdAAgAEMAbwBtAG0AYQBuAGQAIABTAHQAYQByAHQA'))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bABlAGYAdAA='))) ; Width=20 ; Expression={$_.LastCmdStartTime} ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TABhAHMAdAAgAEMAbwBtAG0AYQBuAGQAIABFAG4AZAA='))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bABlAGYAdAA='))) ; Width=20 ; Expression={$_.LastCmdEndTime} ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VQBzAGUAcgAgAE4AYQBtAGUA'))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bABlAGYAdAA='))) ; Width=20 ; Expression={$_.UserName} ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('SABvAHMAdAAgAE4AYQBtAGUA'))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bABlAGYAdAA='))) ; Width=20 ; Expression={$_.HostName} ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QQBwAHAAbABpAGMAYQB0AGkAbwBuAA=='))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bABlAGYAdAA='))) ; Width=60 ; Expression={$_.HostApplication} ; } `
           );
${___/\/==\__/==\_/} = (@{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBwAGkAZAA='))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cgBpAGcAaAB0AA=='))) ; Width=9 ; Expression={$_.Spid} ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TABhAHMAdAAgAEMAbwBtAG0AYQBuAGQAIABTAHQAYQByAHQA'))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bABlAGYAdAA='))) ; Width=20 ; Expression={$_.LastCmdStartTime} ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TABhAHMAdAAgAEMAbwBtAG0AYQBuAGQAIABFAG4AZAA='))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bABlAGYAdAA='))) ; Width=20 ; Expression={$_.LastCmdEndTime} ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwBwAHUAIABzAGUAYwA='))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cgBpAGcAaAB0AA=='))) ; Width=10 ; Expression={$_.CpuTimeMs / 1000.0} ; FormatString="N1" ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBlAG0AIABLAEIA'))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cgBpAGcAaAB0AA=='))) ; Width=9 ; Expression={$_.UsedMemory} ; FormatString="N0" ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwB1AHIAcgBlAG4AdAAgAEQAQgA='))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bABlAGYAdAA='))) ; Width=20 ; Expression={$_.CurrentDB} ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TABhAHMAdAAgAEMAbwBtAG0AYQBuAGQA'))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bABlAGYAdAA='))) ; Width=60 ; Expression={$_.LastCommand} ; } `
           );
${/====\_/=\_/==\/=} =  (@{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBwAGkAZAA='))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cgBpAGcAaAB0AA=='))) ; Width=9 ; Expression={$_.Spid} ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwBvAG0AbQBhAG4AZAAgAFMAdABhAHIAdAAgAFQAaQBtAGUA'))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bABlAGYAdAA='))) ; Width=20 ; Expression={$_.StartTime} ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwBvAG0AbQBhAG4AZAAgAEUAbgBkACAAVABpAG0AZQA='))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bABlAGYAdAA='))) ; Width=20 ; Expression={$_.EndTime} ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwBwAHUAIABzAGUAYwA='))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cgBpAGcAaAB0AA=='))) ; Width=10 ; Expression={$_.CpuTimeMs / 1000.0} ; FormatString="N1" ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UgBlAGEAZABzAA=='))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cgBpAGcAaAB0AA=='))) ; Width=9 ; Expression={$_.Reads} ; FormatString="N0" ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UgBlAGEAZAAgAEsAQgA='))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cgBpAGcAaAB0AA=='))) ; Width=9 ; Expression={$_.ReadKB} ; FormatString="N0" ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwBtAGQAcwAgACMA'))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cgBpAGcAaAB0AA=='))) ; Width=10 ; Expression={$_.CmdCount} ; FormatString="N0" ; }, `
            @{ Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwBvAG0AbQBhAG4AZAA='))) ; Alignment=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bABlAGYAdAA='))) ; Width=60 ; Expression={$_.CmdText} ; } `
           );
# Load AMO assembly.
[System.Reflection.Assembly]::LoadWithPartialName($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBpAGMAcgBvAHMAbwBmAHQALgBBAG4AYQBsAHkAcwBpAHMAUwBlAHIAdgBpAGMAZQBzAC4AQQBkAG8AbQBkAEMAbABpAGUAbgB0AA==')))) | Out-Null;
Write-Host ((Get-Date -format yyyy-MM-dd-HH:mm:ss) + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('OgAgAFMAdABhAHIAdABlAGQAIAAuAC4ALgAKAA=='))));
${___/\_____/=\/===} = New-Object Microsoft.AnalysisServices.AdomdClient.AdomdConnection;
${___/\_____/=\/===}.ConnectionString = $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RABhAHQAYQAgAFMAbwB1AHIAYwBlAD0AJAB7AF8AXwAvAFwAXwAvAD0APQA9AFwALwBcAF8AXwBfAF8ALwB9ADsAUwBzAHAAcgBvAHAASQBuAGkAdABBAHAAcABOAGEAbQBlAD0AUABvAHcAZQByAFMAaABlAGwAbAAgAFMAcwBhAHMARABpAHMAYwBvAHYAZQByAEMAdQByAHIAZQBuAHQAUAByAG8AYwBlAHMAcwBlAHMAOwA=')))
${___/\_____/=\/===}.Open();
${_/\_/===\______/=} = New-Object Microsoft.AnalysisServices.AdomdClient.AdomdCommand;
${_/\_/===\______/=}.Connection = ${___/\_____/=\/===};
${_/\___/=====\/\_/} = New-Object Microsoft.AnalysisServices.AdomdClient.AdomdDataAdapter;
# Get the Id's of my own connection to exclude it.
[String] ${/=\/\/==\/=\_/===} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('DQAKAFMARQBMAEUAQwBUACAAUwBFAFMAUwBJAE8ATgBfAEMATwBOAE4ARQBDAFQASQBPAE4AXwBJAEQAIABBAFMAIABDAG8AbgBuAEkARAANAAoAIAAgACAAIAAgACAALABTAEUAUwBTAEkATwBOAF8ASQBEACAAQQBTACAAUwBlAHMAcwBpAG8AbgBJAEQADQAKACAAIAAgACAAIAAgACwAUwBFAFMAUwBJAE8ATgBfAFMAUABJAEQAIABBAFMAIABTAHAAaQBkAA0ACgBGAFIATwBNACAAJABTAFkAUwBUAEUATQAuAEQASQBTAEMATwBWAEUAUgBfAFMARQBTAFMASQBPAE4AUwANAAoAVwBIAEUAUgBFACAAUwBFAFMAUwBJAE8ATgBfAEkARAAgAD0AIAAnAA=='))) + ${___/\_____/=\/===}.SessionID + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('JwANAAoATwBSAEQARQBSACAAQgBZACAAUwBFAFMAUwBJAE8ATgBfAEMATwBOAE4ARQBDAFQASQBPAE4AXwBJAEQAOwA=')))
${_/\_/===\______/=}.CommandText = ${/=\/\/==\/=\_/===};
${_/\___/=====\/\_/}.SelectCommand = ${_/\_/===\______/=};
${__/\/\___/=\/\_/=} = New-Object System.Data.DataTable;
${/==\/\______/====} = ${_/\___/=====\/\_/}.Fill(${__/\/\___/=\/\_/=});
${_/======\_/\__/=\} = ${__/\/\___/=\/\_/=}.Rows[0];
# Querying the connection informations
${/=\/\/==\/=\_/===} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('DQAKAFMARQBMAEUAQwBUACAAQwBPAE4ATgBFAEMAVABJAE8ATgBfAEkARAAgAEEAUwAgAEMAbwBuAG4ASQBEAA0ACgAgACAAIAAgACAAIAAsAEMATwBOAE4ARQBDAFQASQBPAE4AXwBVAFMARQBSAF8ATgBBAE0ARQAgAEEAUwAgAFsAVQBzAGUAcgBOAGEAbQBlAF0ADQAKACAAIAAgACAAIAAgACwAQwBPAE4ATgBFAEMAVABJAE8ATgBfAEgATwBTAFQAXwBOAEEATQBFACAAQQBTACAASABvAHMAdABOAGEAbQBlAA0ACgAgACAAIAAgACAAIAAsAEMATwBOAE4ARQBDAFQASQBPAE4AXwBIAE8AUwBUAF8AQQBQAFAATABJAEMAQQBUAEkATwBOACAAQQBTACAASABvAHMAdABBAHAAcABsAGkAYwBhAHQAaQBvAG4ADQAKACAAIAAgACAAIAAgACwAQwBPAE4ATgBFAEMAVABJAE8ATgBfAFMAVABBAFIAVABfAFQASQBNAEUAIABBAFMAIABTAHQAYQByAHQAVABpAG0AZQANAAoAIAAgACAAIAAgACAALABDAE8ATgBOAEUAQwBUAEkATwBOAF8ATABBAFMAVABfAEMATwBNAE0AQQBOAEQAXwBTAFQAQQBSAFQAXwBUAEkATQBFACAAQQBTACAATABhAHMAdABDAG0AZABTAHQAYQByAHQAVABpAG0AZQANAAoAIAAgACAAIAAgACAALABDAE8ATgBOAEUAQwBUAEkATwBOAF8ATABBAFMAVABfAEMATwBNAE0AQQBOAEQAXwBFAE4ARABfAFQASQBNAEUAIABBAFMAIABMAGEAcwB0AEMAbQBkAEUAbgBkAFQAaQBtAGUADQAKACAAIAAgACAAIAAgACwAQwBPAE4ATgBFAEMAVABJAE8ATgBfAEIAWQBUAEUAUwBfAFMARQBOAFQAIABBAFMAIABCAHkAdABlAHMAUwBlAG4AdAANAAoAIAAgACAAIAAgACAALABDAE8ATgBOAEUAQwBUAEkATwBOAF8ARABBAFQAQQBfAEIAWQBUAEUAUwBfAFIARQBDAEUASQBWAEUARAAgAEEAUwAgAEIAeQB0AGUAcwBSAGUAYwBlAGkAdgBlAGQADQAKAEYAUgBPAE0AIAAkAFMAWQBTAFQARQBNAC4ARABJAFMAQwBPAFYARQBSAF8AQwBPAE4ATgBFAEMAVABJAE8ATgBTAA0ACgBXAEgARQBSAEUAIABDAE8ATgBOAEUAQwBUAEkATwBOAF8ASQBEACAAPAA+ACAA'))) + ${_/======\_/\__/=\}.ConnID + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('DQAKAE8AUgBEAEUAUgAgAEIAWQAgAEMATwBOAE4ARQBDAFQASQBPAE4AXwBJAEQAOwA=')))
${_/\_/===\______/=}.CommandText = ${/=\/\/==\/=\_/===};
${_/\___/=====\/\_/}.SelectCommand = ${_/\_/===\______/=};
${__/\/=\_/\/=====\} = New-Object System.Data.DataTable;
${/==\/\______/====} = ${_/\___/=====\/\_/}.Fill(${__/\/=\_/\/=====\});
# Querying the session informations
${/=\/\/==\/=\_/===} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('DQAKAFMARQBMAEUAQwBUACAAUwBFAFMAUwBJAE8ATgBfAEMATwBOAE4ARQBDAFQASQBPAE4AXwBJAEQAIABBAFMAIABDAG8AbgBuAEkARAANAAoAIAAgACAAIAAgACAALABTAEUAUwBTAEkATwBOAF8ASQBEACAAQQBTACAAUwBlAHMAcwBpAG8AbgBJAEQADQAKACAAIAAgACAAIAAgACwAUwBFAFMAUwBJAE8ATgBfAFMAUABJAEQAIABBAFMAIABTAHAAaQBkAA0ACgAgACAAIAAgACAAIAAsAFMARQBTAFMASQBPAE4AXwBVAFMARQBSAF8ATgBBAE0ARQAgAEEAUwAgAFsAVQBzAGUAcgBOAGEAbQBlAF0ADQAKACAAIAAgACAAIAAgACwAUwBFAFMAUwBJAE8ATgBfAEMAVQBSAFIARQBOAFQAXwBEAEEAVABBAEIAQQBTAEUAIABBAFMAIABDAHUAcgByAGUAbgB0AEQAQgANAAoAIAAgACAAIAAgACAALABTAEUAUwBTAEkATwBOAF8AVQBTAEUARABfAE0ARQBNAE8AUgBZACAAQQBTACAAVQBzAGUAZABNAGUAbQBvAHIAeQANAAoAIAAgACAAIAAgACAALABTAEUAUwBTAEkATwBOAF8AUwBUAEEAUgBUAF8AVABJAE0ARQAgAEEAUwAgAFMAdABhAHIAdABUAGkAbQBlAA0ACgAgACAAIAAgACAAIAAsAFMARQBTAFMASQBPAE4AXwBMAEEAUwBUAF8AQwBPAE0ATQBBAE4ARAAgAEEAUwAgAEwAYQBzAHQAQwBvAG0AbQBhAG4AZAANAAoAIAAgACAAIAAgACAALABTAEUAUwBTAEkATwBOAF8ATABBAFMAVABfAEMATwBNAE0AQQBOAEQAXwBTAFQAQQBSAFQAXwBUAEkATQBFACAAQQBTACAATABhAHMAdABDAG0AZABTAHQAYQByAHQAVABpAG0AZQANAAoAIAAgACAAIAAgACAALABTAEUAUwBTAEkATwBOAF8ATABBAFMAVABfAEMATwBNAE0AQQBOAEQAXwBFAE4ARABfAFQASQBNAEUAIABBAFMAIABMAGEAcwB0AEMAbQBkAEUAbgBkAFQAaQBtAGUADQAKACAAIAAgACAAIAAgACwAUwBFAFMAUwBJAE8ATgBfAEwAQQBTAFQAXwBDAE8ATQBNAEEATgBEAF8AQwBQAFUAXwBUAEkATQBFAF8ATQBTACAAQQBTACAATABhAHMAdABDAG0AZABDAHAAdQBUAGkAbQBlAE0AcwANAAoAIAAgACAAIAAgACAALABTAEUAUwBTAEkATwBOAF8AQwBPAE0ATQBBAE4ARABfAEMATwBVAE4AVAAgAEEAUwAgAEMAbQBkAEMAbwB1AG4AdAANAAoAIAAgACAAIAAgACAALABTAEUAUwBTAEkATwBOAF8AQwBQAFUAXwBUAEkATQBFAF8ATQBTACAAQQBTACAAQwBwAHUAVABpAG0AZQBNAHMADQAKACAAIAAgACAAIAAgACwAUwBFAFMAUwBJAE8ATgBfAFIARQBBAEQAUwAgAEEAUwAgAFIAZQBhAGQAcwANAAoAIAAgACAAIAAgACAALABTAEUAUwBTAEkATwBOAF8AUgBFAEEARABfAEsAQgAgAEEAUwAgAFIAZQBhAGQASwBCAA0ACgBGAFIATwBNACAAJABTAFkAUwBUAEUATQAuAEQASQBTAEMATwBWAEUAUgBfAFMARQBTAFMASQBPAE4AUwANAAoAVwBIAEUAUgBFACAAUwBFAFMAUwBJAE8ATgBfAEMATwBOAE4ARQBDAFQASQBPAE4AXwBJAEQAIAA8AD4AIAA='))) + ${_/======\_/\__/=\}.ConnID + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('DQAKAE8AUgBEAEUAUgAgAEIAWQAgAFMARQBTAFMASQBPAE4AXwBDAE8ATgBOAEUAQwBUAEkATwBOAF8ASQBEADsA')))
${_/\_/===\______/=}.CommandText = ${/=\/\/==\/=\_/===};
${_/\___/=====\/\_/}.SelectCommand = ${_/\_/===\______/=};
${__/\/=\/\/\___/\_} = New-Object System.Data.DataTable;
${/==\/\______/====} = ${_/\___/=====\/\_/}.Fill(${__/\/=\/\/\___/\_});
# Querying the command informations
${/=\/\/==\/=\_/===} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('DQAKAFMARQBMAEUAQwBUACAAUwBFAFMAUwBJAE8ATgBfAFMAUABJAEQAIABBAFMAIABTAHAAaQBkAA0ACgAgACAAIAAgACAAIAAsAFMARQBTAFMASQBPAE4AXwBDAE8ATQBNAEEATgBEAF8AQwBPAFUATgBUACAAQQBTACAAQwBtAGQAQwBvAHUAbgB0AA0ACgAgACAAIAAgACAAIAAsAEMATwBNAE0AQQBOAEQAXwBTAFQAQQBSAFQAXwBUAEkATQBFACAAQQBTACAAUwB0AGEAcgB0AFQAaQBtAGUADQAKACAAIAAgACAAIAAgACwAQwBPAE0ATQBBAE4ARABfAEUATgBEAF8AVABJAE0ARQAgAEEAUwAgAEUAbgBkAFQAaQBtAGUADQAKACAAIAAgACAAIAAgACwAQwBPAE0ATQBBAE4ARABfAEMAUABVAF8AVABJAE0ARQBfAE0AUwAgAEEAUwAgAEMAcAB1AFQAaQBtAGUATQBzAA0ACgAgACAAIAAgACAAIAAsAEMATwBNAE0AQQBOAEQAXwBSAEUAQQBEAFMAIABBAFMAIABSAGUAYQBkAHMADQAKACAAIAAgACAAIAAgACwAQwBPAE0ATQBBAE4ARABfAFIARQBBAEQAXwBLAEIAIABBAFMAIABSAGUAYQBkAEsAYgANAAoAIAAgACAAIAAgACAALABDAE8ATQBNAEEATgBEAF8AVABFAFgAVAAgAEEAUwAgAEMAbQBkAFQAZQB4AHQADQAKAEYAUgBPAE0AIAAkAFMAWQBTAFQARQBNAC4ARABJAFMAQwBPAFYARQBSAF8AQwBPAE0ATQBBAE4ARABTAA0ACgBXAEgARQBSAEUAIABTAEUAUwBTAEkATwBOAF8AUwBQAEkARAAgADwAPgAgAA=='))) + ${_/======\_/\__/=\}.Spid + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('DQAKAE8AUgBEAEUAUgAgAEIAWQAgAFMARQBTAFMASQBPAE4AXwBTAFAASQBEADsA')));
${_/\_/===\______/=}.CommandText = ${/=\/\/==\/=\_/===};
${_/\___/=====\/\_/}.SelectCommand = ${_/\_/===\______/=};
${_/=\/\_/\/\/\____} = New-Object System.Data.DataTable;
${/==\/\______/====} = ${_/\___/=====\/\_/}.Fill(${_/=\/\_/\/\/\____});
if (!${_/=\/\/\/==\/\___})
{
    Write-Host;
    foreach (${_/\_/========\_/=} in (${__/\/=\_/\/=====\}.Rows | sort ConnId))
    {
        # Separator for a better overview.
        Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwBvAG4AbgBlAGMAdABpAG8AbgA='))) ${_/\_/========\_/=}.ConnID $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bwBmACAAdQBzAGUAcgA='))) ${_/\_/========\_/=}.UserName $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('KgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqACoAKgAqAA==')))`
                   -ForegroundColor Blue;
        echo ${_/\_/========\_/=} | ft (${/=====\/==\__/=\_});
        # Session details for the connection.
        echo (${__/\/=\/\/\___/\_}.Rows) | ? {$_.ConnID -eq ${_/\_/========\_/=}.ConnID} | sort Spid | ft (${___/\/==\__/==\_/});
        [long[]] ${/=\/====\/==\/\__} = ((${__/\/=\/\/\___/\_}.Rows) | ? {$_.ConnID -eq ${_/\_/========\_/=}.ConnID} | select Spid).Spid;
        # Command details for the connection.
        echo (${_/=\/\_/\/\/\____}.Rows) | ? {${/=\/====\/==\/\__} -contains $_.Spid} | sort Spid | ft (${/====\_/=\_/==\/=});
    }
}
Write-Host $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBzAGEAcwAgAFAAcgBvAGMAZQBzAHMAIABPAHYAZQByAHYAaQBlAHcAIABvAGYAIAAkAHsAXwBfAC8AXABfAC8APQA9AD0AXAAvAFwAXwBfAF8AXwAvAH0AIAA6AA=='))) -ForegroundColor Blue;
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwBvAG4AbgBlAGMAdABpAG8AbgBzACAAIwA6ACAAIAA='))) (${__/\/=\_/\/=====\} | measure).Count;
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBlAG4AZAAgAHQAbwB0AGEAbAA6ACAAIAAgACAAIAA='))) ([Math]::Round((${__/\/=\_/\/=====\} | measure -sum -Property BytesSent).Sum / 1024, 1)) "KB";
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UgBlAGMAZQBpAHYAZQBkACAAdABvAHQAYQBsADoAIAA='))) ([Math]::Round((${__/\/=\_/\/=====\} | measure -sum -Property BytesReceived).Sum / 1024, 1)) $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('SwBCAAoA')));
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBlAHMAcwBpAG8AbgBzACAAIwA6ACAAIAAgACAAIAA='))) (${__/\/=\/\/\___/\_} | measure).Count;
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VABvAHQAYQBsACAAdQBzAGUAZAAgAG0AZQBtADoAIAA='))) ([Math]::Round((${__/\/=\/\/\___/\_} | measure -sum -Property UsedMemory).Sum / 1024, 1)) "KB";
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VABvAHQAYQBsACAAYwBvAG0AbQBhAG4AZABzADoAIAA='))) ((${__/\/=\/\/\___/\_} | measure -sum -Property CmdCount).Sum);
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwBwAHUAIAB0AGkAbQBlADoAIAAgACAAIAAgACAAIAA='))) ([Math]::Round((${__/\/=\/\/\___/\_} | measure -sum -Property CpuTimeMs).Sum / 1000, 1)) $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cwBlAGMA')));
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UgBlAGEAZABzACAAIwA6ACAAIAAgACAAIAAgACAAIAA='))) ((${__/\/=\/\/\___/\_} | measure -sum -Property Reads).Sum);
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UgBlAGEAZAAgAGQAYQB0AGEAOgAgACAAIAAgACAAIAA='))) ((${__/\/=\/\/\___/\_} | measure -sum -Property ReadKB).Sum) $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('SwBCAAoA')));
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwBvAG0AbQBhAG4AZABzACAAIwA6ACAAIAAgACAAIAA='))) (${_/=\/\_/\/\/\____} | measure).Count;
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwB1AHIAcgAuACAAcgB1AG4AbgBpAG4AZwA6ACAAIAA='))) (${_/=\/\_/\/\/\____} | ? {$_.EndTime.ToString() -eq ""} | measure).Count;
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwBwAHUAIAB0AGkAbQBlADoAIAAgACAAIAAgACAAIAA='))) ([Math]::Round((${_/=\/\_/\/\/\____} | measure -sum -Property CpuTimeMs).Sum / 1000, 1)) $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cwBlAGMA')));
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UgBlAGEAZABzACAAIwA6ACAAIAAgACAAIAAgACAAIAA='))) ((${_/=\/\_/\/\/\____} | measure -sum -Property Reads).Sum);
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UgBlAGEAZAAgAGQAYQB0AGEAOgAgACAAIAAgACAAIAA='))) ((${_/=\/\_/\/\/\____} | measure -sum -Property ReadKB).Sum) $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('SwBCAAoA')));
# Closing & Disposing all objects.
${_/\___/=====\/\_/}.Dispose();
${__/\/\___/=\/\_/=}.Dispose();
${__/\/=\_/\/=====\}.Dispose();
${__/\/=\/\/\___/\_}.Dispose();
${_/=\/\_/\/\/\____}.Dispose();
${_/\_/===\______/=}.Dispose();
${___/\_____/=\/===}.Close();
${___/\_____/=\/===}.Dispose();
Write-Host;
Write-Host ((Get-Date -format yyyy-MM-dd-HH:mm:ss) + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('OgAgAEYAaQBuAGkAcwBoAGUAZAA='))))