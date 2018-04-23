Function Test-OffBoard {
    [CmdletBinding()]
    param(
        $CustomerName,
        $CustomerCode,
        $exportDate = $(Get-Date -Format ddMMyyyy),
        $processedDate = (Get-Date).ToShortDateString(),
        $TicketNr
    )
    $ovfRoot = (Get-Module -Name ovfDemo).ModuleBase
    $exportFolder = 'C:\exports\offboard'

    $testOffboarding = @{
        Script       = @(
            @{
                Path       = "$ovfRoot\tests\ovf\NewOffboard.Tests.ps1"
                Parameters = @{
                    CustomerName  = $CustomerName
                    CustomerCode  = $CustomerCode
                    exportDate    = $exportDate
                    processedDate = $processedDate
                }
            }
        )
        OutputFile   = "$exportFolder\Offboard-$($CustomerCode)-TestResults-NUnit.xml"
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
        Export-Clixml $exportFolder\OffboardTestResults-$($CustomerCode).xml -Encoding UTF8
}