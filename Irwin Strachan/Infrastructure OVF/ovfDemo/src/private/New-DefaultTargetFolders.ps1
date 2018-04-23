Function New-DefaultTargetFolders {
    [CmdletBinding()]
    param(
        $CustomerCode,
        $FileServer
    )

    $dfsTarget = '\\{0}\Data01$\{1}' -f $FileServer, $CustomerCode
    $domainNetBiosName = (Get-ADDomain).NetBiosName

    if (!(Test-Path -LiteralPath "$dfsTarget\Data" -PathType Container)) {
        New-Item -Path "$dfsTarget\Data" -type directory -Force
    }

    if (!(Test-Path -LiteralPath "$dfsTarget\Apps" -PathType Container)) {
        New-Item -Path "$dfsTarget\Apps" -type directory -Force
    }

    if (!(Test-Path -LiteralPath "$dfsTarget\Profiles" -PathType Container)) {
        New-Item -Path "$dfsTarget\Profiles" -type directory -Force
    }

    if (!(Test-Path -LiteralPath "$dfsTarget\Home" -PathType Container)) {
        New-Item -Path "$dfsTarget\Home" -type directory -Force
    }

    #Set NTFS Security on Folders

    $defaultGlobalGroups = @(
        ('FS {0} FULL' -f $CustomerCode)
        ('FS {0} READ' -f $CustomerCode)
        ('FS {0} NONE' -f $CustomerCode)
        ('FS {0} LIST' -f $CustomerCode)
    )
    #region Set Default CSPM ACE entries on Customer parent Folder
    $defaultGlobalGroups |
        ForEach-Object {
        if ( Get-ADGroup -Filter { Name -eq $_ }) {
            switch -Wildcard ($_) {
                '*FULL' {
                    CMD /C ('icacls.exe {0} /grant:r "{1}\{2}:(OI)(CI)(F)" /C' -f $dfsTarget, $domainNetBiosName, $_)
                }
                '*NONE' {
                    CMD /C ('icacls.exe {0} /deny "{1}\{2}:(OI)(CI)(F)" /C' -f $dfsTarget, $domainNetBiosName, $_)
                }
                '*READ' {
                    CMD /C ('icacls.exe {0} /grant:r "{1}\{2}:(OI)(CI)(RX)" /C' -f $dfsTarget, $domainNetBiosName, $_)
                }
                '*LIST' {
                    CMD /C ('icacls.exe {0} /grant:r "{1}\{2}:(OI)(CI)(RD)" /C' -f $dfsTarget, $domainNetBiosName, $_)
                }
            }
        }
    }
}