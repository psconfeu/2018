Function New-OnBoard{
    [CmdletBinding()]

    param(
        [String]$CustomerName,
        [String]$CustomerCode,
        [String]$TicketNr
    )

    $paramOnboard = @{
        CustomerName = $CustomerName
        CustomerCode = $CustomerCode
    }

    New-CustomerOU @paramOnboard
    New-DefaultOUs @paramOnboard
    New-DefaultGlobalSecurityGroups @paramOnboard
    New-DefaultUniversalSecurityGroups @paramOnboard
    Set-ACEParentOU @paramOnboard
}