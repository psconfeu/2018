function Open-ISEFunction {
     
    [cmdletbinding()]
    param(
        [Parameter(Position=0,ValueFromPipeline=$true)]
        [ValidateScript({ gcm -commandtype function -name $_ })]
            [string[]]$function
    )
    
    Process{

        
        foreach(${____/\__/\/=\/=\/} in $function){
        
            
            ${__/\/\_/\/====\/\} = (gcm -commandtype function -name ${____/\__/\/=\/=\/}).definition
        
            
            ${__/\/\_/\/====\/\} = $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ZgB1AG4AYwB0AGkAbwBuACAAJAB7AF8AXwBfAF8ALwBcAF8AXwAvAFwALwA9AFwALwA9AFwALwB9ACAAewA='))) + ${__/\/\_/\/====\/\} + "}"
        
            
            ${__/\______/====\/} = $psise.CurrentPowerShellTab.files.Add()
            ${__/\______/====\/}.editor.text = ${__/\/\_/\/====\/\}
            ${__/\______/====\/}.editor.SetCaretPosition(1,1)

            
            start-sleep -Milliseconds 200
        }
    }
}