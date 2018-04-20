
[cmdletbinding()]
Param (
    [parameter()]
    [string]${__/\/==\/\/=\/\_/} 
)
If ($PSBoundParameters[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RQBuAGEAYgBsAGUATABvAGcAZwBpAG4AZwA=')))]) {
    ${Global:__/\/==\/\/=\/\_/} = ${__/\/==\/\/=\/\_/}
}
${Global:___/\/=\_/======\} = Get-Content Function:Prompt
Function Global:Prompt {[char]8}
Clear-Host
${Global:/===\/=\_/=\/=\/\} = [HashTable]::Synchronized(@{})
${Global:__/\___/\____/\_/} = [hashtable]::Synchronized(@{})
${Global:_/\/\__/\/\__/=\/} =  [System.Collections.Queue]::Synchronized((New-Object System.collections.queue))
${Global:/====\__/\__/\__/} = [HashTable]::Synchronized(@{})
${Global:__/=\/\/\___/\/\_} =  [System.Collections.Queue]::Synchronized((New-Object System.collections.queue))
${Global:____/=\/\/=\__/\/} = [HashTable]::Synchronized(@{})
${/==\/\/\/\/==\_/\} = New-Object Timers.Timer
${/==\/\/\/\/==\_/\}.Enabled = $true
${/==\/\/\/\/==\_/\}.Interval = 1000 
${___/=\__/=\_/\_/\} = Register-ObjectEvent -SourceIdentifier MonitorClientConnection -InputObject ${/==\/\/\/\/==\_/\} -EventName Elapsed -Action { 
    While (${__/=\/\/\___/\/\_}.count -ne 0) {    
        ${/=\/==\/=\__/===\} = ${__/=\/\/\___/\/\_}.Dequeue()
        ${__/\___/\____/\_/}.${/=\/==\/=\__/===\}.PowerShell.EndInvoke(${__/\___/\____/\_/}.${/=\/==\/=\__/===\}.Job)
        ${__/\___/\____/\_/}.${/=\/==\/=\__/===\}.PowerShell.Runspace.Close()
        ${__/\___/\____/\_/}.${/=\/==\/=\__/===\}.PowerShell.Dispose()          
        ${__/\___/\____/\_/}.Remove(${/=\/==\/=\__/===\})                          
        ${_/\/\__/\/\__/=\/}.Enqueue($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('fgBEAHsAMAB9AA=='))) -f ${/=\/==\/=\__/===\})   
    }   
}
${___/=\__/=\_/\_/\} = Register-ObjectEvent -SourceIdentifier NewConnectionTimer -InputObject ${/==\/\/\/\/==\_/\} -EventName Elapsed -Action {
    If (${/====\__/\__/\__/}.count -lt ${/===\/=\_/=\/=\/\}.count) {
        ${/===\/=\_/=\/=\/\}.GetEnumerator() | ForEach {
            If (-Not (${/====\__/\__/\__/}.Contains($_.Name))) {
                ${/====\__/\__/\__/}[$_.Name]=$_.Value               
                ${/=\/==\/=\__/===\} = $_.Name
                ${_/\/\__/\/\__/=\/}.Enqueue(($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('fgBDAHsAMAB9AA=='))) -f ${/=\/==\/=\__/===\}))
                ${_/=\/=\___/\__/==} = [RunSpaceFactory]::CreateRunspace()
                ${_/=\/=\___/\__/==}.Open()
                ${_/=\/=\___/\__/==}.SessionStateProxy.setVariable($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cwBoAGEAcgBlAGQAZABhAHQAYQA='))), ${/===\/=\_/=\/=\/\})
                ${_/=\/=\___/\__/==}.SessionStateProxy.setVariable($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwBsAGkAZQBuAHQASABhAHMAaAA='))), ${/====\__/\__/\__/})
                ${_/=\/=\___/\__/==}.SessionStateProxy.setVariable($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VQBzAGUAcgA='))), ${/=\/==\/=\__/===\})
                ${_/=\/=\___/\__/==}.SessionStateProxy.setVariable($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBlAHMAcwBhAGcAZQBRAHUAZQB1AGUA'))), ${_/\/\__/\/\__/=\/})               
                ${_/=\/=\___/\__/==}.SessionStateProxy.setVariable($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UgBlAG0AbwB2AGUAUQB1AGUAdQBlAA=='))), ${__/=\/\/\___/\/\_})
                ${/=\_/=\______/=\/} = [PowerShell]::Create()
                ${/=\_/=\______/=\/}.Runspace = ${_/=\/=\___/\__/==}   
                ${____/=\/=\_/==\/=} = {
                    ${___/=\/=\_/\/==\/} = ${/====\__/\__/\__/}.${/=\/==\/=\__/===\}
                    ${_/=\/\/\/\/\/=\_/} = ${___/=\/=\_/\/==\/}.GetStream()
                    While ($True) {                        
                        [byte[]]${/===\_/=====\_/=\} = New-Object byte[] 10025
                        ${__/=\___/\____/==} = ${___/=\/=\_/\/==\/}.ReceiveBufferSize
                        ${/=\___/\/==\_____} = ${_/=\/\/\/\/\/=\_/}.Read(${/===\_/=====\_/=\}, 0, ${__/=\___/\____/==})
                        If (${/=\___/\/==\_____} -gt 0) {
                            ${_/\/\__/\/\__/=\/}.Enqueue([System.Text.Encoding]::ASCII.GetString(${/===\_/=====\_/=\}[0..(${/=\___/\/==\_____} - 1)]))
                        } Else {
                            ${/===\/=\_/=\/=\/\}.Remove(${/=\/==\/=\__/===\})
                            ${/====\__/\__/\__/}.Remove(${/=\/==\/=\__/===\})                   
                            ${__/=\/\/\___/\/\_}.Enqueue(${/=\/==\/=\__/===\})
                            Break
                        }
                    }
                }
                ${__/\/\_/\_/==\___} = "" | Select Job, PowerShell
                ${__/\/\_/\_/==\___}.PowerShell = ${/=\_/=\______/=\/}
                ${__/\/\_/\_/==\___}.job = ${/=\_/=\______/=\/}.AddScript(${____/=\/=\_/==\/=}).BeginInvoke()
                ${__/\___/\____/\_/}.${/=\/==\/=\__/===\} = ${__/\/\_/\_/==\___}                                             
            }
        }
    }
}
${/=\_/\____/=\__/=} = Register-ObjectEvent -SourceIdentifier IncomingMessageTimer -InputObject ${/==\/\/\/\/==\_/\} -EventName Elapsed -Action {
    While (${_/\/\__/\/\__/=\/}.Count -ne 0) {
        ${_/\___/\/=\/\/==\} = ${_/\/\__/\/\__/=\/}.dequeue() 
        Switch (${_/\___/\/=\/\/==\}) {
            {$_.Startswith("~M")} {
                ${/=\/=\/==\/\___/\} = ($_).SubString(2)
                ${__/\_/\/=\_/=\__/} = ${/=\/=\/==\/\___/\} -split ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ewAwAH0A'))) -f "~~")
                Write-Host ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ewAwAH0AIAA+AD4AIAB7ADEAfQA6ACAAewAyAH0A'))) -f (Get-Date).ToString(),${__/\_/\/=\_/=\__/}[0],${__/\_/\/=\_/=\__/}[1])
                If (${__/\/==\/\/=\/\_/}) {
                    Out-File -Inputobject ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ewAwAH0AIAA+AD4AIAB7ADEAfQA6ACAAewAyAH0A'))) -f (Get-Date).ToString(),${__/\_/\/=\_/=\__/}[0],${__/\_/\/=\_/=\__/}[1]) -FilePath ${__/\/==\/\/=\/\_/} -Append
                }
            }
            {$_.Startswith("~D")} {
                Write-Host ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ewAwAH0AIAA+AD4AIAB7ADEAfQAgAGgAYQBzACAAZABpAHMAYwBvAG4AbgBlAGMAdABlAGQAIABmAHIAbwBtACAAdABoAGUAIABzAGUAcgB2AGUAcgA='))) -f (Get-Date).ToString(),$_.SubString(2))
                If (${__/\/==\/\/=\/\_/}) {
                    Out-File -Inputobject ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ewAwAH0AIAA+AD4AIAB7ADEAfQAgAGgAYQBzACAAZABpAHMAYwBvAG4AbgBlAGMAdABlAGQAIABmAHIAbwBtACAAdABoAGUAIABzAGUAcgB2AGUAcgA='))) -f (Get-Date).ToString(),$_.SubString(2)) -FilePath ${__/\/==\/\/=\/\_/} -Append
                }                
            }
            {$_.StartsWith("~C")} {
                Write-Host ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ewAwAH0AIAA+AD4AIAB7ADEAfQAgAGgAYQBzACAAYwBvAG4AbgBlAGMAdABlAGQAIAB0AG8AIAB0AGgAZQAgAHMAZQByAHYAZQByAA=='))) -f (Get-Date).ToString(),$_.SubString(2))
                If (${__/\/==\/\/=\/\_/}) {
                    Out-File -Inputobject ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ewAwAH0AIAA+AD4AIAB7ADEAfQAgAGgAYQBzACAAYwBvAG4AbgBlAGMAdABlAGQAIAB0AG8AIAB0AGgAZQAgAHMAZQByAHYAZQByAA=='))) -f (Get-Date).ToString(),$_.SubString(2)) -FilePath ${__/\/==\/\/=\/\_/} -Append
                }                              
            }
            {$_.StartsWith("~S")} {
                Write-Host ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ewAwAH0AIAA+AD4AIABTAGUAcgB2AGUAcgAgAGgAYQBzACAAcwBoAHUAdABkAG8AdwBuAC4A'))) -f (Get-Date).ToString())
                If (${__/\/==\/\/=\/\_/}) {
                    Out-File -Inputobject ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ewAwAH0AIAA+AD4AIABTAGUAcgB2AGUAcgAgAGgAYQBzACAAcwBoAHUAdABkAG8AdwBuAC4A'))) -f (Get-Date).ToString()) -FilePath ${__/\/==\/\/=\/\_/} -Append
                }                              
            }            
            Default {
                Write-Host ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ewAwAH0AIAA+AD4AIAB7ADEAfQA='))) -f (Get-Date).ToString(),$_)
                If (${__/\/==\/\/=\/\_/}) {
                    Out-File -Inputobject ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ewAwAH0AIAA+AD4AIAB7ADEAfQA='))) -f (Get-Date).ToString(),$_) -FilePath ${__/\/==\/\/=\/\_/} -Append
                }                  
            }
        }        
        ${/====\__/\__/\__/}.GetEnumerator() | ForEach {
            ${/=\/\_/\_/==\____} = ${/====\__/\__/\__/}[$_.Name]
            ${/==\___/=\/\/==\/} = ${/=\/\_/\_/==\____}.GetStream()
            ${__/=\/=\/\/\/==\/} = ${_/\___/\/=\/\/==\}
            ${__/\/===\/===\_/=} = ([text.encoding]::ASCII).GetBytes(${__/=\/=\/\/\/==\/})
            ${/==\___/=\/\/==\/}.Write(${__/\/===\/===\_/=},0,${__/\/===\/===\_/=}.Length)
            ${/==\___/=\/\/==\/}.Flush()            
        }
    }
}
${/==\/\/\/\/==\_/\}.Start()
${Global:_/=\/=\___/\__/==} = [RunSpaceFactory]::CreateRunspace()
${_/=\/=\___/\__/==}.Open()
${_/=\/=\___/\__/==}.SessionStateProxy.setVariable($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cwBoAGEAcgBlAGQARABhAHQAYQA='))), ${/===\/=\_/=\/=\/\})
${_/=\/=\___/\__/==}.SessionStateProxy.setVariable($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TABpAHMAdABlAG4AZQByAA=='))), ${____/=\/\/=\__/\/})
${_/=\/=\___/\__/==}.SessionStateProxy.setVariable($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RQBuAGEAYgBsAGUATABvAGcAZwBpAG4AZwA='))), ${__/\/==\/\/=\/\_/})
${Global:/=\_/=\______/=\/} = [PowerShell]::Create()
${/=\_/=\______/=\/}.Runspace = ${_/=\/=\___/\__/==}
${____/=\/=\_/==\/=} = {
 ${____/=\/\/=\__/\/}[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bABpAHMAdABlAG4AZQByAA==')))] = [System.Net.Sockets.TcpListener]15600
 ${____/=\/\/=\__/\/}[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bABpAHMAdABlAG4AZQByAA==')))].Start()
 [console]::WriteLine($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ewAwAH0AIAA+AD4AIABTAGUAcgB2AGUAcgAgAFMAdABhAHIAdABlAGQA'))) -f (Get-Date).ToString())
 If (${__/\/==\/\/=\/\_/}) {
    Write-Verbose ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TABvAGcAZwBpAG4AZwAgAHQAbwAgAGYAaQBsAGUA'))))
    Out-File -Inputobject ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ewAwAH0AIAA+AD4AIABTAGUAcgB2AGUAcgAgAFMAdABhAHIAdABlAGQA'))) -f (Get-Date).ToString()) -FilePath ${__/\/==\/\/=\/\_/}
} 
 while($true) {
    [byte[]]${__/\/\/\____/=\_/} = New-Object byte[] 1024
    ${___/=\/=\_/\/==\/} = ${____/=\/\/=\__/\/}[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('bABpAHMAdABlAG4AZQByAA==')))].AcceptTcpClient()
    If (${___/=\/=\_/\/==\/} -ne $Null) {
        ${__/\/\_/\_/\__/=\} = ${___/=\/=\_/\/==\/}.GetStream()
        Do {
            Write-Verbose ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QgB5AHQAZQBzACAATABlAGYAdAA6ACAAewAwAH0A'))) -f ${___/=\/=\_/\/==\/}.Available)
            ${/=\___/\/==\_____} = ${__/\/\_/\_/\__/=\}.Read(${__/\/\/\____/=\_/}, 0, ${__/\/\/\____/=\_/}.Length)
            ${__/=\/=\/\/\/==\/} += [text.Encoding]::Ascii.GetString(${__/\/\/\____/=\_/}[0..(${/=\___/\/==\_____}-1)])
        } While (${__/\/\_/\_/\__/=\}.DataAvailable)
        If (${/===\/=\_/=\/=\/\}.Count -lt 30) { 
            ${/===\/=\_/=\/=\/\}[${__/=\/=\/\/\/==\/}] = ${___/=\/=\_/\/==\/}           
            ${/=\______/\__/=\/} = ($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('fgBaAHsAMAB9AA=='))) -f (${/===\/=\_/=\/=\/\}.Keys -join "~~"))
            ${/==\___/=\/\/==\/} = ${___/=\/=\_/\/==\/}.GetStream()
            ${__/\/===\/===\_/=} = ([text.encoding]::ASCII).GetBytes(${/=\______/\__/=\/})
            ${/==\___/=\/\/==\/}.Write(${__/\/===\/===\_/=},0,${__/\/===\/===\_/=}.Length)
            ${/==\___/=\/\/==\/}.Flush()             
            ${__/=\/=\/\/\/==\/} = $Null
        } Else {
        }
    } Else {
        Break
    }
 }
}
${Global:_/=\_/=\____/\/\_} = ${/=\_/=\______/=\/}.AddScript(${____/=\/=\_/==\/=}).BeginInvoke()
Function Global:Stop-PoshChatServer {
    ${_/\/\__/\/\__/=\/}.enqueue("~S")   
    ${____/=\/\/=\__/\/}.listener.Server.Close()
    Remove-Variable MessageQueue
    ${/====\__/\__/\__/}.GetEnumerator() | ForEach {
        ${/===\/=\_/=\/=\/\}[$_.Name].client.close()
    }
    ${/=\_/=\______/=\/}.EndInvoke(${_/=\_/=\____/\/\_})    
    ${_/=\/=\___/\__/==}.close()
    ${/=\_/=\______/=\/}.Dispose()      
    Start-Sleep -Seconds 5   
    Get-EventSubscriber | Unregister-Event
    Get-Job | Remove-Job -force        
    Remove-Variable newPowerShell
    Remove-Variable newrunspace
    Remove-Variable handle    
    Set-Content -Path Function:Prompt -Value {${___/\/=\_/======\}}.invoke()    
}