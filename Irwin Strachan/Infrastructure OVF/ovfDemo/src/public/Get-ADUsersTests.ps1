function Get-ADUsersTests {
    [CmdletBinding()]
    Param(
        $File,
        $Path,
        $WorkSheetName,
        $CustomerName,
        $CustomerCode
    )

    $ovfRoot = (Get-Module -Name ovfDemo).ModuleBase
    $exportFolder = 'C:\exports\adusers'

    #Run PesterTest and save results
    $paramPester = @{
        Script       = @(
            @{
                Path       = "$ovfRoot\tests\ovf\\ADUsers.Properties.Tests.ps1"
                Parameters = @{
                    File          = $File
                    Path          = $Path
                    WorkSheetName = $WorkSheetName
                    CustomerName  = $CustomerName
                    CustomerCode  = $CustomerCode
                }
            }
        )
        OutputFile   = "$exportFolder\ADUsers-$($CustomerCode)-TestResults-NUnit.xml"
        OutputFormat = 'NunitXml'
        PassThru     = $True
    }

    $resultsTest = Invoke-Pester @paramPester

    #Get All failed tests
    $failedTests = $resultsTest.TestResult.where{$_.Passed -eq $false}

    $failedTests |
        ForEach-Object {
        #regex is my achilles heel ;-)
        $result = $_.Name.Split(':')[-1]
        $arrResult = $result.Split('/')

        [PSCustomObject]@{
            SamAccountName = ($_.Describe.split(':').Trim())[-1]
            Property       = $arrResult[0].Trim()
            Expected       = $arrResult[1].Trim()
        }
    } -OutVariable failedObjects

    $failedObjects |
        Export-Csv -Path $exportFolder\FailedTests-$CustomerCode.csv -Delimiter "`t" -NoTypeInformation -Encoding UTF8

    #Export Pester results to xml
    $resultsTest |
        Export-Clixml $exportFolder\ADUsersTestResults-$($CustomerCode).xml -Encoding UTF8
}