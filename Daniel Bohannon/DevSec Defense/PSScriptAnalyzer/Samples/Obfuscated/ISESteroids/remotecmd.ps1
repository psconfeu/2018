function Run-RemoteCMD { 
 
    param( 
    [Parameter(Mandatory=$true,valuefrompipeline=$true)] 
    [string]$compname) 
    begin { 
        ${__/\_/\__/=\/==\/} = [char]34+"powermt display dev=all"+[char]34+" > c:\temp\log.txt" 
        [string]${__/=\/==\__/\/===} = "CMD.EXE /C " +${__/\_/\__/=\/==\/} 
                        } 
    process { 
        ${________/\/\_/=\/} = Invoke-WmiMethod -class Win32_process -name Create -ArgumentList (${__/=\/==\__/\/===}) -ComputerName $compname | out-null
        Start-sleep -s 5
        ${/==\_/==\/\/\_/\/}=Get-Content \\$compname\C$\temp\log.txt | Out-String
        Write-Output ${/==\_/==\/\/\_/\/}
     
     
     
     
    } 
    End{Write-Output "Script ...END"} 
                 } 