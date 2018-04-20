funtcion Add-SVNFile {
    # Usage Get-Childitem C:\\Scripts\\ | Add-SVNFile -Uri https://svn.internal.foo.com/svn/mycoolgame/branches/1.81 -Comment "Not sure if it's working"
    param (
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [String[]]$File,
        [Parameter(Position=1,Mandatory=$true)]
        [String]$Uri, #Ton dépot SVN ex: https://svn.internal.foo.com/svn/mycoolgame/branches/1.81
        [Parameter(Position=2,Mandatory=$true)]
        [String]$Comment = "Nothing"
    )

    Start-Process -Filepath "svn.exe" -ArgumentList "co $uri" -Wait -WindowStyle Hidden
    Start-Process -Filepath "svn.exe" -ArgumentList "add $File" -Wait -WindowStyle Hidden
    Start-Process -Filepath "svn.exe" -ArgumentList "ci -m $Comment $File" -Wait -WindowStyle Hidden

}
