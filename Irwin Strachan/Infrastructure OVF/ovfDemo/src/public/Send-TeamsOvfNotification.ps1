Function Send-TeamsOvfNotification {
    [CmdletBinding()]
    param(
        $CustomerName,
        $CustomerCode,
        $TicketNr,
        [ValidateSet("Onboard","Offboard","OnboardFolders","OffboardFolders","ADUsers")]
        [String]$Mode
    )

    #region MessageCard function helpers
    function MessageCard {
        param([scriptblock]$ScriptBlock)

        $newScript = "@{$($ScriptBlock.ToString())}"
        $newScriptBlock = [scriptblock]::Create($newScript)
        & $newScriptBlock
    }

    function section {
        param([scriptblock]$ScriptBlock)

        $newScript = "[Ordered]@{$($ScriptBlock.ToString())}"
        $newScriptBlock = [scriptblock]::Create($newScript)
        & $newScriptBlock
    }

    function fact {
        param([scriptblock]$ScriptBlock)

        $Invoked = $ScriptBlock.Invoke()
        $Invoked.Keys |
            ForEach-Object {
            @{
                Name  = $_
                Value = $Invoked.$_
            }
        }
    }
    #endregion

    $ovfRoot = (Get-Module -Name ovfDemo).ModuleBase
    $exportFolder = "C:\exports\$($Mode)"

    $thumbprint = (Get-ChildItem Cert:\CurrentUser\My\ -DocumentEncryptionCert |
            Where-Object { $_.Subject -like '*irwin*'}).Thumbprint

    $teamURI = Unprotect-CmsMessage -LiteralPath "$ovfRoot\Team.uri" -To $thumbPrint

    #Import Onboarding testresults
    $testResults = Import-Clixml $exportFolder\$($Mode)TestResults-$($CustomerCode).xml

    $NewMessage = MessageCard {
        summary = "$Mode results of customer $CustomerName"
        title   = "$Mode results of customer $CustomerName"
        text    = "Customer name: $CustomerName"

        sections = @(

            section {
                activetyTitle = '**Details Customer**'
                facts = fact {
                    @{
                        CustomerName = $CustomerName
                        CustomerCode = $CustomerCode
                        TicketNr     = $TicketNr
                        Onboarding   = @{$true = 'Successful'; $false = 'Failed'}[($testResults.FailedCount -eq '0')]
                    }
                }
            }
            #section
            section {
                activityTitle    = "Pester results $Mode"
                facts = fact {
                    @{
                        Total   = $testResults.TotalCount
                        Passed  = $testResults.PassedCount
                        Failed  = $testResults.FailedCount
                        Skipped = $testResults.SkippedCount
                        Pending = $testResults.PendingCount
                    }
                }
            }
        )
    }

    $paramTeam = @{
        Uri         = $teamURI
        Method      = 'POST'
        Body        = $($NewMessage | ConvertTo-Json -Depth 6)
        ContentType = 'application/JSON'
    }

    $null = Invoke-RestMethod @paramTeam
}