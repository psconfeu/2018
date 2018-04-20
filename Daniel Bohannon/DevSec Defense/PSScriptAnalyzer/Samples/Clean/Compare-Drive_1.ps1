param($ComputerName1,$ComputerName2)

$a = gwmi win32_volume -filter "DriveType=3"  -computername $ComputerName1 | where {@('Y:','Z:') -notcontains $_.DriveLetter} | select name, @{n='capacity'; e={[math]::truncate($_.Capacity/1GB)}}
$b = gwmi win32_volume -filter "DriveType=3"  -computername $ComputerName2 | where {@('Y:','Z:') -notcontains $_.DriveLetter} | select name, @{n='capacity'; e={[math]::truncate($_.Capacity/1GB)}}

Compare-Object -ReferenceObject $a -DifferenceObject $b -Property name,capacity -PassThru |
select-object name, @{n='ComputerName1';e={$ComputerName1}}, @{n='ComputerName2';e={$ComputerName2}}, 
@{n='Capacity1';e={$name = $_.name; $drive = $a | ? { $_.name -eq $name }; if ($drive.capacity) {$drive.capacity} else {0} }}, 
@{n='Capacity2';e={$name = $_.name; $drive = $b | ? { $_.name -eq $name }; if ($drive.capacity) {$drive.capacity} else {0} }} |
Sort-Object -Property name -Unique

#get-content .\\serverpairs.txt | %{$servers = $_ -split ','; .\\compare-drive.ps1 $servers[0] $servers[1] }  | ogv
