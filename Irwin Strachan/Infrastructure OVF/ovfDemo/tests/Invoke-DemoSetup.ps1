#Edit CurrentTAb
$psISE.CurrentPowerShellTab.DisplayName = 'Begin'
$null = $psISE.CurrentPowerShellTab.Files.Add('C:\scripts\modules\ovfDemo\tests\Prerequisits.OVFDemo.Tests.ps1')


#Open Demo 01 Scripts in new PowerShell tab
$tab = $psISE.PowerShellTabs.Add()
$tab.DisplayName = 'Demo 01 - Onboarding'
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\demo\Demo 01 - Onboarding a Customer.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\src\public\New-OnBoard.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\src\public\Test-OnBoard.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\tests\ovf\NewOnboard.Tests.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\src\public\New-OnBoardFolders.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\src\public\Test-OnBoardFolders.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\tests\ovf\NewOnboardFolders.Tests.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\src\public\Send-TeamsOvfNotification.ps1')
$tab = $psISE.PowerShellTabs.Add()
$tab.DisplayName = 'Demo 02 - Offboarding'
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\demo\Demo 02 - Offboarding a Customer.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\src\public\New-OffBoard.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\src\public\Test-OffBoard.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\tests\ovf\NewOffboard.Tests.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\src\public\New-OffboardFolders.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\src\public\Test-OffboardFolders.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\tests\ovf\NewOffboardFolders.Tests.ps1')
$tab = $psISE.PowerShellTabs.Add()
$tab.DisplayName = 'Demo 03 - Onboarding / Offboarding Garden Gurus'
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\demo\Demo 03a - Onboarding Garden Gurus.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\demo\Demo 03b - Onboarding Garden Gurus users.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\src\public\Get-ADUsersTests.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\src\public\Set-ADUsersTests.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\tests\ovf\ADUsers.Properties.Tests.ps1')
$null = $tab.Files.Add('C:\scripts\modules\ovfDemo\demo\Demo 03c - Offboarding Garden Gurus.ps1')
