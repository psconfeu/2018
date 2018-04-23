#Create default export folders
$exportFolders = @(
    'Onboard'
    'Offboard'
    'Onboardfolders'
    'Offboardfolders'
    'ADUsers'
)
$exportFolders |
ForEach-Object{
    If (!(Test-path "c:\exports\$_")){
        $null = New-Item -Path "c:\exports\$_" -ItemType Directory  -Force
    }
}

# Implement your module commands in this script.
$ovfDemoRoot = Split-Path -Parent $PSCommandPath;
Get-ChildItem -Path "$ovfDemoRoot\Src\" -Include '*.ps1' -Recurse |
    ForEach-Object {
        ## https://becomelotr.wordpress.com/2017/02/13/expensive-dot-sourcing/
        . ([System.Management.Automation.ScriptBlock]::Create(
                [System.IO.File]::ReadAllText($_.FullName)
            ))
    }

$exportedFunctions = Get-ChildItem -Path "C:\scripts\modules\ovfDemo\src\public" |
ForEach-Object {
    $_.BaseName
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.

Export-ModuleMember -Function $exportedFunctions
