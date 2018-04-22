$labName = 'DscLab1'
if (-not (Get-Lab -ErrorAction SilentlyContinue).Name -eq $labName)
{
    Import-Lab -Name $labName -NoValidation
}

$pullServers = Get-LabVM -Role DSCPullServer
$sqlServer = Get-LabVM -Role SQLServer2016 | Select-Object -First 1

#-------------------------------------------------------------------------------------------------

Import-Module -Name $PSScriptRoot\LabHelper.psm1

Invoke-LabCommand -ComputerName $pullServers -ActivityName 'Configure Quick Access' -ScriptBlock {

    Invoke-ShellActivity -Path 'C:\Program Files\WindowsPowerShell\Modules' -Verb 'Pin to Quick access'
    Invoke-ShellActivity -Path 'C:\Program Files\WindowsPowerShell\DscService\Configuration' -Verb 'Pin to Quick access'
    Invoke-ShellActivity -Path 'C:\DscScripts' -Verb 'Pin to Quick access'

} -Function (Get-Command -Name Invoke-ShellActivity)

Invoke-LabCommand -ComputerName $pullServers -ActivityName 'Configure Explorer' -ScriptBlock {

    #show file extensions
    Set-ItemProperty -Path HKCU:\software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Value 0
    #Combine when taskbar is full
    Set-ItemProperty -Path HKCU:\software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name TaskbarGlomLevel -Value 1
    #open file explorer to PC
    Set-ItemProperty -Path HKCU:\software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
    
    #Removing recenlty used files from quick access
    Set-ItemProperty -Path HKCU:\software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Start_TrackDocs -Value 0
    #Removing recenlty used folders from quick access
    Set-ItemProperty -Path HKCU:\software\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Value 0

}

Invoke-LabCommand -ActivityName 'Configure ISESteroids' -ComputerName $pullServers -ScriptBlock {

    mkdir -Path "$([System.Environment]::GetFolderPath('MyDocuments'))\WindowsPowerShell" -Force | Out-Null
    'Import-Module -Name ISESteroids' | Out-File -FilePath "$([System.Environment]::GetFolderPath('MyDocuments'))\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1"
    
    mkdir -Path "$([System.Environment]::GetFolderPath('ApplicationData'))\ISESteroids\Options" -Force | Out-Null

}

$isePath = Invoke-LabCommand -ComputerName $pullServers[0] -ScriptBlock { "$([System.Environment]::GetFolderPath('ApplicationData'))\ISESteroids\Options" } -PassThru -NoDisplay
Copy-LabFileItem -Path $PSScriptRoot\options.xml -DestinationFolder $isePath -ComputerName $pullServers -UseAzureLabSourcesOnAzureVm $false

#$desktop = Invoke-LabCommand -ComputerName $pullServers[0] -ScriptBlock { [System.Environment]::GetFolderPath('Desktop') } -PassThru -NoDisplay
#Copy-LabFileItem -Path "$PSScriptRoot\..\DscScripts" -DestinationFolder $desktop -ComputerName $pullServers -UseAzureLabSourcesOnAzureVm $false