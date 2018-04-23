Function Test-OffBoardFolders{
    [CmdletBinding()]
    param(
        $FileServer,
        $CustomerName,
        $CustomerCode,
        $TicketNr
    )
    $ovfRoot = (Get-Module -Name ovfDemo).ModuleBase
    $exportFolder = 'C:\exports\offboardfolders'

    $testOffboarding = @{
        Script       = @(
            @{
                Path       = "$ovfRoot\tests\ovf\NewOffboardFolders.Tests.ps1"
                Parameters = @{
                    FileServer   = $FileServer
                    CustomerCode = $CustomerCode
                }
            }
        )
        OutputFile   = "$exportFolder\OffboardFolders-$($CustomerCode)-TestResults-NUnit.xml"
        OutputFormat = 'NunitXml'
        PassThru     = $True
    }

    $offboardingTestResults = Invoke-Pester @testOffboarding

    if ($offboardingTestResults.FailedCount -eq '0') {
        "Processing [TicketNr: {0}] successful" -f $TicketNr
    }
    else {
        "Processing [TicketNr: {0}] failed" -f $TicketNr
    }

    #Export Pester results to xml
    $offboardingTestResults |
        Export-Clixml $exportFolder\OffboardFoldersTestResults-$($CustomerCode).xml -Encoding UTF8

}