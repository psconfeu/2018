Function New-OnBoardFolders {
    [CmdletBinding()]
    param(
        [String]$FileServer,
        [String]$CustomerName,
        [String]$CustomerCode,
        [String]$TicketNr
    )

    if (Test-Connection -ComputerName $FileServer){
        New-DefaultTargetFolders -CustomerCode $CustomerCode -FileServer $FileServer
        New-CustomerDFSnLink -CustomerCode $CustomerCode -FileServer $FileServer
    }
    else {
        Write-Warning "Seems like the FileServer $($FileServer) isn't online"
    }
}
