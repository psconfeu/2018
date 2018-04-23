Function New-CustomerDFSnlink {
    [CmdletBinding()]
    param(
        $CustomerCode,
        $FileServer
    )

    #DFS variables
    $dfsRoot = "\\pshirwin.local\Data"
    $dfsLink = '{0}\{1}' -f $dfsRoot, $CustomerCode
    $dfsTarget = '\\{0}\Data01$\{1}' -f $FileServer, $CustomerCode

    $paramDFSnFolder = @{
        Path = $dfsLink
        TargetPath = $dfsTarget
        Description = "DFS link for $CustomerCode"
    }

    if(!(Test-Path -LiteralPath $dfsLink) -and (Test-Path -LiteralPath $dfsTarget)){
        New-DfsnFolder @paramDFSnFolder
    }
    else{
        Write-Verbose "DFS Link: $($dfsLink) exists"
    }
}