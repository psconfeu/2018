# -----------------------------------------------------------------------------
# Script	: To Export User Profile Information Value in Excel and HTML
# Author	: Chendrayan Venkatesan
# Company	: Tata Consultancy Services
# Date		: October 26 2012
# Version	: 1.0
# -----------------------------------------------------------------------------
#. Use Internal name of the user profile property.
#. Any custom user fields will have "SPS-".
#. Remove comment "#" in line 43 and do the same in line 48 if you need HTML output.
#. Provide location after out-file to save the HTML file.
#. In Line 59 use the same location as Out-File.
#. Append if you have any custom fields in mysite user profile property
#. For HTML look and feel please copy and paste the style.css in C:\.
#. Use any style.css as per organization standard and policy.
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
${_/=\_/\___/=\_/==} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('WQBvAHUAcgAgAE0AeQBzAGkAdABlACAASABvAHMAdAAgAE4AYQBtAGUA')))
${/====\__/=====\_/} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBhAHYAZQAgAHQAaABlACAATwB1AHQAcAB1AHQAIABGAGkAbABlACAAaQBuACAAeQBvAHUAcgAgAGQAZQBzAGkAcgBlAGQAIABMAG8AYwBhAHQAaQBvAG4A')))
${__/==\/=\/==\/=\_} = Get-SPServiceContext -Site ${_/=\_/\___/=\_/==}
${__/==\/\_/=\/==\/} = New-Object Microsoft.Office.Server.UserProfiles.UserProfileManager(${__/==\/=\/==\/=\_});
${/===\_/==\/===\__} = ${__/==\/\_/=\/==\/}.GetEnumerator()
${___/==\__/=\/\/=\} = @()
foreach ($profile in ${/===\_/==\/===\__}) {
   ${/==\/\/\/\/==\/\/} = "" | 
   select $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QQBjAGMAbwB1AG4AdABOAGEAbQBlAA=='))), $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UAByAGUAZgBlAHIAcgBlAGQATgBhAG0AZQA='))) , $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RABlAHAAYQByAHQAbQBlAG4AdAA='))) , $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBhAG4AYQBnAGUAcgA='))) , $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TwBmAGYAaQBjAGUA'))) , $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TABvAGMAYQB0AGkAbwBuAA=='))) , $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VwBvAHIAawBFAG0AYQBpAGwA'))) , $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QQBzAHMAaQBzAHQAYQBuAHQA'))) , $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QQBiAG8AdQB0AE0AZQA='))) , $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TABhAG4AZwB1AGEAZwBlAA=='))) , $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UABpAGMAdAB1AHIAZQBVAFIATAA='))) , $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UgBvAGwAZQA=')))
   ${/==\/\/\/\/==\/\/}.AccountName = $profile[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QQBjAGMAbwB1AG4AdABOAGEAbQBlAA==')))]
   ${/==\/\/\/\/==\/\/}.PreferredName = $profile[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UAByAGUAZgBlAHIAcgBlAGQATgBhAG0AZQA=')))]
   ${/==\/\/\/\/==\/\/}.Manager = $profile[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBhAG4AYQBnAGUAcgA=')))]
   ${/==\/\/\/\/==\/\/}.Department = $profile[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RABlAHAAYQByAHQAbQBlAG4AdAA=')))]
   ${/==\/\/\/\/==\/\/}.Office = $profile[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TwBmAGYAaQBjAGUA')))]
   ${/==\/\/\/\/==\/\/}.Location = $profile[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TABvAGMAYQB0AGkAbwBuAA==')))]
   ${/==\/\/\/\/==\/\/}.WorkEmail = $profile[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VwBvAHIAawBFAG0AYQBpAGwA')))]
   ${/==\/\/\/\/==\/\/}.Assistant = $profile[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QQBzAHMAaQBzAHQAYQBuAHQA')))]
   ${/==\/\/\/\/==\/\/}.AboutMe = $profile[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('QQBiAG8AdQB0AE0AZQA=')))].Value
   ${/==\/\/\/\/==\/\/}.Language = $profile[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TABhAG4AZwB1AGEAZwBlAA==')))]
   ${/==\/\/\/\/==\/\/}.PictureURL = $profile[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UABpAGMAdAB1AHIAZQBVAFIATAA=')))]
   ${/==\/\/\/\/==\/\/}.Role = $profile[$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UgBvAGwAZQA=')))]
   #$collection += $profileData | ConvertTo-Html -Fragment
   ${___/==\__/=\/\/=\} += ${/==\/\/\/\/==\/\/}
}
#ConvertTo-Html -Body "$collection" -CssUri C:\style.CSS | Out-File "Location to save"
${___/==\__/=\/\/=\} | epcsv ${/====\__/=====\_/} -NoTypeInformation
#Send Mail to Box for easy access
${/==\/=\__/\____/\} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TgBhAG0AZQAgAG8AZgAgAHQAaABlACAAUwBNAFQAUAAgAFMAZQByAHYAZQByAA==')))
${_/\/\/===\__/=\/\} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RQBtAGEAaQBsACAAQQBkAGQAcgBlAHMAcwA=')))
${_/\____/\/==\/===} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RQBtAGEAaQBsACAAQQBkAGQAcgBlAHMAcwA='))) , $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RQBtAGEAaQBsACAAQQBkAGQAcgBlAHMAcwA=')))
${/===\___/\__/\/=\} = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VQBzAGUAcgAgAFAAcgBvAGYAaQBsAGUAIABJAG4AZgBvAHIAbQBhAHQAaQBvAG4AIABSAGUAcABvAHIAdAA=')))
Send-MailMessage -From ${_/\/\/===\__/=\/\} -To ${_/\____/\/==\/===} -SmtpServer ${/==\/=\__/\____/\} -Subject ${/===\___/\__/\/=\} -Attachments $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('UwBhAG0AZQAgAGEAcwAgAE8AdQB0AC0ARgBpAGwAZQAgAEwAbwBjAGEAdABpAG8AbgA=')))