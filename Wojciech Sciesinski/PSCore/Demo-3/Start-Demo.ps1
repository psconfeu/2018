## Start-Demo.ps1
## http://poshcode.org/6399
##################################################################################################
## This is an overhaul of Jeffrey Snover's original Start-Demo script by Joel "Jaykul" Bennett
##
## I've switched it to using ReadKey instead of ReadLine (you don't have to hit Enter each time)
## As a result, I've changed the names and keys for a lot of the operations, so that they make
## sense with only a single letter to tell them apart (sorry if you had them memorized).
##
## I've also been adding features as I come across needs for them, and you'll contribute your
## improvements back to the PowerShell Script repository as well.
##################################################################################################
## Revision History (version 3.5.0)
## 3.5.0 Added:    StartDelay parameter added
##       Added:	   SkipInstructions parameter added
##       Added:    The help section 'Improving ideas' added
##       Addde:    DelayAfterComment switch added, add wait time after write comments to screen
##       Fixed:    Some comments to code added
##       Fixed:    Restoring oryginal prompt corrected
## 3.4.1 Fixed:    Switches SkipAddTheEndLine and SkipAddDemoTime corrected
## 3.4.0 Fixed:    FullAuto mode corrected
##       Fixed:    Small corrections of code based on PSScriptAnalyzer 1.6.0 sugestions
##       Added:    Console window title will be set back after a demo end
##       Added:    Own custom prompt can be used under demo
##       Added:    SkipAddTheEndLine switch to don't display 'The end' line
##       Added:    SkipAddDemoTime switch to don't display start/end demo and demo duration in
##                 a PowerShell console window
##       Added:    backgroundColor parameter added - now PowerShell console don't need to be black
## 3.3.3 Fixed:    Script no longer says "unrecognized key" when you hit shift or ctrl, etc.
##       Fixed:    Blank lines in script were showing as errors (now printed like comments)
## 3.3.2 Fixed:    Changed the "x" to match the "a" in the help text
## 3.3.1 Fixed:    Added a missing bracket in the script
## 3.3 - Added:    Added a "Clear Screen" option
##     - Added:    Added a "Rewind" function (which I'm not using much)
## 3.2 - Fixed:    Put back the trap { continue; }
## 3.1 - Fixed:    No Output when invoking Get-Member (and other cmdlets like it???)
## 3.0 - Fixed:    Commands which set a variable, like: $files = ls
##     - Fixed:    Default action doesn't continue
##     - Changed:  Use ReadKey instead of ReadLine
##     - Changed:  Modified the option prompts (sorry if you had them memorized)
##     - Changed:  Various time and duration strings have better formatting
##     - Enhance:  Colors are settable: prompt, command, comment
##     - Added:    NoPauseAfterExecute switch removes the extra pause
##                 If you set this, the next command will be displayed immediately
##     - Added:    Auto Execute mode (FullAuto switch) runs the rest of the script
##                 at an automatic speed set by the AutoSpeed parameter (or manually)
##     - Added:    Automatically append an empty line to the end of the demo script
##                 so you have a chance to "go back" after the last line of you demo
##################################################################################################
## Improving ideas
## - convert script to function
## - add padding zero(s) to command number
## - remove char '?' from the prompt in the FullAuto mode
##################################################################################################

param (
    $file = ".\demo.txt",
    [int]$command = 0,
    [System.ConsoleColor]$promptColor = "Yellow",
    [System.ConsoleColor]$commandColor = "White",
    [System.ConsoleColor]$commentColor = "Green",
    [System.ConsoleColor]$backgroundColor = "black",
	[int]$StartDelay,
	[switch]$SkipInstructions,
    [switch]$FullAuto,
    [int]$AutoSpeed = 3,
	[int]$DelayAfterComment = 1,
	[switch]$NoPauseAfterExecute,
    [switch]$UseMyPrompt, #To customize change definition in the function Prompt (below)
    [switch]$SkipAddTheEndLine,
    [switch]$SkipAddDemoTime
)

$RawUI = $Host.UI.RawUI
$hostWidth = $RawUI.BufferSize.Width
$hostTitle = $RawUI.WindowTitle

If ($UseMyPrompt.ispresent) {
    $OryginalPrompt = Get-Content Function:\prompt
    Prompt
}

# More about constructing prompts here: https://technet.microsoft.com/en-us/library/hh847739.aspx
Function prompt { "[PS] >" }

# A function for reading in a character
function Read-Char() {
    $_OldColor = $RawUI.ForeGroundColor
    $RawUI.ForeGroundColor = "Red"
    $inChar = $RawUI.ReadKey("IncludeKeyUp")
    # loop until they press a character, so Shift or Ctrl, etc don't terminate us
    while ($inChar.Character -eq 0) {
        $inChar = $RawUI.ReadKey("IncludeKeyUp")
    }
    $RawUI.ForeGroundColor = $_OldColor
    return $inChar.Character
}



function Rewind($lines, $index, $steps = 1) {
    $started = $index;
    $index -= $steps;
    while (($index -ge 0) -and ($lines[$index].Trim(" `t").StartsWith("#"))) {
        $index--
    }
    if ($index -lt 0) { $index = $started }
    return $index
}

$file = Resolve-Path $file
while (-not (Test-Path $file)) {
    $file = Read-Host "Please enter the path of your demo script (Crtl+C to cancel)"
    $file = Resolve-Path $file
}

Clear-Host

If ( $StarDelay -gt 0 ) {
	Start-Sleep -seconds $StartDelay
}

$_lines = Get-Content $file

If (-not $SkipAddTheEndLine.IsPresent) {
    # Append an extra (do nothing) line on the end so we can still go back after the last line.
    $_lines += "Write-Host 'The End'"
}

$_starttime = [DateTime]::now

#Overwrite original prompt (?)
Write-Host -nonew -back $backgroundColor -fore $promptColor $(" " * $hostWidth)

If (-not $SkipAddDemoTime.IsPresent) {
    Write-Host -nonew -back $backgroundColor -fore $promptColor @"
<Demo Started :: $(split-path $file -leaf)>$(' ' * ($hostWidth - (18 + $(split-path $file -leaf).Length)))
"@
}

If ( -not ($SkipInstructions.IsPresent -or $FullAuto.IsPresent) ) {
	Write-Host -nonew -back $backgroundColor -fore $promptColor "Press"
	Write-Host -nonew -back $backgroundColor -fore Red " ? "
	Write-Host -nonew -back $backgroundColor -fore $promptColor "for help.$(' ' * ($hostWidth - 17))"
	Write-Host -nonew -back $backgroundColor -fore $promptColor $(" " * $hostWidth)
}

# We use a FOR and an INDEX ($_i) instead of a FOREACH because
# it is possible to start at a different location and/or jump
# around in the order.
for ($_i = $Command; $_i -lt $_lines.count; $_i++) {
    # Put the current command in the Window Title along with the demo duration
    $Dur = [DateTime]::Now - $_StartTime
    $RawUI.WindowTitle = "$(if ($dur.Hours -gt 0) { '{0}h ' })$(if ($dur.Minutes -gt 0) { '{1}m ' }){2}s   {3}" -f
    $dur.Hours, $dur.Minutes, $dur.Seconds, $($_Lines[$_i])

    # Echo out the commmand to the console with a prompt as though it were real
    Write-Host -nonew -fore $promptColor "[$_i]$([char]0x2265) "

	# Comments line from file can be write to the console using $commentColor as a text (not executed)
    if ($_lines[$_i].Trim(" ").StartsWith("#") -or $_lines[$_i].Trim(" ").Length -le 0) {
        Write-Host -fore $commentColor "$($_Lines[$_i])  "
		Start-Sleep -Seconds $DelayAfterComment
        continue
    }
    else {
        Write-Host -nonew -fore $commandColor "$($_Lines[$_i])  "
    }

    if ($FullAuto.IsPresent) { $FullAutoInt = $true; Start-Sleep $autoSpeed; $ch = [char]13 }
    else { $ch = Read-Char }

    switch ($ch) {
        "?" {
            Write-Host -Fore $promptColor @"

Running demo: $file
(n) Next       (p) Previous
(q) Quit       (s) Suspend
(t) Timecheck  (v) View $(split-path $file -leaf)
(g) Go to line by number
(f) Find lines by string
(a) Auto Execute mode
(c) Clear Screen
"@
            $_i-- # back a line, we're gonna step forward when we loop
        }
        "n" {
            # Next (do nothing)
            Write-Host -Fore $promptColor "<Skipping Line>"
        }
        "p" {
            # Previous
            Write-Host -Fore $promptColor "<Back one Line>"
            while ($_lines[--$_i].Trim(" ").StartsWith("#")) { }
            $_i-- # back a line, we're gonna step forward when we loop
        }
        "a" {
            # EXECUTE (Go Faster)
            $AutoSpeed = [int](Read-Host "Pause (seconds)")
            $FullAutoInt = $true;
            Write-Host -Fore $promptColor "<eXecute Remaining Lines>"
            $_i-- # Repeat this line, and then just blow through the rest
        }
        "q" {
            # Quit
            Write-Host -Fore $promptColor "<Quiting demo>"
            $_i = $_lines.count;
            #Restore oryginal PowerShell host title
            $RawUI.WindowTitle = $hostTitle
            #Restore oryginal PowerShell prompt
            If ($UseMyPrompt.IsPresent) {
				Invoke-Expression
            }
            break;
        }
        "v" {
            # View Source
            $lines[0..($_i - 1)] | Write-Host -Fore Yellow
            $lines[$_i] | Write-Host -Fore Green
            $lines[($_i + 1)..$lines.Count] | Write-Host -Fore Yellow
            $_i-- # back a line, we're gonna step forward when we loop
        }
        "t" {
            # Time Check
            $dur = [DateTime]::Now - $_StartTime
            Write-Host -Fore $promptColor $(
                "{3} -- $(if ($dur.Hours -gt 0) { '{0}h ' })$(if ($dur.Minutes -gt 0) { '{1}m ' }){2}s" -f
                $dur.Hours, $dur.Minutes, $dur.Seconds, ([DateTime]::Now.ToShortTimeString()))
            $_i-- # back a line, we're gonna step forward when we loop
        }
        "s" {
            # Suspend (Enter Nested Prompt)
            Write-Host -Fore $promptColor "<Suspending demo - type 'Exit' to resume>"
            $Host.EnterNestedPrompt()
            $_i-- # back a line, we're gonna step forward when we loop
        }
        "g" {
            # GoTo Line Number
            $i = [int](Read-Host "line number")
            if ($i -le $_lines.Count) {
                if ($i -gt 0) {
                    # extra line back because we're gonna step forward when we loop
                    $_i = Rewind $_lines $_i (($_i - $i) + 1)
                }
                else {
                    $_i = -1 # Start negative, because we step forward when we loop
                }
            }
        }
        "f" {
            # Find by pattern
            $match = $_lines | Select-String (Read-Host "search string")
            if ([String]::IsNullOrEmpty($match)) {
                Write-Host -Fore Red "Can't find a matching line"
            }
            else {
                $match | ForEach-Object -Process { Write-Host -Fore $promptColor $("[{0,2}] {1}" -f ($_.LineNumber - 1), $_.Line) }
                if ($match.Count -lt 1) {
                    $_i = $match.lineNumber - 2 # back a line, we're gonna step forward when we loop
                }
                else {
                    $_i-- # back a line, we're gonna step forward when we loop
                }
            }
        }
        "c" {
            Clear-Host
            $_i-- # back a line, we're gonna step forward when we loop
        }
        "$([char]13)" {
            # on enter
            Write-Host
            trap [System.Exception] { Write-Error $_; continue; }
            Invoke-Expression ($_lines[$_i]) | out-default
            if (-not $NoPauseAfterExecute -and -not $FullAutoInt) {
                $null = $RawUI.ReadKey("NoEcho,IncludeKeyUp") # Pause after output for no apparent reason... ;)
            }
        }
        default {
            Write-Host -Fore Green "`nKey not recognized.  Press ? for help, or ENTER to execute the command."
            $_i-- # back a line, we're gonna step forward when we loop
        }
    }
}
$dur = [DateTime]::Now - $_StartTime
If (-not $SkipAddDemoTime.IsPresent) {
    Write-Host -Fore $promptColor $(
        "<Demo Complete -- $(if ($dur.Hours -gt 0) { '{0}h ' })$(if ($dur.Minutes -gt 0) { '{1}m ' }){2}s>" -f
        $dur.Hours, $dur.Minutes, $dur.Seconds, [DateTime]::Now.ToLongTimeString())
    Write-Host -Fore $promptColor $([DateTime]::now)
}
Write-Host
#Restore oryginal PowerShell host title
$RawUI.WindowTitle = $hostTitle
#Restore oryginal PowerShell prompt
If ($UseMyPrompt.IsPresent) {
    Invoke-Expression -Command "Function Prompt { $OryginalPrompt }" -ErrorAction SilentlyContinue
}