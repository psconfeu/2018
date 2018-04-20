<#

    .NOTES
    Name     : CapsLockNotifier.ps1
    Author   : Bryan Jaudon <bryan.jaudon@gmail.com>
    Version  : 1.0
    Date     : 10/25/2012

    .Description
    Adds a notification icon to show current CapsLock status. Double clicking or by using the context menu, allows for 
    toggling of the CapsLock status.


#>

#requires -version 2

param([switch]$Debug)

function CheckCapsLock {
    $CapsLockStatus=[console]::CapsLock
    Write-Debug "CheckCapsLock - Previous Reading: $Script:PreviousCapsLock - Current Reading: $CapsLockStatus"
    if ($PreviousCapsLock -ne $CapsLockStatus) {
        if ($CapsLockStatus -eq $True) {
            Write-Debug "CheckCapsLock - Update CapsLock NotificationIcon to ON"
            $NotifyIcon.Icon = $IconOn 
            $NotifyIcon.BalloonTipTitle = "CapsLock is On"
            $NotifyIcon.Text="CapsLock Status - On"
            $NotifyIcon.BalloonTipText = "CapsLock status has changed to On."
        }
        else { 
            Write-Debug "CheckCapsLock - Update CapsLock NotificationIcon to OFF"
            $NotifyIcon.Icon = $IconOff 
            $NotifyIcon.BalloonTipTitle = "CapsLock is Off"
            $NotifyIcon.Text="CapsLock Status - Off"
            $NotifyIcon.BalloonTipText = "CapsLock status has changed to Off."
        }
        Write-Debug "CheckCapsLock - Show NotificationIcon BaloonTip"
        $NotifyIcon.BalloonTipIcon = "Info"  
        $NotifyIcon.Visible = $True 
        $NotifyIcon.ShowBalloonTip(50000)  
    }
    $Script:PreviousCapsLock=$CapsLockStatus
}

function ToggleCapsLock {
    $wshObject=New-Object -ComObject "WScript.Shell"
    $wshObject.SendKeys('{CapsLock}')
    Write-Debug "ToggleCapsLock - wshObject Sendkeys(CapsLock)"
}

Function Hide-PowerShell { $null = $showWindowAsync::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0) }

[void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
[void][reflection.assembly]::loadwithpartialname("System.Drawing")

[string]$IconOnb64=@"
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
AABJRU5ErkJggg==
"@

$IconOnstream=[System.IO.MemoryStream][System.Convert]::FromBase64String($IconOnb64)
$IconOnbmp=[System.Drawing.Bitmap][System.Drawing.Image]::FromStream($IconOnstream)
$IconOnhandle=$IconOnbmp.GetHicon()
$IconOn=[System.Drawing.Icon]::FromHandle($IconOnhandle)

[string]$IconOffb64=@"
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
QmCC
"@

$IconOffstream=[System.IO.MemoryStream][System.Convert]::FromBase64String($IconOffb64)
$IconOffbmp=[System.Drawing.Bitmap][System.Drawing.Image]::FromStream($IconOffstream)
$IconOffhandle=$IconOffbmp.GetHicon()
$IconOff=[System.Drawing.Icon]::FromHandle($IconOffhandle)

$form1 = New-Object System.Windows.Forms.form
$NotifyIcon= New-Object System.Windows.Forms.NotifyIcon
$ContextMenu = New-Object System.Windows.Forms.ContextMenu
$MenuItemToggle = New-Object System.Windows.Forms.MenuItem
$MenuItemExit = New-Object System.Windows.Forms.MenuItem
$Timer = New-Object System.Windows.Forms.Timer

$form1.ShowInTaskbar = $false
$form1.WindowState = "minimized"

$NotifyIcon.ContextMenu = $ContextMenu
$NotifyIcon.contextMenu.MenuItems.AddRange($MenuItemToggle)
$NotifyIcon.contextMenu.MenuItems.AddRange($MenuItemExit)
$NotifyIcon.Visible = $True
$NotifyIcon.add_DoubleClick({ Write-Debug "NotifyIcon - DoubleClickEvent: ToggleCapsLock"; ToggleCapsLock })

$Timer.Interval =  1000
$Timer.add_Tick({ CheckCapsLock })
$Timer.start()

$MenuItemToggle.Index = 0
$MenuItemToggle.Text = "&Toggle CapsLock"
$MenuItemToggle.add_Click({ Write-Debug "NotifyIcon - MenuItemEvent: ToggleCapsLock"; ToggleCapsLock })

$MenuItemExit.Index = 1
$MenuItemExit.Text = "E&xit"
$MenuItemExit.add_Click({ Write-Debug "NotifyIcon - ExitEvent"; $Timer.stop(); $NotifyIcon.Visible = $False; $form1.close() })

$script:showWindowAsync = Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -name Win32ShowWindowAsync -namespace Win32Functions -PassThru

if ($host.name -ne "Windows PowerShell ISE Host") { 
    if ($Debug -ne $True) { Hide-PowerShell }
    else { $DebugPreference="Continue" }
}

$Script:PreviousCapsLock=[console]::CapsLock
if ($Script:PreviousCapsLock -eq $True) {
    Write-Debug "Initilization - CapsLock On"
    $NotifyIcon.Icon = $IconOn 
    $NotifyIcon.Text="CapsLock Status - On"
}
else {
    Write-Debug "Initilization - CapsLock Off"
    $NotifyIcon.Icon = $IconOff 
    $NotifyIcon.Text="CapsLock Status - Off"
}

[void][System.Windows.Forms.Application]::Run($form1)
