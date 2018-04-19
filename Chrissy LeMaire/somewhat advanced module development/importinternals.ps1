$moduleBase = Get-Module dbatools | exp ModuleBase
. "$($moduleBase)\internal\functions\Write-Message.ps1"
. "$($moduleBase)\internal\functions\Stop-Function.ps1"
. "$($moduleBase)\internal\functions\Test-FunctionInterrupt.ps1"
. "$($moduleBase)\internal\functions\Test-DbaDeprecation.ps1"
. "$($moduleBase)\internal\functions\Get-DbaRunspace.ps1"