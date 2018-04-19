# Failsafe
break


# <Will be removed in final slide, need to update my profile (including prompt)>
# Importing dbatools so it all will work
#Import-Module dbatools
#. .\importinternals.ps1






 #----------------------------------------------------------------------------# 
 #                  Drowning users in a sea of blood ... not                  # 
 #----------------------------------------------------------------------------# 

# This is going to be bloody
Get-ChildItem C:\doesntexist

# So is this
throw "Some error happened"

# This is ... not going to be bloody. But bloody useless for scripting!
try { Write-Warning "Some error happened" }
catch { "Error reaction incoming ... not!"}

# Make it optional
try { throw "Some error happened" }
catch {
    if ($ThrowExceptions) { throw }
    else { Write-Warning $_ }
}
# Opt in
$ThrowExceptions = $true

#####
# Works, but messy

# Solution
$EnableException = $false
Stop-Function -Message "Some error happened"
$EnableException = $true
Stop-Function -Message "Some error happened"

#####
# Demo function
#TODO: Replace with real functionality
function Get-Test {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline = $true)]
        [int[]]
        $Numbers,
        [switch]$Foo,
        [switch]$Bar,
        [switch]$EnableException
    )
    begin {
        if ($Foo) {
            Stop-Function -Message "Failing as ordered to"
            return
        }
    }
    process {
        if (Test-FunctionInterrupt) { return }

        foreach ($number in $Numbers) {
            if (($number -eq 2) -and ($Bar)) {
                try { Get-DbaBackupHistory -SqlInstance . -SqlCredential $cred -EnableException }
                catch { Stop-Function -Message "Failing" -ErrorRecord $_ -Continue }
            }
            $number
        }
    }
}
# No errors wanted
1..3 | Get-Test
# Kill it in begin
1..3 | Get-Test -Foo
# Need more blood
1..3 | Get-Test -Foo -EnableException
# Don't waste it!
try { 1..3 | Get-Test -Foo -EnableException }
catch { "Something broke" }

# Killing in process
1..3 | Get-Test -Bar
1..3 | Get-Test -Bar -EnableException


 #----------------------------------------------------------------------------# 
 #                               Configuration                                # 
 #----------------------------------------------------------------------------# 

<#
#TODO: Remove before presentation
Basic Issue: Growing option Complexity as command meta-level rises
functionA calls functionB calls functionC calls functionD
- Pass through all parameters?
--> Either provide incredibly complex parameters or choose for the user.
--> Not every choice is right for everybody
- How do you control behavior that doesn't have a command?

--> Need for options separate from commands
#>

# PSReadline has options in dedicated command
Get-PSReadlineOption

<#
Issue: The more options, the less usable a command with parameters for each of them

Solution:
- Option as parameter value, not parameter
#>

Get-DbaConfig
Get-DbaConfig | Out-GridView

<#
To note:
- Supports option documentation
- Supports input validation
- Supports reacting to setting changes
#>

$paramSetDbaConfig = @{
	FullName    = 'sql.connection.encrypt'
	Value	    = $true
	Initialize  = $true # Only during module definition
	Validation  = 'bool'
	Handler	    = { Write-Host ("Setting SQL connection encryption to: {0}" -f $args[0]) }
	Description = "Whether SQL connections should be encrypted. Don't disable unless you REALLY must."
}

Set-DbaConfig @paramSetDbaConfig
Get-DbaConfig 'sql.connection.encrypt'
Set-DbaConfig 'sql.connection.encrypt' "foo"
Set-DbaConfig 'sql.connection.encrypt' $false

#TODO: Implement in Connect-SqlInstance (Internal connection function)
Get-DbaConfigValue -FullName 'sql.connection.encrypt'

Set-DbaConfig 'sql.connection.encrypt' $true

<#
Notes on implementation:
- Available in all runspaaces
- Scales well
- Easy to split configuration definition in to logic groups
#>

<#
Additional features:
- Settings can be persisted per user or per machine
- Can be controlled via GPO/DSC/SCCM
#>


 #----------------------------------------------------------------------------# 
 #                                   Logging                                  # 
 #----------------------------------------------------------------------------# 

# Dbatools logs quite a bit
Get-DbaConfigValue -FullName 'path.dbatoolslogpath' | Invoke-Item

New-DbatoolsSupportPackage

<#
Challenges:
- Performance
- Size
- Usability & integration
- Access conflicts
#>

# Usability: Building on the known
#---------------------------------

# Bad
Write-Verbose -Message "Something" -Verbose

# Good
Write-Message -Level Verbose -Message "Something" -Verbose
Write-Message -Level SomewhatVerbose -Message "Something" -Verbose

<#
Levels:
Critical, Important, Output, Significant, VeryVerbose, Verbose, SomewhatVerbose, System, Debug, InternalComment, Warning
#>
Write-Message -Level VeryVerbose -Message "Something"
Set-DbaConfig 'message.maximuminfo' 4
Write-Message -Level VeryVerbose -Message "Something"
#TODO: Fix this thing, then kill TODO

# Performance
#------------

Get-Runspace | ft -AutoSize

# Avoid duplication through C# static management
Get-DbaRunspace

# Script doing the actual logging
#TODO: Fix path
code "D:\Code\Github\dbatools\internal\scripts\logfilescript.ps1"


# Size
#-----

Get-DbaConfig logging.*


# Integrated rotate


# Access Conflicts
#-----------------

<#
- One writing thread per process
- Output files named for computer and process ID
#>


# The Other Things
#-----------------

# Forensics!
Get-DbatoolsLog | Out-GridView
Write-Message -Level Verbose -Message "Something new"


 #----------------------------------------------------------------------------# 
 #                         DbaInstance Parameter class                        # 
 #----------------------------------------------------------------------------# 

<#
Original Situation:
- Accept anything, then interpret
- Some contributors / team members would just assume string
- Non-uniform validations
--> Unmanaged madness
#>

<#
Challenge:
- Uniform user experience on input
- Validation overhead
- Converting input from multiple sources
- Passing through live connections
- Keeping it usable for average contributors!!
#>

<#
Answer: Parameter Classes
#>
[DbaInstance]"foo"
[DbaInstance]"."
[DbaInstance]"foo\bar"
[DbaInstance]"Server=foo\bar;"
[DbaInstance]"(localdb)\foo"
[DbaInstance]([System.Net.DNS]::GetHostEntry("localhost"))
[DbaInstance](Get-ADComputer "Odin") #TODO: Set up setup to include connection to AD VM
[DbaInstance](Connect-DbaInstance -SqlInstance localhost)
[DbaInstance]"foo bar"
[DbaInstance]"foo\select"

<#
- Conversion/interpretation as parameter binding
- Pass through original input
- Validation as parameter binding

All the contributors need to do is replace [string] or [object] with [DbaInstance]

Additional benefit:
- Scales exquisitely well: 30 Minutes of work had 380 commands accept localdb
  as input and work correctly against it.
#>


 #----------------------------------------------------------------------------# 
 #                          Import Sequence & Tuning                          # 
 #----------------------------------------------------------------------------# 

#TODO: Kill (Guide through structure) <-- Probably no time

<#
- Parallel import of
-- Functions
-- Libraries
-- Configurations

- Off-Load of
-- Tab Completion

- Measuring each step
#>

<#
Import Options
- Dot Sourcing (Import Speed)
- Copy DLL files before import (To support update function on legacy systems without Side-by-Side)
- Always Compile (Compile library on import; For devs)
- Serial Import (Slower import, less resource spike)
#>

[SqlCollaborative.Dbatools.dbaSystem.DebugHost]::ImportTime | Out-GridView