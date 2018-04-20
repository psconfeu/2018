Add-PSSnapin $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBpAGMAcgBvAHMAbwBmAHQALgBTAGgAYQByAGUAUABvAGkAbgB0AC4AUABvAHcAZQByAFMAaABlAGwAbAA='))) -ErrorAction SilentlyContinue

function Remove-SPWebApplicationBlockedFileExtension {
<#
.Synopsis
 This function removes a file extension from a SharePoint Web Application's BlockedFileExtensions collection.

.Description
 This function removes a file extension from a SharePoint Web Application's BlockedFileExtensions collection.
 This ensures that files with the specified extension can be saved within the Web Application.
 When the remove operation is complete, the Get-SPWebApplicationBlockedFileExtension function is called to report the status of the file extension.
 This function has been verified to work with:
 ---All SharePoint 2010 and 2013 versions
 ---Will execute on Windows Server 2008, 2008 R2 and 2012

.Example
 Remove-SPWebApplicationBlockedFileExtension -WebApplication http://yourwebapplication -Extension "html"

 This example removes the "html" file extension from the BlockedFileExtensions collection for the SharePoint Web Application http://yourwebapplication

.Example
 Get-SPWebApplication | ForEach-Object {Remove-SPWebApplicationBlockedFileExtension -WebApplication $_ -Extension "html"}

 This example removes the "html" file extension from the BlockedFileExtensions collection for all SharePoint Web Applications (excluding Central Administration)
 
.PARAMETER WebApplication
 Required. SPWebApplicationPipeBind. Specifies a single SharePoint Web Application.

.PARAMETER Extension
 Required. String. Specify the file extension to remove from the specified WebApplication BlockedFileExtensions collection. This parameter is forced to lower case within the script.

.Notes
 Name: Remove-SPWebApplicationBlockedFileExtension
 Author: Craig Lussier
 Last Edit: 3/3/2013

.Link
 Get-SPWebApplicationBlockedFileExtension
 http://www.craiglussier.com
 http://twitter.com/craiglussier
 http://social.technet.microsoft.com/profile/craig%20lussier/
 # Requires PowerShell Version 2.0 or Version 3.0
#>
[CmdletBinding()]
Param(
[Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
[Microsoft.SharePoint.PowerShell.SPWebApplicationPipeBind]$WebApplication,
[Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=1)]
[string]$Extension
)

    Process {

        Write-Verbose $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RQBuAHQAZQByAGkAbgBnACAAUAByAG8AYwBlAHMAcwAgAEIAbABvAGMAawAgAC0AIABSAGUAbQBvAHYAZQAtAFMAUABXAGUAYgBBAHAAcABsAGkAYwBhAHQAaQBvAG4AQgBsAG8AYwBrAGUAZABGAGkAbABlAEUAeAB0AGUAbgBzAGkAbwBuAA==')))
        try {
            Write-Verbose $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RwBlAHQAIABXAGUAYgAgAEEAcABwAGwAaQBjAGEAdABpAG8AbgA=')))
            ${_/\/===\/===\/\/\} = Get-SPWebApplication $WebApplication
            ${__/\____/==\__/\/} = ${_/\/===\/===\/\/\}.DisplayName

            ${_/\/\/\_/\______/} = $Extension.ToLower().ToString()

            Write-Verbose $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RwBlAHQAIABXAGUAYgAgAEEAcABwAGwAaQBjAGEAdABpAG8AbgAgAEIAbABvAGMAawBlAGQARgBpAGwAZQBFAHgAdABlAG4AcwBpAG8AbgBzAA==')))
            ${_/==\/==\__/=\/=\} = ${_/\/===\/===\/\/\}.BlockedFileExtensions

            Write-Verbose $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QQB0AHQAZQBtAHAAdAAgAHQAbwAgAHIAZQBtAG8AdgBlACAAdABoAGUAIAAkAEUAeAB0AGUAbgBzAGkAbwBuACAAZQB4AHQAZQBuAHMAaQBvAG4AIABmAHIAbwBtACAAdABoAGUAIAB0AGgAZQAgAEIAbABvAGMAawBlAGQARgBpAGwAZQBFAHgAdABlAG4AcwBpAG8AbgBzACAAYwBvAGwAbABlAGMAdABpAG8AbgA=')))
            if(${_/==\/==\__/=\/=\} -contains ${_/\/\/\_/\______/}) {
                ${_/==\/==\__/=\/=\}.Remove(${_/\/\/\_/\______/}) | Out-Null
                ${_/\/===\/===\/\/\}.Update()
                Write-Verbose $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UgBlAG0AbwB2AGUAZAAgAHQAaABlACAAJAB7AF8ALwBcAC8AXAAvAFwAXwAvAFwAXwBfAF8AXwBfAF8ALwB9ACAAZQB4AHQAZQBuAHMAaQBvAG4AIABmAHIAbwBtACAAdABoAGUAIABCAGwAbwBjAGsAZQBkAEYAaQBsAGUARQB4AHQAZQBuAHMAaQBvAG4AcwAgAGMAbwBsAGwAZQBjAHQAaQBvAG4A')))
            }
            else {
                Write-Warning $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VABoAGUAIABFAHgAdABlAG4AcwBpAG8AbgAgACcAJAB7AF8ALwBcAC8AXAAvAFwAXwAvAFwAXwBfAF8AXwBfAF8ALwB9ACcAIABkAG8AZQBzACAAbgBvAHQAIABlAHgAaQBzAHQAIABpAG4AIAB0AGgAZQAgACcAJAB7AF8AXwAvAFwAXwBfAF8AXwAvAD0APQBcAF8AXwAvAFwALwB9ACcAIABXAGUAYgAgAEEAcABwAGwAaQBjAGEAdABpAG8AbgAuACAATgBvACAAUgBlAG0AbwB2AGUAIABhAGMAdABpAG8AbgAgAHQAYQBrAGUAbgAuAA==')))
            }

        }
        catch {
            Write-Error $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VABoAGUAcgBlACAAaABhAHMAIABiAGUAZQBuACAAYQBuACAAZQByAHIAbwByACAAdwBoAGkAbABlACAAYQB0AHQAZQBtAHAAdABpAG4AZwAgAHQAbwAgAHIAZQBtAG8AdgBlACAAdABoAGUAIABzAHAAZQBjAGkAZgBpAGUAZAAgAGUAeAB0AGUAbgBzAGkAbwBuACAAZgByAG8AbQAgAHQAaABlACAAQgBsAG8AYwBrAGUAZABGAGkAbABlAEUAeAB0AGUAbgBzAGkAbwBuAHMAIABjAG8AbABsAGUAYwB0AGkAbwBuACAAbwBmACAAdABoAGUAIABzAHAAZQBjAGkAZgBpAGUAZAAgAFcAZQBiACAAQQBwAHAAbABpAGMAYQB0AGkAbwBuAC4A')))
            Write-Error $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VAByAHkAIAByAHUAbgBuAGkAbgBnACAAUABvAHcAZQByAFMAaABlAGwAbAAgAGEAcwAgAEEAZABtAGkAbgBpAHMAdAByAGEAdABvAHIAIABhAG4AZAAgAG0AYQBrAGUAIABzAHUAcgBlACAAeQBvAHUAIABoAGEAdgBlACAAcAByAG8AcABlAHIAIABQAFMAUwBoAGUAbABsAEEAZABtAGkAbgAgAHAAZQByAG0AaQBzAHMAaQBvAG4AcwAgAHQAbwAgAHQAaABlACAAdQBuAGQAZQByAGwAeQBpAG4AZwAgAFMAUABDAG8AbgB0AGUAbgB0AEQAYQB0AGEAYgBhAHMAZQAgAGYAbwByACAAdABoAGUAIABzAHAAZQBjAGkAZgBpAGUAZAAgAFcAZQBiACAAQQBwAHAAbABpAGMAYQB0AGkAbwBuAA==')))
            Write-Error $_
        }

        try {
            Write-Verbose $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwBhAGwAbAAgAHQAaABlACAARwBlAHQALQBTAFAAVwBlAGIAQQBwAHAAbABpAGMAYQB0AGkAbwBuAEIAbABvAGMAawBlAGQARgBpAGwAZQBFAHgAdABlAG4AcwBpAG8AbgAgAGYAdQBuAGMAdABpAG8AbgAgAHQAbwAgAHYAZQByAGkAZgB5ACAAdABoAGEAdAAgAHQAaABlACAAJwAkAHsAXwAvAFwALwBcAC8AXABfAC8AXABfAF8AXwBfAF8AXwAvAH0AJwAgAGUAeAB0AGUAbgBzAGkAbwBuACAAZABvAGUAcwAgAG4AbwB0ACAAZQB4AGkAcwB0ACAAaQBuACAAdABoAGUAIABCAGwAbwBjAGsAZQBkAEYAaQBsAGUARQB4AHQAZQBuAHMAaQBvAG4AcwAgAGMAbwBsAGwAZQBjAHQAaQBvAG4AIABvAGYAIAB0AGgAZQAgAHMAcABlAGMAaQBmAGkAZQBkACAAVwBlAGIAIABBAHAAcABsAGkAYwBhAHQAaQBvAG4A')))
            
            Write-Verbose $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RABlAHQAZQByAG0AaQBuAGUAIAB0AGgAZQAgAGUAeABlAGMAdQB0AGkAbgBnACAAZgBvAGwAZABlAHIA'))) 
            ${__/\_/\/====\/==\} = & { Split-Path $myInvocation.ScriptName } #$i.scriptname

            Write-Verbose $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RABvAHQAIABzAG8AdQByAGMAZQAgAHQAaABlACAARwBlAHQALQBTAFAAVwBlAGIAQQBwAHAAbABpAGMAYQB0AGkAbwBuAEIAbABvAGMAawBlAGQARgBpAGwAZQBFAHgAdABlAG4AcwBpAG8AbgAuAHAAcwAxACAAZgBpAGwAZQAgAHQAbwAgAGwAbwBhAGQAIAB0AGgAZQAgAGYAdQBuAGMAdABpAG8AbgA=')))
            . $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('JAB7AF8AXwAvAFwAXwAvAFwALwA9AD0APQA9AFwALwA9AD0AXAB9AFwARwBlAHQALQBTAFAAVwBlAGIAQQBwAHAAbABpAGMAYQB0AGkAbwBuAEIAbABvAGMAawBlAGQARgBpAGwAZQBFAHgAdABlAG4AcwBpAG8AbgAuAHAAcwAxAA==')))

            Write-Verbose $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QwBhAGwAbABpAG4AZwAgAHQAaABlACAAdABoAGUAIABHAGUAdAAtAFMAUABXAGUAYgBBAHAAcABsAGkAYwBhAHQAaQBvAG4AQgBsAG8AYwBrAGUAZABGAGkAbABlAEUAeAB0AGUAbgBzAGkAbwBuACAAZgB1AG4AYwB0AGkAbwBuAA==')))
            Get-SPWebApplicationBlockedFileExtension -WebApplication $WebApplication -Extension ${_/\/\/\_/\______/}
        }
        catch {
            Write-Error $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VABoAGUAcgBlACAAaABhAHMAIABiAGUAZQBuACAAYQBuACAAZQByAHIAbwByACAAdwBoAGkAbABlACAAYQB0AHQAZQBtAHAAdABpAG4AZwAgAHQAbwAgAHYAZQByAGkAZgB5ACAAdABoAGEAdAAgAHQAaABlACAAcwBwAGUAYwBpAGYAaQBlAGQAIABlAHgAdABlAG4AcwBpAG8AbgAgAGgAYQBzACAAYgBlAGUAbgAgAHIAZQBtAG8AdgBlAGQAIABmAHIAbwBtACAAdABoAGUAIABCAGwAbwBjAGsAZQBkAEYAaQBsAGUARQB4AHQAZQBuAHMAaQBvAG4AcwAgAGMAbwBsAGwAZQBjAHQAaQBvAG4AIABvAGYAIAB0AGgAZQAgAHMAcABlAGMAaQBmAGkAZQBkACAAVwBlAGIAIABBAHAAcABsAGkAYwBhAHQAaQBvAG4ALgA=')))
            Write-Error $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBhAGsAZQAgAHMAdQByAGUAIAB0AGgAZQAgAEcAZQB0AC0AUwBQAFcAZQBiAEEAcABwAGwAaQBjAGEAdABpAG8AbgBCAGwAbwBjAGsAZQBkAEYAaQBsAGUAVAB5AHAAZQAuAHAAcwAxACAAZgBpAGwAZQAgAGkAcwAgAGkAbgAgAHQAaABlACAAcwBhAG0AZQAgAGYAbwBsAGQAZQByACAAYQBzACAAdABoAGUAIABSAGUAbQBvAHYAZQAtAFMAUABXAGUAYgBBAHAAcABsAGkAYwBhAHQAaQBvAG4AQgBsAG8AYwBrAGUAZABGAGkAbABlAEUAeAB0AGUAbgBzAGkAbwBuAC4AcABzADEAIABmAGkAbABlAC4A')))
            Write-Error $_
        }
        Write-Verbose $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TABlAGEAdgBpAG4AZwAgAFAAcgBvAGMAZQBzAHMAIABCAGwAbwBjAGsAIAAtACAAUgBlAG0AbwB2AGUALQBTAFAAVwBlAGIAQQBwAHAAbABpAGMAYQB0AGkAbwBuAEIAbABvAGMAawBlAGQARgBpAGwAZQBFAHgAdABlAG4AcwBpAG8AbgA=')))
    }

}