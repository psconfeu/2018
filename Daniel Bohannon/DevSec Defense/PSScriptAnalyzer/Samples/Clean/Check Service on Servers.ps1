<#
  Author:   Matt Schmitt
  Date:     11/29/12 
  Version:  1.0 
  From:     USA 
  Email:    ithink2020@gmail.com 
  Website:  http://about.me/schmittmatt
  Twitter:  @MatthewASchmitt
  
  Description
  A script for checking the status of a service on a group of servers, from a list in a file.  
#>


$serverList = Import-Csv 'c:\\serverList.csv'

"Server" +"`t" + "Status" | Out-File c:\\ServerService.csv


foreach ($element in $serverList) 
{
    
    $sStatus = get-service -Name "CPSVS" | Select-Object -expand Status

    $server = $element | Select-Object -expand Server

    $server + "`t" + $sStatus | Out-File -append c:\\ServerServiceStatus.csv

} 


Send-MailMessage -From donotreply@test.com -To recipient@domain.com -subject "Spooler Service Report" -Body "Attached is Server Service report." -Attachments "c:\\ServerServiceStatus.csv" -SmtpServer "xxx.xxx.xxx.xxx"
