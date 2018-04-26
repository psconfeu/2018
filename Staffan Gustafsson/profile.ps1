param(
    [string] $Title,
    [AllowNull()]
    [AllowEmptyString()]
    [string] $prompt,
    [string] $Presentation,
    [string] $ReadLineHistory
)

[string]$global:demohome = & {
    $c = $ReadLineHistory
    while ($c -notmatch "\\(Formatting|TypeSystem)$") {
        $c = Split-Path $c
    }
    $c
}
$root2018 = Split-Path $demoHome

. $root2018\colorizeCommand.ps1

$global:pssrc = Search-Everything -FolderInclude repos\PowerShell -Global -ChildFileName build.psm1
Set-Location $demohome
Set-PSReadLineOption -ShowToolTips

$windowTitle = "PSConfEU2018 - $Presentation - $Title"
$host.UI.RawUI.WindowTitle = $windowTitle

if (-not $prompt) {$prompt = $title}
$PromptText = "PSConfEU2018 - $Presentation - $prompt"

Set-PSReadLineOption -ExtraPromptLineCount 1
function prompt {
    if ($prompt) {
        $li = "($($global:loadindex+1))"
        "[$PromptText]`n${li}PS> "
    }
    else {
        "> "
    }
}

function show-commands {
    [Alias("c")]
    param()
    . $root2018\colorizeCommand.ps1

    . {
        for ($i = 1; $i -le $commands.length; $i++) {
            [pscustomobject] @{
                i = $i
                c = colorize $commands[$i - 1]
            }
        }
    }| Format-Table -HideTableHeaders -Wrap
}



function ParseCommands {
    param($file)
    $err = $tok = $null
    $ast = [Management.Automation.Language.Parser]::ParseFile($file, [ref]$tok, [ref]$err)
    $statements = $ast.EndBlock.Statements
    $comments = $tok.Where{$_.Kind -in 'Comment'}
    $ext = $statements.extent + $comments.extent
    $builder = [text.StringBuilder]::new(200)
    $prevLineEnd = 0
    foreach ($e in $ext | Sort-Object StartLinenumber) {
        if ($e.StartLinenumber -eq $prevLineEnd + 1) {
            if ($builder.Length -ne 0) {
                $builder.Append("`n") | Out-Null
            }
            $builder.Append($e.Text) | Out-Null
        }
        else {
            $builder.Replace("`r`n", "`n").ToString()
            $builder.Length = 0
            $builder.Append($e.Text) | Out-Null
        }
        $prevLineEnd = $e.EndLineNumber
    }
    $builder.Replace("`r`n", "`n").ToString()
}

function Reload {
    [Alias('r')]
    param()
    $global:Commands = ParseCommands $ReadLineHistory
    Set-Command 0
}

Reload
function AcceptAndLoadNext {
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::CancelLine()
    LoadNext
}

function LoadNext {
    $current = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$current, [ref]$cursor)
    if ($current) {
        return
    }
    if ($script:loadIndex -ge $commands.Length) {
        $script:loadIndex = $commands.Length - 1
    }
    $script:loadIndex++
    $next = $global:commands[$script:loadIndex]
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($next)
}

Set-PSReadLineKeyHandler -Chord Ctrl+. -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("Start-Demo")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

function Start-Demo {
    [CmdletBinding()]
    param(
        # A history file with a command on each line (or using ` as a line-continuation character)
        [Parameter()]
        [Alias("PSPath")]
        [string]$Path = $ReadLineHistory
    )
    [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()

    foreach ($command in (Get-Content $Path -Raw) -split '(?<!`)\r\n' -replace '`\r\n', "`r`n") {
        [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($command)
    }

    #Write-Host "Press Ctrl+Home to go to the start of the demo, and Ctrl+Enter to run each line" -Foreground Yellow

    Set-PSReadLineKeyHandler Ctrl+Home BeginningOfHistory
    Set-PSReadLineKeyHandler Ctrl+Enter -ScriptBlock { AcceptAndLoadNext }
    Set-PSReadLineKeyHandler DownArrow -ScriptBlock { LoadNext }
    Set-PSReadLineKeyHandler Shift+DownArrow NextHistory
}

ipmo  $root2018\joinitem.dll

Set-PSReadLineOption -PromptText '> '
Set-PSReadLineKeyHandler -Chord Ctrl+o -ScriptBlock {  Colors }