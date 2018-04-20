

Function Zip-File () {
  
  [CmdletBinding(DefaultParameterSetName="Add")]
  Param(
    [Parameter(Mandatory=$True, ParameterSetName="Add")]
    [Parameter(Mandatory=$True, ParameterSetName="Remove")]
    [Parameter(Mandatory=$True, ParameterSetName="Extract")]
    [Parameter(Mandatory=$True, ParameterSetName="List")]
    [String]$ZipFile,
    [Parameter(Mandatory=$True, ParameterSetName="Add")]
    [String[]]$Add,
    [Parameter(Mandatory=$False, ParameterSetName="Add")]
    [Switch]$Recurse,
    [Parameter(Mandatory=$True, ParameterSetName="Remove")]
    [String[]]$Remove,
    [Parameter(Mandatory=$True, ParameterSetName="Extract")]
    [String[]]$Extract,
    [Parameter(Mandatory=$False, ParameterSetName="Extract")]
    [String]$Destination=$PWD,
    [Parameter(Mandatory=$False, ParameterSetName="Add")]
    [Parameter(Mandatory=$False, ParameterSetName="Remove")]
    [Parameter(Mandatory=$False, ParameterSetName="Extract")]
    [Switch]$Folders,
    [Parameter(Mandatory=$True, ParameterSetName="List")]
    [Switch]$List
  )
  DynamicParam {
    if ($ZipFile -match ".*Zip\\.*")  {
      ${_/\_/\/\_/\_/\___} = New-Object -TypeName  System.Management.Automation.ParameterAttribute
      ${_/\_/\/\_/\_/\___}.ParameterSetName = "List"
      ${_/\_/\/\_/\_/\___}.Mandatory = $True
      ${/=\_/\/\/===\/==\} = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
      ${/=\_/\/\/===\/==\}.Add(${_/\_/\/\_/\_/\___})
      ${__/\__/===\_/\/=\} = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter("Path", [String], ${/=\_/\/\/===\/==\})
      ${/=\_/\/==\/==\_/=} = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
      ${/=\_/\/==\/==\_/=}.Add("Path", ${__/\__/===\_/\/=\})
      return ${/=\_/\/==\/==\_/=}
    }
  }
  Begin {
    ${_/=\____/=\/\_/\_} = New-Object -ComObject Shell.Application
    if (![System.IO.File]::Exists($ZipFile) -and ($PSCmdlet.ParameterSetName -eq "Add")) {
      Try {
        [System.IO.File]::WriteAllText($ZipFile, $("PK" + [Char]5 + [Char]6 + $("$([Char]0)" * 18)))
      }
      Catch {
      }
    }
    ${__/=\/=\_/=====\_} = ${_/=\____/=\/\_/\_}.NameSpace($ZipFile)
    if ($PSCmdlet.ParameterSetName -eq "Add") {
      ${_/==\/\__/==\/\/\} = "$([System.IO.Path]::GetTempPath())$([System.IO.Path]::GetRandomFileName())"
      if (![System.IO.Directory]::Exists(${_/==\/\__/==\/\/\})) {
        [Void][System.IO.Directory]::CreateDirectory(${_/==\/\__/==\/\/\})
      }
    }
  }
  Process {
    Switch ($PSCmdlet.ParameterSetName) {
      "Add" {
        Try {
          if ($Folders) {
            ForEach (${_/\____/\_/\/\_/\} in $Add) {
              ${__/==\/\_/\/\/\/\} = [System.IO.Path]::GetDirectoryName(${_/\____/\_/\/\_/\})
              ${/===\/=\_/=\__/\/} = [System.IO.Path]::GetFileName(${_/\____/\_/\/\_/\})
              ${_/=\/==\/\/==\__/} = [System.IO.Directory]::GetDirectories(${__/==\/\_/\/\/\/\}, ${/===\/=\_/=\__/\/})
              ${_/\/\/=\/\_____/=} = ${__/=\/=\_/=====\_}.Items().Count
              ForEach (${_/\_/==\/\/\_/\__} in ${_/=\/==\/\/==\__/}) {
                ${___/\_/\_/==\_/\/} = ${__/=\/=\_/=====\_}.ParseName([System.IO.Path]::GetFileName(${_/\_/==\/\/\_/\__}))
                if ([String]::IsNullOrEmpty(${___/\_/\_/==\_/\/})) {
                  if (!$Recurse) {
                    Write-Host $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QQBkAGQAaQBuAGcAIABGAG8AbABkAGUAcgA6ACAAJAB7AF8ALwBcAF8ALwA9AD0AXAAvAFwALwBcAF8ALwBcAF8AXwB9AA==')))
                  }
                  ${__/=\/=\_/=====\_}.CopyHere(${_/\_/==\/\/\_/\__}, 0x14)
                  Do {
                    [System.Threading.Thread]::Sleep(100)
                  } While (${__/=\/=\_/=====\_}.Items().Count -eq ${_/\/\/=\/\_____/=})
                } else {
                  if (!$Recurse) {
                    Write-Host $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RgBvAGwAZABlAHIAIABFAHgAaQBzAHQAcwAgAGkAbgAgAEEAcgBjAGgAaQB2AGUAOgAgACQAewBfAC8AXABfAC8APQA9AFwALwBcAC8AXABfAC8AXABfAF8AfQA=')))
                  }
                }
              }
            }
          } else {
            ForEach (${_/\____/\_/\/\_/\} in $Add) {
              ${__/==\/\_/\/\/\/\} = [System.IO.Path]::GetDirectoryName(${_/\____/\_/\/\_/\})
              ${/===\/=\_/=\__/\/} = [System.IO.Path]::GetFileName(${_/\____/\_/\/\_/\})
              ${_/\_/==\/\/\__/\_} = [System.IO.Directory]::GetFiles(${__/==\/\_/\/\/\/\}, ${/===\/=\_/=\__/\/})
              ${_/\/\/=\/\_____/=} = ${__/=\/=\_/=====\_}.Items().Count
              ForEach (${_/\____/\_/\/\_/\} in ${_/\_/==\/\/\__/\_}) {
                ${___/\_/\_/==\_/\/} = ${__/=\/=\_/=====\_}.ParseName([System.IO.Path]::GetFileName(${_/\____/\_/\/\_/\}))
                if ([String]::IsNullOrEmpty(${___/\_/\_/==\_/\/})) {
                  Write-Host $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QQBkAGQAaQBuAGcAIABGAGkAbABlADoAIAAkAHsAXwAvAFwAXwBfAF8AXwAvAFwAXwAvAFwALwBcAF8ALwBcAH0A')))
                  ${__/=\/=\_/=====\_}.CopyHere(${_/\____/\_/\/\_/\}, 0x14)
                  Do {
                    [System.Threading.Thread]::Sleep(100)
                  } While (${__/=\/=\_/=====\_}.Items().Count -eq ${_/\/\/=\/\_____/=})
                } else {
                  Write-Host $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RgBpAGwAZQAgAEUAeABpAHMAdABzACAAaQBuACAAQQByAGMAaABpAHYAZQA6ACAAJAB7AF8ALwBcAF8AXwBfAF8ALwBcAF8ALwBcAC8AXABfAC8AXAB9AA==')))
                }
              }
              if ($Recurse) {
                ${_/=\/==\/\/==\__/} = [System.IO.Directory]::GetDirectories(${__/==\/\_/\/\/\/\})
                ForEach (${_/\_/==\/\/\_/\__} in ${_/=\/==\/\/==\__/}) {
                  ${__/\/\/=\/==\___/} = [System.IO.Path]::GetFileName(${_/\_/==\/\/\_/\__})
                  if (!${__/=\/=\_/=====\_}.ParseName(${__/\/\/=\/==\___/})) {
                    [Void][System.IO.Directory]::CreateDirectory($ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('JAB7AF8ALwA9AD0AXAAvAFwAXwBfAC8APQA9AFwALwBcAC8AXAB9AFwAJAB7AF8AXwAvAFwALwBcAC8APQBcAC8APQA9AFwAXwBfAF8ALwB9AA=='))))
                    [System.IO.File]::WriteAllText($ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('JAB7AF8ALwA9AD0AXAAvAFwAXwBfAC8APQA9AFwALwBcAC8AXAB9AFwAJAB7AF8AXwAvAFwALwBcAC8APQBcAC8APQA9AFwAXwBfAF8ALwB9AFwALgBEAGkAcgA='))), "")
                    Zip-File -ZipFile $ZipFile -Add $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('JAB7AF8ALwA9AD0AXAAvAFwAXwBfAC8APQA9AFwALwBcAC8AXAB9AFwAJAB7AF8AXwAvAFwALwBcAC8APQBcAC8APQA9AFwAXwBfAF8ALwB9AA=='))) -Folders -Recurse
                  }
                  ${/=\/===\/\/\/\_/=} = @()
                  ForEach (${__/\_/=\/\_/==\/=} in $Add) {
                    ${/=\/===\/\/\/\_/=} += "$([System.IO.Path]::GetDirectoryName(${__/\_/=\/\_/==\/=}))\${__/\/\/=\/==\___/}\$([System.IO.Path]::GetFileName(${__/\_/=\/\_/==\/=}))"
                  }
                  Zip-File -ZipFile $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('JABaAGkAcABGAGkAbABlAFwAJAB7AF8AXwAvAFwALwBcAC8APQBcAC8APQA9AFwAXwBfAF8ALwB9AA=='))) -Add ${/=\/===\/\/\/\_/=} -Recurse:$Recurse
                }
              }
            }
          }
        }
        Catch {
          Throw "Error Adding Files to Zip Archive"
        }
        Break
      }
      "Remove" {
        Try {
          ForEach (${_/\____/\_/\/\_/\} in $Remove) {
            if ($Folders) {
              $(${__/=\/=\_/=====\_}.Items() | ? -FilterScript { $_.IsFolder -and (($_.Name -eq ${_/\____/\_/\/\_/\}) -or ($_.Name -match ${_/\____/\_/\/\_/\}.Replace('.', '\.').Replace('*', '.*'))) }) | % -Process { Write-Host "Removing Folder: $($_.Name)"; $_.InvokeVerbEx("Delete", 0x14) }
            } else {
              $(${__/=\/=\_/=====\_}.Items() | ? -FilterScript { !$_.IsFolder -and (($_.Name -eq ${_/\____/\_/\/\_/\}) -or ($_.Name -match ${_/\____/\_/\/\_/\}.Replace('.', '\.').Replace('*', '.*'))) }) | % -Process { Write-Host "Removing File: $($_.Name)"; $_.InvokeVerbEx("Delete", 0x14) }
            }
          }
          ForEach (${_/=\____/===\___/} in $(${__/=\/=\_/=====\_}.Items() | ? -FilterScript { $_.IsFolder })) {
            Zip-File -ZipFile "$ZipFile\$(${_/=\____/===\___/}.Name)" -Remove $Remove -Folders:$Folders
          }
        }
        Catch {
          Throw "Error Removing Files from Zip Archive"
        }
        Break
      }
      "Extract" {
        Try {
          if (![System.IO.Directory]::Exists($Destination)) {
            [Void][System.IO.Directory]::CreateDirectory($Destination)
          }
          ${________/==\__/\/} = ${_/=\____/=\/\_/\_}.NameSpace($Destination)
          ForEach (${_/\____/\_/\/\_/\} in $Extract) {
            if ($Folders) {
              $(${__/=\/=\_/=====\_}.Items() | ? -FilterScript { $_.IsFolder -and (($_.Name -eq ${_/\____/\_/\/\_/\}) -or ($_.Name -match ${_/\____/\_/\/\_/\}.Replace('.', '\.').Replace('*', '.*'))) }) | % -Process { Write-Host "Extracting Folder: $($_.Name) to $Destination"; ${________/==\__/\/}.CopyHere($_, 0x14) }
            } else {
              $(${__/=\/=\_/=====\_}.Items() | ? -FilterScript { !$_.IsFolder -and (($_.Name -eq ${_/\____/\_/\/\_/\} -and $_.Name -ne ".Dir") -or ($_.Name -match ${_/\____/\_/\/\_/\}.Replace('.', '\.').Replace('*', '.*'))) }) | % -Process { Write-Host "Extracting File: $($_.Name) to $Destination"; ${________/==\__/\/}.CopyHere($_, 0x14) }
            }
          }
          ForEach (${_/=\____/===\___/} in $(${__/=\/=\_/=====\_}.Items() | ? -FilterScript { $_.IsFolder })) {
            Zip-File -ZipFile "$ZipFile\$(${_/=\____/===\___/}.Name)" -Extract $Extract -Destination "$Destination\$(${_/=\____/===\___/}.Name)" -Folders:$Folders
          }
        }
        Catch {
        $Error[0]
          Throw "Error Extracting Files from Zip Archive"
        }
        Break
      }
      "List" {
        Try {
          ${__/=\/=\_/=====\_}.Items() | ? -FilterScript { !$_.IsFolder -and $_.Name -ne ".Dir" } | select -Property "Name", "Size", "ModifyDate", "Type", @{"Name"="Path";"Expression"={$(if ($($PSCmdlet.MyInvocation.BoundParameters["Path"])) {$($PSCmdlet.MyInvocation.BoundParameters["Path"])} else {"\"})}}
          ForEach (${_/=\____/===\___/} in $(${__/=\/=\_/=====\_}.Items() | ? -FilterScript { $_.IsFolder })) {
            Zip-File -ZipFile "$ZipFile\$(${_/=\____/===\___/}.Name)" -List -Path "$(if ($($PSCmdlet.MyInvocation.BoundParameters["Path"])) {$($PSCmdlet.MyInvocation.BoundParameters["Path"])})\$(${_/=\____/===\___/}.Name)"
          }
        }
        Catch {
          Throw "Error Listing Files in Zip Archive"
        }
        Break
      }
    }
  }
  End {
    ${_/=\____/=\/\_/\_} = $Null
    ${__/=\/=\_/=====\_} = $Null
    if ($PSCmdlet.ParameterSetName -eq "Add") {
      if ([System.IO.Directory]::Exists(${_/==\/\__/==\/\/\})) {
        [Void][System.IO.Directory]::Delete(${_/==\/\__/==\/\/\}, $True)
      }
    }
  }
}



Zip-File -ZipFile D:\Temp.zip -Add "D:\Test\*.txt" -Recurse

Zip-File -ZipFile D:\Temp.zip -List | ft


























