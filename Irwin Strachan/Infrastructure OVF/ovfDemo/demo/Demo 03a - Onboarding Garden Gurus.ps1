#region New onboarding Customer
Import-Module C:\scripts\modules\ovfDemo\ovfDemo.psm1

$paramCustomer = @{
    CustomerName = 'Garden Gurus'
    CustomerCode = '014456'
    TicketNr = '20180327002'
}

$paramReport = @{
    CustomerName = 'Garden Gurus'
    CustomerCode = '014456'
}

Write-Host "Onboarding customer $($paramCustomer.CustomerName)" -ForegroundColor Magenta
New-OnBoard @paramCustomer -Verbose
Pause
#endregion

#region Run OVF Tests Onboard
Clear-Host

Write-Host "Running Onboard OVF test for $($paramCustomer.CustomerName)" -ForegroundColor Magenta
Test-OnBoard @paramCustomer
Pause

#Send-SlackOvfNotification @paramCustomer -Mode Onboard
#Send-TeamsOvfNotification @paramCustomer -Mode Onboard
Write-Host "Show HTML report Onboard OVF Tests" -ForegroundColor Magenta
Pause
Get-NUnitHtmlReport @paramReport -Mode Onboard
Pause
Clear-Host

Write-Host "Onboarding folder structure for $($paramCustomer.CustomerName)" -ForegroundColor Magenta
New-OnBoardFolders -FileServer WIN2k16-001 @paramCustomer
Pause
Clear-Host
Write-Host "Running OnboardFolders OVF test for $($paramCustomer.CustomerName)" -ForegroundColor Magenta
Test-OnBoardFolders -FileServer WIN2k16-001 @paramCustomer
#Send-SlackOvfNotification @paramCustomer -Mode OnboardFolders

Write-Host "Show HTML report OnboardFolders OVF Tests" -ForegroundColor Magenta
Pause
Get-NUnitHtmlReport @paramReport -Mode OnboardFolders
#endregion
