#region New onboarding Customer
Import-Module C:\scripts\modules\ovfDemo\ovfDemo.psm1

$paramCustomer = @{
    CustomerName = 'PickWick Inc.'
    CustomerCode = '199912'
    TicketNr = '20180329001'
}

Write-Host "Onboarding customer $($paramCustomer.CustomerName)" -ForegroundColor Magenta
New-OnBoard @paramCustomer -Verbose
Pause
#endregion

#region Run Onboarding Customer tests
Clear-Host
Write-Host "Running Onboard OVF test for $($paramCustomer.CustomerName)" -ForegroundColor Magenta
Test-OnBoard @paramCustomer
Write-Host 'Sending slack notification' -ForegroundColor Magenta
Send-SlackOvfNotification @paramCustomer -Mode Onboard
Write-Host 'Sending teams notification' -ForegroundColor Magenta
Send-TeamsOvfNotification @paramCustomer -Mode Onboard
Pause
#endregion

#region New Onboarding Customer folders
Clear-Host
Write-Host "Onboarding customer folders $($paramCustomer.CustomerName)" -ForegroundColor Magenta
New-OnBoardFolders -FileServer WIN2k16-001 @paramCustomer
Pause
#endregion

#region Run Onboarding Customer folders tests
Clear-Host
Write-Host "Running OnboardFolders OVF test for $($paramCustomer.CustomerName)" -ForegroundColor Magenta
Test-OnBoardFolders -FileServer WIN2k16-001 @paramCustomer
Pause
Clear-Host

Write-Host 'Sending slack notification' -ForegroundColor Magenta
Send-SlackOvfNotification @paramCustomer -Mode OnboardFolders
#endregion
