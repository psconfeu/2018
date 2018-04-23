Function New-OffBoard{
    [CmdletBinding()]

    param(
        [String]$CustomerName ,
        [String]$CustomerCode ,
        [String]$TicketNr
    )

    Export-CustomerADObjects -CustomerName $CustomerName -CustomerCode $CustomerCode
    Remove-CustomerOU -CustomerName $CustomerName -CustomerCode $CustomerCode
}