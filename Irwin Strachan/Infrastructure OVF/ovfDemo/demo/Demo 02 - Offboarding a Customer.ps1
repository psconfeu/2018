#region New offboarding Customer
Clear-Host
Import-Module C:\scripts\modules\ovfDemo\ovfDemo.psm1

$paramCustomer = @{
    CustomerName = 'PickWick Inc.'
    CustomerCode = '199912'
    TicketNr = '20180329001'
}

Write-Host "Offboarding customer $($paramCustomer.CustomerName)" -ForegroundColor Magenta
New-OffBoard @paramCustomer -Verbose
Pause
#endregion

#region Run Offboarding tests
Clear-Host

Write-Host "Running Offboard OVF test for $($paramCustomer.CustomerName)" -ForegroundColor Magenta
Test-OffBoard @paramCustomer
Send-SlackOvfNotification @paramCustomer -Mode Offboard
Write-Host 'Sending teams notification' -ForegroundColor Magenta
Send-TeamsOvfNotification @paramCustomer -Mode Offboard
Pause
#endregion

#region New offboarding Customer Folders
Clear-Host

Write-Host "Offboarding customer  folders for $($paramCustomer.CustomerName)" -ForegroundColor Magenta
New-OffBoardFolders -FileServer WIN2k16-001 @paramCustomer -Verbose
Pause
#endregion

#region Run Offboarding customer Folders
Clear-Host

Write-Host "Running OffboardFolders OVF test for $($paramCustomer.CustomerName)" -ForegroundColor Magenta
Test-OffBoardFolders -FileServer WIN2k16-001 @paramCustomer
Write-Host 'Sending slack notification' -ForegroundColor Magenta
Send-SlackOvfNotification @paramCustomer -Mode OffboardFolders
Write-Host 'Sending teams notification' -ForegroundColor Magenta
Send-TeamsOvfNotification @paramCustomer -Mode OffboardFolders
#endregion