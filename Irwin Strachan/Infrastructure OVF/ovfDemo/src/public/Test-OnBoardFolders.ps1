Function Test-OnBoardFolders {
    [CmdletBinding()]
    param(
        $FileServer,
        $CustomerName,
        $CustomerCode,
        $TicketNr
    )
    $ovfRoot = (Get-Module -Name ovfDemo).ModuleBase
    $exportFolder = 'C:\exports\onboardfolders'

    $testOnboarding = @{
        Script       = @(
            @{
                Path       = "$ovfRoot\tests\ovf\NewOnboardFolders.Tests.ps1"
                Parameters = @{
                    FileServer   = $FileServer
                    CustomerCode = $CustomerCode
                }
            }
        )
        OutputFile   = "$exportFolder\OnboardFolders-$($CustomerCode)-TestResults-NUnit.xml"
        OutputFormat = 'NunitXml'
        PassThru     = $True
    }

    $onboardingTestResults = Invoke-Pester @testOnboarding

    if ($onboardingTestResults.FailedCount -eq '0') {
        "Processing [TicketNr: {0}] successful" -f $TicketNr
    }
    else {
        "Processing [TicketNr: {0}] failed" -f $TicketNr
    }

    #Export Pester results to xml
    $onboardingTestResults |
        Export-Clixml $exportFolder\OnboardFoldersTestResults-$($CustomerCode).xml -Encoding UTF8
}