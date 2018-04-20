  



function Get-ComputerService(){
param([string]${_____/\__/=====\/=})

${_/====\/\/==\/=\/}=$null
[array]${__/=\_/\_/===\_/=}=@()
[array]${_/\_/===\/===\_/=}=@()

${_/====\/\/==\/=\/}=Get-WmiObject -Namespace 'root\cimv2' -Class 'win32_service' -ComputerName ${_____/\__/=====\/=}

${_/====\/\/==\/=\/} | % {
    ${____/\/\___/==\/=}=New-Object System.Object
    ${____/\/\___/==\/=} | Add-Member -Type NoteProperty -Name 'Display-Name' -Value $_.DisplayName -Force
    ${____/\/\___/==\/=} | Add-Member -Type NoteProperty -Name 'Service name' -Value $_.Name -Force
    ${____/\/\___/==\/=} | Add-Member -Type NoteProperty -Name 'Service-Account' -Value $_.StartName -Force
    
    switch ($_.State) {
        'Running' {${__/=\_/\_/===\_/=}+=${____/\/\___/==\/=}}    
        'Stopped' {${_/\_/===\/===\_/=}+=${____/\/\___/==\/=}}
        }     
    }
    
    Write-Host "---- >>> State: Running Services <<<----" -BackgroundColor Green -ForegroundColor Black
    ${__/=\_/\_/===\_/=} | Sort-Object 'Display-Name' | Format-Table -AutoSize
    
    Write-Host "---- >>> State: Stopped Services <<<----" -BackgroundColor Red -ForegroundColor White   
    ${_/\_/===\/===\_/=} | Sort-Object 'Display-Name' | Format-Table -AutoSize
    
    
    Write-Host " "
    Write-Host "-- R E S U L T --" -BackgroundColor Green -ForegroundColor Black
    Write-Host "Running: " ${__/=\_/\_/===\_/=}.count -BackgroundColor Yellow -ForegroundColor Red
    Write-Host "Stopped: " ${_/\_/===\/===\_/=}.count -BackgroundColor Yellow -ForegroundColor Red
    
} 



Clear-Host

${_____/\__/=====\/=}= Read-Host "Please Enter Computername"

[bool]${/===\/==\/=====\/}=Test-Connection  -Computer ${_____/\__/=====\/=} -Count 1 -Quiet
if (${/===\/==\/=====\/} -eq $false) { Write-Host " Computer is not reachable " -BackgroundColor Red -ForegroundColor White; break}
else {Get-ComputerService -_____/\__/=====\/= ${_____/\__/=====\/=}}
