# Where we are? - PowerShell way
#https://github.com/PowerShell/PowerShell/blob/master/build.psm1#L100-L158
#http://bit.ly/2H8tDcE

function Get-EnvironmentInformation
{
    $environment = @{}
    # PowerShell Core will likely not be built on pre-1709 nanoserver
    if ($PSVersionTable.ContainsKey("PSEdition") -and "Core" -eq $PSVersionTable.PSEdition) {
        $environment += @{'IsCoreCLR' = $true}
        $environment += @{'IsLinux' = $IsLinux}
        $environment += @{'IsMacOS' = $IsMacOS}
        $environment += @{'IsWindows' = $IsWindows}
    } else {
        $environment += @{'IsCoreCLR' = $false}
        $environment += @{'IsLinux' = $false}
        $environment += @{'IsMacOS' = $false}
        $environment += @{'IsWindows' = $true}
    }

    if ($Environment.IsWindows)
    {
        $environment += @{'IsAdmin' = (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)}
        # Can't use $env:HOME - not available on older systems (e.g. in AppVeyor)
        $environment += @{'nugetPackagesRoot' = "${env:HOMEDRIVE}${env:HOMEPATH}\.nuget\packages"}
    }
    else
    {
        $environment += @{'nugetPackagesRoot' = "${env:HOME}/.nuget/packages"}
    }

    if ($Environment.IsLinux) {
        $LinuxInfo = Get-Content /etc/os-release -Raw | ConvertFrom-StringData

        $environment += @{'LinuxInfo' = $LinuxInfo}
        $environment += @{'IsDebian' = $LinuxInfo.ID -match 'debian'}
        $environment += @{'IsDebian8' = $Environment.IsDebian -and $LinuxInfo.VERSION_ID -match '8'}
        $environment += @{'IsDebian9' = $Environment.IsDebian -and $LinuxInfo.VERSION_ID -match '9'}
        $environment += @{'IsUbuntu' = $LinuxInfo.ID -match 'ubuntu'}
        $environment += @{'IsUbuntu14' = $Environment.IsUbuntu -and $LinuxInfo.VERSION_ID -match '14.04'}
        $environment += @{'IsUbuntu16' = $Environment.IsUbuntu -and $LinuxInfo.VERSION_ID -match '16.04'}
        $environment += @{'IsUbuntu17' = $Environment.IsUbuntu -and $LinuxInfo.VERSION_ID -match '17.04'}
        $environment += @{'IsCentOS' = $LinuxInfo.ID -match 'centos' -and $LinuxInfo.VERSION_ID -match '7'}
        $environment += @{'IsFedora' = $LinuxInfo.ID -match 'fedora' -and $LinuxInfo.VERSION_ID -ge 24}
        $environment += @{'IsOpenSUSE' = $LinuxInfo.ID -match 'opensuse'}
        $environment += @{'IsSLES' = $LinuxInfo.ID -match 'sles'}
        $environment += @{'IsOpenSUSE13' = $Environmenst.IsOpenSUSE -and $LinuxInfo.VERSION_ID  -match '13'}
        $environment += @{'IsOpenSUSE42.1' = $Environment.IsOpenSUSE -and $LinuxInfo.VERSION_ID  -match '42.1'}
        $environment += @{'IsRedHatFamily' = $Environment.IsCentOS -or $Environment.IsFedora}
        $environment += @{'IsSUSEFamily' = $Environment.IsSLES -or $Environment.IsOpenSUSE}

        # Workaround for temporary LD_LIBRARY_PATH hack for Fedora 24
        # https://github.com/PowerShell/PowerShell/issues/2511
        if ($environment.IsFedora -and (Test-Path ENV:\LD_LIBRARY_PATH)) {
            Remove-Item -Force ENV:\LD_LIBRARY_PATH
            Get-ChildItem ENV:
        }
    }

    return [PSCustomObject] $environment
}

$Environment = Get-EnvironmentInformation

#Where are we? - Pester way - the GetPesterOs function
#https://github.com/pester/Pester/blob/master/Functions/Environment.ps1#L7-L30
#http://bit.ly/2H8tDcE

function GetPesterOs
{
    # Prior to v6, PowerShell was solely on Windows. In v6, the $IsWindows variable was introduced.
    if ((GetPesterPsVersion) -lt 6)
    {
        'Windows'
    }
    elseif (Get-Variable -Name 'IsWindows' -ErrorAction 'SilentlyContinue' -ValueOnly )
    {
        'Windows'
    }
    elseif (Get-Variable -Name 'IsMacOS' -ErrorAction 'SilentlyContinue' -ValueOnly )
    {
        'macOS'
    }
    elseif (Get-Variable -Name 'IsLinux' -ErrorAction 'SilentlyContinue' -ValueOnly )
    {
        'Linux'
    }
    else
    {
        throw "Unsupported Operating system!"
    }
}