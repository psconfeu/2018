Function Get-NUnitHtmlReport {
    [CmdletBinding()]
    param(
        $CustomerName,
        $CustomerCode,
        [ValidateSet("Onboard","Offboard","OnboardFolders","OffboardFolders",'ADUsers')]
        [String]$Mode
    )

    $ovfRoot = (Get-Module -Name ovfDemo).ModuleBase
    $exportFolder = "C:\exports\$($Mode)"

    $null = & $ovfRoot\plug-ins\ReportUnit\reportunit.exe  "$exportFolder\$($Mode)-$($CustomerCode)-TestResults-NUnit.xml"
    Invoke-Item "$exportFolder\$($Mode)-$($CustomerCode)-TestResults-NUnit.html"
}