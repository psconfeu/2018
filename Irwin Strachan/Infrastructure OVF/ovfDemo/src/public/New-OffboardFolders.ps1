Function New-OffBoardFolders {
    [CmdletBinding()]
    param(
        $CustomerCode,
        $CustomerName,
        $FileServer = 'WIN2k16-001',
        $TicketNr
    )

    #region 1 Get DFSn link
    $DFSLink = Get-DfsnRoot -ErrorAction SilentlyContinue |
        Where-Object {$_.Path -like '*Data'}|
        foreach-object {
        Get-DfsnFolder "$($_.Path)\*" |
            Where-Object {$_.Path -like "*$CustomerCode"} |
            Get-DfsnFolderTarget
    }
    #endregion

    #region 2 Deleting  Folder & Target
    if ($DFSLink) {
        #region 2.1 Delete DFSn Link
        $DFSLink |
            ForEach-Object {
            Write-Verbose "Deleting DFSnFolder $($DFSLink.Path)"
            Remove-DfsnFolder $_.Path -Force -ErrorAction SilentlyContinue
        }
        #endregion

        #region 2.2 Delete DFSn Target
        if (Test-Path -Path $DFSLink.TargetPath) {
            Write-Verbose "Deleting TargetPath $($DFSLink.TargetPath)"
            Remove-Item -LiteralPath $DFSLink.TargetPath -Recurse -Force
        }
        #endregion
    }
    else{
        Write-Verbose "DFSn Link for costumercode $CustomerCode doesn't exists"
    }
    #endregion
}
