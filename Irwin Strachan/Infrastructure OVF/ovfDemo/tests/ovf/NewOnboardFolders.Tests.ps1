
<#

Author: ing. I.C.A. Strachan
Version: 1.0
Version History:

Purpose:

#>
[CmdletBinding()]
param(
    $CustomerCode,
    $FileServer
)

$dfsTarget = '\\{0}\Data01$\{1}' -f $FileServer, $CustomerCode
$dfsRoot = "\\pshirwin.local\Data"
$dfsLink = '{0}\{1}' -f $dfsRoot, $CustomerCode

#region OVF Main
Describe 'Customer Onboarding Folder structure operational readiness' {
    Context "Verifying default folders for `'$CustomerCode`' have been created" {
        it "Folder `'$dfsTarget\Data`' exists"{
            Test-Path -LiteralPath "$dfsTarget\Data" -PathType Container |
            Should Be $true
        }

        it "Folder `'$dfsTarget\Apps`' exists"{
            Test-Path -LiteralPath "$dfsTarget\Apps" -PathType Container |
            Should Be $true
        }

        it "Folder `'$dfsTarget\Profiles`' exists"{
            Test-Path -LiteralPath "$dfsTarget\Profiles" -PathType Container |
            Should Be $true
        }

        it "Folder `'$dfsTarget\Home`' exists"{
            Test-Path -LiteralPath "$dfsTarget\Home" -PathType Container |
            Should Be $true
        }
    }

    Context "Verifying DFSn Link for Customer `'$CustomerCode`' has been created"{
        it "Folder `'$dfsLink`' exists"{
            Test-Path -LiteralPath "$dfsLink" -PathType Container |
            Should Be $true
        }
    }
}