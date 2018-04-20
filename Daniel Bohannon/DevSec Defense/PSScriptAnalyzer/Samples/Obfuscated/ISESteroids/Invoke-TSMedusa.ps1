function Invoke-TSMedusa {
  
  Param(
    [Parameter(Mandatory = $true,
      Position = 0,
      ValueFromPipeLineByPropertyName = $true)]
    [Alias("PSComputerName","CN","MachineName","IP","IPAddress","ComputerName","Url","Ftp","Domain","DistinguishedName")]
    [string]$Identity,

    [parameter(Position = 1,
      ValueFromPipeLineByPropertyName = $true)]
    [string]$UserName,

    [parameter(Position = 2,
      ValueFromPipeLineByPropertyName = $true)]
    [string]$Password,

    [parameter(Position = 3)]
    [ValidateSet("SQL","FTP","ActiveDirectory","Web")]
    [string]$Service = "SQL"
  )
  Process {
    if($service -eq $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBRAEwA')))) {
      ${_/=\__/\/=\/=\/=\} = New-Object System.Data.SQLClient.SQLConnection
      if($userName) {
        ${_/=\__/\/=\/=\/=\}.ConnectionString = $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RABhAHQAYQAgAFMAbwB1AHIAYwBlAD0AJABpAGQAZQBuAHQAaQB0AHkAOwBJAG4AaQB0AGkAYQBsACAAQwBhAHQAYQBsAG8AZwA9AE0AYQBzAHQAZQByADsAVQBzAGUAcgAgAEkAZAA9ACQAdQBzAGUAcgBOAGEAbQBlADsAUABhAHMAcwB3AG8AcgBkAD0AJABwAGEAcwBzAHcAbwByAGQAOwA=')))
      } else {
        ${_/=\__/\/=\/=\/=\}.ConnectionString = $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cwBlAHIAdgBlAHIAPQAkAGkAZABlAG4AdABpAHQAeQA7AEkAbgBpAHQAaQBhAGwAIABDAGEAdABhAGwAbwBnAD0ATQBhAHMAdABlAHIAOwB0AHIAdQBzAHQAZQBkAF8AYwBvAG4AbgBlAGMAdABpAG8AbgA9AHQAcgB1AGUAOwA=')))
      }
      Try {
        ${_/=\__/\/=\/=\/=\}.Open()
        ${_/=\/==\____/\___} = $true
      }
      Catch {
        ${_/=\/==\____/\___} = $false
      }
      if(${_/=\/==\____/\___} -eq $true) {
        ${__/\/=\/\_/\/==\/} = switch(${_/=\__/\/=\/=\/=\}.ServerVersion) {
          { $_ -match "^6" } { $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBRAEwAIABTAGUAcgB2AGUAcgAgADYALgA1AA==')));Break }
          { $_ -match "^6" } { $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBRAEwAIABTAGUAcgB2AGUAcgAgADcA')));Break }
          { $_ -match "^8" } { $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBRAEwAIABTAGUAcgB2AGUAcgAgADIAMAAwADAA')));Break }
          { $_ -match "^9" } { $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBRAEwAIABTAGUAcgB2AGUAcgAgADIAMAAwADUA')));Break }
          { $_ -match $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('XgAxADAAXAAuADAAMAA='))) } { $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBRAEwAIABTAGUAcgB2AGUAcgAgADIAMAAwADgA')));Break }
          { $_ -match $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('XgAxADAAXAAuADUAMAA='))) } { $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBRAEwAIABTAGUAcgB2AGUAcgAgADIAMAAwADgAIABSADIA')));Break }
          Default { $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VQBuAGsAbgBvAHcAbgA='))) }
        }
      } else {
        ${__/\/=\/\_/\/==\/} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VQBuAGsAbgBvAHcAbgA=')))
      }
    } elseif($service -eq $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RgBUAFAA')))) {
      if($identity -notMatch $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('XgBmAHQAcAA6AC8ALwA=')))) {
        ${/=\____/\_/===\_/} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('ZgB0AHAAOgAvAC8A'))) + $identity
      } else {
        ${/=\____/\_/===\_/} = $identity
      }
      try {
        ${/==\/====\/\/=\__} = [System.Net.FtpWebRequest]::Create(${/=\____/\_/===\_/})
        ${/==\/====\/\/=\__}.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectoryDetails
        ${/==\/====\/\/=\__}.Credentials = new-object System.Net.NetworkCredential($userName, $password)
        ${_/\/\/\__/\/==\/=} = ${/==\/====\/\/=\__}.GetResponse()
        ${__/\/=\/\_/\/==\/} = ${_/\/\/\__/\/==\/=}.BannerMessage + ${_/\/\/\__/\/==\/=}.WelcomeMessage
        ${_/=\/==\____/\___} = $true
      } catch {
        ${__/\/=\/\_/\/==\/} = $error[0].ToString()
        ${_/=\/==\____/\___} = $false
      }
    } elseif($service -eq $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QQBjAHQAaQB2AGUARABpAHIAZQBjAHQAbwByAHkA')))) {
      Add-Type -AssemblyName System.DirectoryServices.AccountManagement
      ${_____/\/=\/=\____} = [System.DirectoryServices.AccountManagement.ContextType]::Domain
      Try {
        ${__/==\/=\/=\/====} = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(${_____/\/=\/=\____}, $identity)
        ${_/=\/==\____/\___} = $true
      }
      Catch {
        ${__/\/=\/\_/\/==\/} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VQBuAGEAYgBsAGUAIAB0AG8AIABjAG8AbgB0AGEAYwB0ACAARABvAG0AYQBpAG4A')))
        ${_/=\/==\____/\___} = $false
      }
      if(${_/=\/==\____/\___} -ne $false) {
        Try {
          ${_/=\/==\____/\___} = ${__/==\/=\/=\/====}.ValidateCredentials($username, $password)
          ${__/\/=\/\_/\/==\/} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UABhAHMAcwB3AG8AcgBkACAATQBhAHQAYwBoAA==')))
        }
        Catch {
          ${_/=\/==\____/\___} = $false
          ${__/\/=\/\_/\/==\/} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UABhAHMAcwB3AG8AcgBkACAAZABvAGUAcwBuACcAdAAgAG0AYQB0AGMAaAA=')))
        }
      }
    } elseif($service -eq $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VwBlAGIA')))) {
      if($identity -notMatch $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('XgAoAGgAdAB0AHAAfABoAHQAdABwAHMAKQA6AC8ALwA=')))) {
        ${/=\____/\_/===\_/} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('aAB0AHQAcAA6AC8ALwA='))) + $identity
      } else {
        ${/=\____/\_/===\_/} = $identity
      }
      ${__/\/=\/\/==\/\/\} = New-Object Net.WebClient
      ${________/==\/\/\_} = ConvertTo-SecureString -AsPlainText -String $password -Force
      ${/=\_/\_/=====\__/} = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName, ${________/==\/\/\_}
      ${__/\/=\/\/==\/\/\}.Credentials = ${/=\_/\_/=====\__/}
      Try {
        ${__/\/=\/\_/\/==\/} = ${__/\/=\/\/==\/\/\}.DownloadString(${/=\____/\_/===\_/})
        ${_/=\/==\____/\___} = $true
      }
      Catch {
        ${_/=\/==\____/\___} = $false
        ${__/\/=\/\_/\/==\/} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UABhAHMAcwB3AG8AcgBkACAAZABvAGUAcwBuACcAdAAgAG0AYQB0AGMAaAA=')))
      }
    }
    
    New-Object PSObject -Property @{
      ComputerName = $identity;
      UserName = $username;
      Password = $Password;
      Success = ${_/=\/==\____/\___};
      Message = ${__/\/=\/\_/\/==\/}
    } | Select-Object Success, Message, UserName, Password, ComputerName
  }
}
