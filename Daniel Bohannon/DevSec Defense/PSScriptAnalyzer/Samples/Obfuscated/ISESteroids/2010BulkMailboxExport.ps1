










${/==\/==\/==\/\_/\} = Import-Csv D:\ExportedPST\users.csv

foreach (${___/\/\_/\/==\_/=} in ${/==\/==\/==\/\_/\})
{

Write-Host "`nStarted processing ${___/\/\_/\/==\_/=}.FirstName" -ForegroundColor Cyan
${__/\/===\____/\/=} = ${___/\/\_/\/==\_/=}.FirstName+${___/\/\_/\/==\_/=}.LastName
New-MailboxExportRequest -DomainController g1vdceu01.eu.bpww.org  -Mailbox ${___/\/\_/\/==\_/=}.Alias -FilePath "\\g1vmbxarch01\D$\ExportedPST\${__/\/===\____/\/=}.pst"
}

	
