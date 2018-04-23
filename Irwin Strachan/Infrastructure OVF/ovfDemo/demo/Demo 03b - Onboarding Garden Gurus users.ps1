#region Onboarding users
Import-Module C:\scripts\modules\ovfDemo\ovfDemo.psm1

$paramADUsers = @{
    File = 'PSConfEU - Demo AD Users.xlsx'
    Path = 'C:\scripts\sources\xlsx'
    WorkSheetName = 'Garden gurus'
    CustomerName = 'Garden Gurus'
    CustomerCode = '014456'
}

$paramReport = @{
    CustomerName = 'Garden Gurus'
    CustomerCode = '014456'
    Mode = 'ADUsers'
}

Write-Host  "Onboarding users for $($paramADUsers.CustomerName)" -ForegroundColor Magenta
New-OnboardADUsers @paramADUsers -Verbose
Pause
Clear-Host
#endregion

#region Test Onboarding users
Write-Host  "Running Onboard users OVF test for $($paramCustomer.CustomerName)" -ForegroundColor Magenta
Get-ADUsersTests @paramADUsers
Pause
#endregion

#region Changing some property value for demo purposes
Clear-Host
Write-Host  "Changing some user properties for demo purposes" -ForegroundColor Magenta

#Change some properties for demo purposes
Set-ADUser -Identity 'Inho1958' -City 'Baarn' -GivenName 'Marvin' -PassThru
Set-ADUser -Identity 'Froccattled' -Title 'Mrs.' -Surname 'Jarvis' -PassThru
Pause
Clear-Host

Write-Host "Verifying that differences exists" -ForegroundColor Magenta
#Test ADUsers settings again
Get-ADUsersTests @paramADUsers
Pause
Clear-Host
#endregion

#region Correcting user properties
Write-Host "Correcting user properties" -ForegroundColor Magenta
Set-ADUsersTests -CustomerCode $paramADUsers.CustomerCode -Verbose
Pause
Clear-Host
#endregion

#region Verifying that values were set
Write-Host "Verifying that differences were coreccted" -ForegroundColor Magenta
Get-ADUsersTests @paramADUsers
Pause
Clear-Host

Write-Host "Get HTMLReport" -ForegroundColor Magenta
Get-NUnitHtmlReport @paramReport
#endregion