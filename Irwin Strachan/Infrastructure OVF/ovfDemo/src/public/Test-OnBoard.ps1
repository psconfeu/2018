Function Test-OnBoard {
    [CmdletBinding()]
    param(
        $CustomerName,
        $CustomerCode,
        $TicketNr
    )
    $ovfRoot = (Get-Module -Name ovfDemo).ModuleBase
    $exportFolder = 'C:\exports\onboard'

    $testOnboarding = @{
        Script       = @(
            @{
                Path       = "$ovfRoot\tests\ovf\NewOnboard.Tests.ps1"
                Parameters = @{
                    CustomerName = $CustomerName
                    CustomerCode = $CustomerCode
                }
            }
        )
        OutputFile   = "$exportFolder\Onboard-$($CustomerCode)-TestResults-NUnit.xml"
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
        Export-Clixml $exportFolder\OnboardTestResults-$($CustomerCode).xml -Encoding UTF8
}