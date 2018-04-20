$executionContext.SessionState.InvokeCommand.PostCommandLookupAction = {
    param($CommandName, $CommandLookupEventArgs)

    # Only for interactive commands (and that doesn't include "prompt")
    # I should exclude out-default so we don't handle it on every pipeline, but ...
    if($CommandLookupEventArgs.CommandOrigin -eq "Runspace" -and $CommandName -ne "prompt" ) {
        ## Create a new script block that checks for the "-??" argument 
        ## And if -?? exists, calls Get-Help -Full instead
        ## Otherwise calls the expected command
        $CommandLookupEventArgs.CommandScriptBlock = {
            if($Args.Length -eq 1 -and $Args[0] -eq "-??") {
                Get-Help $CommandName -Full
            } else {
                & $CommandName @args
            }
        ## Wrap it in a closure because we need $CommandName
        }.GetNewClosure()
    }
}
