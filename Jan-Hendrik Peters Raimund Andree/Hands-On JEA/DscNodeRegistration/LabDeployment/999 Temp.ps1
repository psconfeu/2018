Copy-LabFileItem -Path $PSScriptRoot\PinTo10v2.exe -ComputerName $pullServers -DestinationFolderPath C:\Windows

Invoke-LabCommand -ActivityName 'Pin Apps to Taskbar' -ComputerName $pullServers -ScriptBlock {
    #PinTo10v2.exe /pintb C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe
    PinTo10v2.exe /pintb C:\Windows\System32\notepad.exe
} -PassThru

#The public key is required on the 
$otherDcs.NodeName | ForEach-Object {
    Get-LabCertificate -SearchString $_ -FindType FindBySubjectName -ComputerName $ca |
    Add-LabCertificate -ComputerName $_
}

Invoke-LabCommand -ComputerName $otherDcs.NodeName -ScriptBlock {
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -Force
}