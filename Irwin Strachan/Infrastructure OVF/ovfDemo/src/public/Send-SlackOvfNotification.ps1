Function Send-SlackOvfNotification {
    [CmdletBinding()]
    param(
        $CustomerName,
        $CustomerCode,
        $TicketNr,
        [ValidateSet("Onboard","Offboard","OnboardFolders","OffboardFolders","ADUsers")]
        [String]$Mode
    )

    $exportFolder = "C:\exports\$($Mode)"

    $savedCreds = Import-CliXml -Path "${env:\userprofile}\slack.Cred"
    $token = $savedCreds.'slack-psconfeu2018'.GetNetworkCredential().Password

    #Import Onboarding testresults
    $testResults = Import-Clixml $exportFolder\$($Mode)TestResults-$($CustomerCode).xml

    $iconEmoji = @{$true = ':white_check_mark:'; $false = ':red_circle:'}[$testResults.FailedCount -eq 0]
    $color = @{$true = 'green'; $false = 'red'}[$testResults.FailedCount -eq 0]

    #SlackFields
    $Fields = [PSCustomObject]@{
        Total   = $testResults.TotalCount
        Passed  = $testResults.PassedCount
        Failed  = $testResults.FailedCount
        Skipped = $testResults.SkippedCount
        Pending = $testResults.PendingCount
    } | New-SlackField -Short

    $slackAttachments = @{
        Color      = $([System.Drawing.Color]::$color)
        PreText    = "$($Mode) results Customer $($CustomerName)"
        AuthorName = '@irwins'
        AuthorIcon = 'https://raw.githubusercontent.com/irwins/PowerShell-scripts/master/wrench.png'
        Fields     = $Fields
        Fallback   = 'Your client is bad'
        Title      = "Pester result counts ticket nr: $($TicketNr)"
        TitleLink  = 'https://www.youtube.com/watch?v=IAztPZBQrrU'
        Text       = @{$true = 'Everything passed'; $false = 'Check failed tests'}[$testResults.FailedCount -eq 0]
    }

    #$null = New-SlackMessageAttachment @slackAttachments |
    #New-SlackMessage -Channel 'powershell' -IconEmoji $iconEmoji -AsUser -Username '@irwins' |
    #Send-SlackMessage -Token $token

    New-SlackMessageAttachment @slackAttachments |
        New-SlackMessage -Channel 'psslack' -IconEmoji $iconEmoji -AsUser -Username '@irwins' |
        Send-SlackMessage -Token $token
}