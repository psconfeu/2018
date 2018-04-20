#Get list of all Management packs and their links from Technet Wiki
#Thanks to Stefan Stranger http://blogs.technet.com/b/stefan_stranger/archive/2013/03/13/finding-management-packs-from-microsoft-download-website-using-powershell.aspx
$allmpspage = iwr -Uri $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('aAB0AHQAcAA6AC8ALwBzAG8AYwBpAGEAbAAuAHQAZQBjAGgAbgBlAHQALgBtAGkAYwByAG8AcwBvAGYAdAAuAGMAbwBtAC8AdwBpAGsAaQAvAGMAbwBuAHQAZQBuAHQAcwAvAGEAcgB0AGkAYwBsAGUAcwAvADEANgAxADcANAAuAG0AaQBjAHIAbwBzAG8AZgB0AC0AbQBhAG4AYQBnAGUAbQBlAG4AdAAtAHAAYQBjAGsAcwAuAGEAcwBwAHgA')))
$mpslist = $allmpspage.Links | ? {($_.href -like $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('KgBoAHQAdABwADoALwAvAHcAdwB3AC4AbQBpAGMAcgBvAHMAbwBmAHQALgBjAG8AbQAvACoAZABvAHcAbgBsAG8AYQBkACoA')))) -and ($_.outerText -notlike $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('KgBMAGkAbgBrACAAdABvACAAZABvAHcAbgBsAG8AYQBkACAAcABhAGcAZQAqAA==')))) -and ($_.InnerHTML -like $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('KgBUAGgAaQBzACAAbABpAG4AawAqAA=='))))} | 
Select @{Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBhAG4AYQBnAGUAbQBlAG4AdAAgAFAAYQBjAGsA')));Expression={$_.InnerText}}, @{Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RABvAHcAbgBsAG8AYQBkACAATABpAG4AawA=')));Expression={$_.href}}
#Directory to save the downloaded management packs. Make sure it is created first before running the script
$dirmp = $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RAA6AFwATQBQAHMAXAA=')))
#go trough every MP
foreach ($mp in $mpslist)
{
#get MP link
$mplink = $mp.'Download Link'
#get MP name
$mpname = $mp.'Management Pack'
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBQACAATgBhAG0AZQA6AA=='))) $mpname
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBQACAATABpAG4AawA6AA=='))) $mplink
#Read MP page
$mppage = iwr -Uri "$mplink"
#Find all download links on the page (mp, guide and etc.). $_.href cannot be used beacuse some of the links require conformation before download
$dws = $mppage.Links | ? {($_.'bi:fileurl' -like $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('KgBoAHQAdABwADoALwAvAGQAbwB3AG4AbABvAGEAZAAuAG0AaQBjAHIAbwBzAG8AZgB0AC4AYwBvAG0ALwBkAG8AdwBuAGwAbwBhAGQAKgA=')))) } | Select @{Label=$([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RABvAHcAbgBsAG8AYQBkACAATABpAG4AawA=')));Expression={$_.'bi:fileurl'}}
#Find the version number of the MP on its page
$version = $mppage.ParsedHtml.getElementsByTagName("td") | Where $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('YwBsAGEAcwBzAG4AYQBtAGUA'))) -contains $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('YwBvAGwAMgA='))) | Select -ExpandProperty InnerText
#Remove character ? in fron of MP version. For some reason some versions of mps start with ?
$version = $version.Replace("?","")
#Remove / character from MP name if contains it beacuse can create unneeded directories
$mpname = $mpname.Replace("/","")
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQBQACAAVgBlAHIAcwBpAG8AbgA6AA=='))) $version
Write-Host $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RABvAHcAbgBsAG8AYQBkACAATABpAG4AawBzADoA'))) $dws
#Create directory with the Name of the MP and subdirecotory with the version of the MP
ni -ItemType directory -Path $dirmp\$mpname\$version
#Get the array of found download links
$dws = $dws.'Download Link'
#Get trough every download link
foreach ($dw in $dws)
{
#assign download link to $source variable
$source = $dw
#Get the name of the file that will be downloaded
$Filename = [System.IO.Path]::GetFileName($source)
#Set directory where the file to be downloaded
$dest = "$dirmp\$mpname\$version\$Filename"
#initiate client for download
$wc = New-Object System.Net.WebClient
#download the file and put it in the destination directory
$wc.DownloadFile($source, $dest)
}
#empy line
Write-Host
}