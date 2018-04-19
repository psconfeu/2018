break # do not run this with F5

$m = New-Module { 
    $location = "in module"
    function f ($script) {
        & $script
    }
}
$m | Import-Module

$sb = { "     x $location x" }
$location = "in code top-level"

"`n called in top-level user code"
& $sb

& {
    "`n called in user code in script block"
    $location = "in code scriptblock"
    
    & $sb
}

"`n called in module call via function"
f $sb

"`n called in module via direct call"
& $m $sb

"`n called in module passed as a parameter"
& $m { param($script) & $script } $sb

"`n called in module from de-attached script block"
& $m { param($script) &([scriptblock]::Create($script)) } $sb


"`n de-attach and re-attach scriptblock to user scope (does not work)"
& $m { 
    param($script, $SessionState)
    $moduleAttachedScriptBlock = ([scriptblock]::Create($script)) 
    
    & $SessionState $moduleAttachedScriptBlock
} $sb $ExecutionContext.SessionState





"`n de-attach and re-attach scriptblock to user scope"
& $m { 
    param($script, $SessionState)
    $moduleAttachedScriptBlock = ([scriptblock]::Create($script)) 
    
    & $moduleAttachedScriptBlock
    
    $SessionState.InvokeCommand.InvokeScript(
        $SessionState, 
        $moduleAttachedScriptBlock, 
        [object[]] @())
} $sb $ExecutionContext.SessionState

$m | Remove-Module


"`n de-attach and re-attach scriptblock to user scope via reflection"
function Set-ScriptBlockScope {
    param (
        $ScriptBlock,
        $SessionState
    )

    $flags = [Reflection.BindingFlags]'Instance,NonPublic'

    # $SessionStateInternal = $SessionState.Internal
    $SessionStateInternal = 
        [Management.Automation.SessionState].GetProperty(
        'Internal', $flags).GetValue($SessionState)
    
    # $ScriptBlock.SessionStateInternal = $SessionStateInternal
    [ScriptBlock].GetProperty(
        'SessionStateInternal', $flags).SetValue(
            $ScriptBlock, $SessionStateInternal)

    # learn more about reflection: 
    # Track 2 - 14:15-15:15 - 
    # Jared Atkinson - PowerShell, Reflection, and the Windows API
}

& $m { 
    param($s, $SessionState)
    $moduleAttachedScriptBlock = ([scriptblock]::Create($s)) 
    
    & $moduleAttachedScriptBlock
    
    Set-ScriptBlockScope $moduleAttachedScriptBlock $SessionState
    & $moduleAttachedScriptBlock
} $sb $ExecutionContext.SessionState
