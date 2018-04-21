$pscode = Search-Everything -Global -filter "PowerShell child:build.psm1 folder:"
[string] $root2018 = Resolve-Path "$PSScriptRoot\..\"
[string] $formatRoot = Join-Path $root2018 Formatting

Register-EditorCommand -Name "Format.OpenPowerPoint" -DisplayName 'Open Formatting Presentation' -SuppressOutput -ScriptBlock {
    Invoke-Item $PSScriptRoot\Formatting.pptx
}

Register-EditorCommand -Name "Format._OpenDefault" -DisplayName 'Out-Default' -SuppressOutput -ScriptBlock {  OpenOutConsole }
Register-EditorCommand -Name "Format._OpenDefaultFormatter" -DisplayName 'Built-in formats' -SuppressOutput -ScriptBlock { OpenDefaultFormat  }
Register-EditorCommand -Name "Format.10" -DisplayName '1: Super Heroes' -SuppressOutput -ScriptBlock {  SuperHeroPwsh }
Register-EditorCommand -Name "Format.20" -DisplayName '2: List' -SuppressOutput -ScriptBlock {  ListPwsh }
Register-EditorCommand -Name "Format.30" -DisplayName '3: Table' -SuppressOutput -ScriptBlock {  TablePwsh }
Register-EditorCommand -Name "Format.40" -DisplayName '4: Error' -SuppressOutput -ScriptBlock { ErrorPwsh }
Register-EditorCommand -Name "Format.50" -DisplayName '5: Custom' -SuppressOutput -ScriptBlock { CustomPwsh }
Register-EditorCommand -Name "Format.60" -DisplayName '6: Color' -SuppressOutput -ScriptBlock {  ColorPwsh }

function OpenOutConsole {
    Open-EditorFile $pscode\src\System.Management.Automation\FormatAndOutput\out-console\OutConsole.cs
}
function OpenDefaultFormat {
    Open-EditorFile $pscode\src\System.Management.Automation\FormatAndOutput\DefaultFormatters\DotNetTypes_format_ps1xml.cs
}

function prompt {
    "> "
}

function SuperHeroPwsh {
    Open-EditorFile $formatRoot\SuperHeroes.ps1
    Open-EditorFile $formatRoot\Heroes.json
    pwsh -ReadLineHistory $formatRoot\SuperHeroes.ps1 -Title "Super Heroes"
}
function ListPwsh {
    Open-EditorFile $$formatRoot\measure.format.ps1xml
    pwsh -ReadLineHistory $formatRoot\List.ps1 -Title "List formatting"
}
function TablePwsh {  pwsh -ReadLineHistory $formatRoot\Table.ps1 -Title "Table formatting"}
function CustomPwsh {  pwsh -ReadLineHistory $formatRoot\Custom.ps1 -Title "Custom formatting"}
function ErrorPwsh {
    $title = "Errors"
    $pr = "`e[91m$Title`e[39m"
    pwsh -ReadLineHistory $formatRoot\Errors.ps1  -Title "Errors" -Prompt $pr
}
function ColorPwsh {
    $pr = "`e[93mc`e[91mo`e[97ml`e[96mo`e[92mr`e[95ms`e[39m"
    pwsh -ReadLineHistory $formatRoot\Color.ps1 -Title "Colors" -prompt $pr
}
function pwsh {
    param(
        [Parameter(Mandatory)]
        [string] $ReadLineHistory
        ,
        [string] $Title = "Demo"
        ,
        [AllowNull()]
        [AllowEmptyString()]
        [string] $Prompt
    )

    & $cmd  -WindowStyle Maximized  -NoExit -File $root2018\profile.ps1  @PSBoundParameters -Presentation Formatting
}
