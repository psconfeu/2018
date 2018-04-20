
Param
    (
    $FileName = "TEMP-PrintLog-$((get-date -format $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('eQB5AHkATQBNAGQAZAA='))))).csv",
    $eventRecordID,
    $eventChannel
    )
Begin
    {
        ${/==\/=\_/\/==\__/} = $MyInvocation.MyCommand.ToString()
        ${/=\/=====\/\_/=\_} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBpAGMAcgBvAHMAbwBmAHQALQBXAGkAbgBkAG8AdwBzAC0AUAByAGkAbgB0AFMAZQByAHYAaQBjAGUALwBPAHAAZQByAGEAdABpAG8AbgBhAGwA')))
        ${__/\__/\__/\_/\_/} = $MyInvocation.MyCommand.Path
        ${____/\/\__/==\/=\} = $env:USERDOMAIN + "\" + ${env:____/\/\__/==\/=\}
        $ErrorActionPreference = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwB0AG8AcAA=')))
        New-EventLog -Source ${/==\/=\_/\/==\__/} -LogName ${/=\/=====\/\_/=\_} -ErrorAction SilentlyContinue
        ${______/\_/\/==\__} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBjAHIAaQBwAHQAOgAgAA=='))) + ${__/\__/\__/\_/\_/} + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('CgBTAGMAcgBpAHAAdAAgAFUAcwBlAHIAOgAgAA=='))) + ${____/\/\__/==\/=\} + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('CgBTAHQAYQByAHQAZQBkADoAIAA='))) + (Get-Date).toString()
        Write-EventLog -LogName ${/=\/=====\/\_/=\_} -Source ${/==\/=\_/\/==\__/} -EventID $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('MQAwADAA'))) -EntryType $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('SQBuAGYAbwByAG0AYQB0AGkAbwBuAA=='))) -Message ${______/\_/\/==\__} 
        }
Process
    {
        Try
        {
            ${_/\/\__/\_/\__/==} = Get-WinEvent -LogName $eventChannel -FilterXPath "<QueryList><Query Id='0' Path='$eventChannel'><Select Path='$eventChannel'>*[System[(EventRecordID=$eventRecordID)]]</Select></Query></QueryList>"
            ${__/\_/\___/=\/\__} = ([xml]${_/\/\__/\_/\__/==}.ToXml())
            }
        Catch
        {
            ${______/\_/\/==\__} = $Error[0]
            Write-Warning ${______/\_/\/==\__}
            Write-EventLog -LogName ${/=\/=====\/\_/=\_} -Source ${/==\/=\_/\/==\__/} -EventID $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('MQAwADEA'))) -EntryType $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RQByAHIAbwByAA=='))) -Message ${______/\_/\/==\__} 
            Break
            }
        ${/=\/\_/=\/=\/=\__} = ${_/\/\__/\_/\__/==}.Properties[3].Value
        if(${/=\/\_/=\/=\/=\__}.IndexOf("\\") -gt -1)
        {
            ${_/\_/\___/=======} = "nslookup $(${/=\/\_/=\/=\/=\__}.Substring(2,(${/=\/\_/=\/=\/=\__}.Length)-2)) |Select-String 'Name:'"
            }
        else
        {
            ${_/\_/\___/=======} = "nslookup $(${/=\/\_/=\/=\/=\__}) |Select-String 'Name:'"
            }
        Try
        {
            [string]${/=\/=\_/=\/\_/==\} = Invoke-Expression ${_/\_/\___/=======}
            ${/=\/\_/=\/=\/=\__} = ${/=\/=\_/=\/\_/==\}.Substring(${/=\/=\_/=\/\_/==\}.IndexOf(" "),((${/=\/=\_/=\/\_/==\}.Length) - ${/=\/=\_/=\/\_/==\}.IndexOf(" "))).Trim()
            }
        Catch
        {
            ${/=\/\_/=\/=\/=\__} = $PrintJob.Properties[3].Value
            }
        ${_/\____/==\/=\_/\} = New-Object -TypeName PSObject -Property @{
            Time = ${_/\/\__/\_/\__/==}.TimeCreated
            Job = ${__/\_/\___/=\/\__}.Event.UserData.DocumentPrinted.Param1
            Document = ${__/\_/\___/=\/\__}.Event.UserData.DocumentPrinted.Param2
            User = ${__/\_/\___/=\/\__}.Event.UserData.DocumentPrinted.Param3
            Client = ${/=\/\_/=\/=\/=\__}
            Printer = ${__/\_/\___/=\/\__}.Event.UserData.DocumentPrinted.Param6
            Port = ${__/\_/\___/=\/\__}.Event.UserData.DocumentPrinted.Param5
            Size = ${__/\_/\___/=\/\__}.Event.UserData.DocumentPrinted.Param7
            Pages = ${__/\_/\___/=\/\__}.Event.UserData.DocumentPrinted.Param8
            }
        ${_/\____/==\/=\_/\} = ${_/\____/==\/=\_/\} |Select-Object -Property Size, Time, User, Job, Client, Port, PRinter, Pages, Document
        ${_/\____/==\/=\_/\} = ConvertTo-Csv -InputObject ${_/\____/==\/=\_/\} -NoTypeInformation
        }
End
    {
        if ((Test-Path -Path "P:\PrintLogs\$($FileName)") -eq $true)
        {
            ${_/\____/==\/=\_/\} |Select-Object -Skip 1 |Out-File -FilePath "P:\PrintLogs\$($FileName)" -Append
            }
        else
        {
            ${_/\____/==\/=\_/\} |Out-File -FilePath "P:\PrintLogs\$($FileName)"
            }
        ${______/\_/\/==\__} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBjAHIAaQBwAHQAOgAgAA=='))) + ${__/\__/\__/\_/\_/} + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('CgBTAGMAcgBpAHAAdAAgAFUAcwBlAHIAOgAgAA=='))) + ${____/\/\__/==\/=\} + $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('CgBGAGkAbgBpAHMAaABlAGQAOgAgAA=='))) + (Get-Date).toString()
        Write-EventLog -LogName ${/=\/=====\/\_/=\_} -Source ${/==\/=\_/\/==\__/} -EventID $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('MQAwADAA'))) -EntryType $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('SQBuAGYAbwByAG0AYQB0AGkAbwBuAA=='))) -Message ${______/\_/\/==\__}
        }