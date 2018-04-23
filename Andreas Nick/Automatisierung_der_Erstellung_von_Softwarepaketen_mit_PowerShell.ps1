<#  Andreas Nick Automatisierung der Erstellung von Softwarepaketen_mit PowerShell
                                          _            _  _
 _ __    ___  __      __  ___  _ __  ___ | |__    ___ | || |
| '_ \  / _ \ \ \ /\ / / / _ \| '__|/ __|| '_ \  / _ \| || |
| |_) || (_) | \ V  V / |  __/| |   \__ \| | | ||  __/| || |
| .__/  \___/   \_/\_/   \___||_|   |___/|_| |_| \___||_||_|
|_|
 
 _   _  ___   ___  _ __   __ _  _ __   ___   _   _  _ __
| | | |/ __| / _ \| '__| / _` || '__| / _ \ | | | || '_ \
| |_| |\__ \|  __/| |   | (_| || |   | (_) || |_| || |_) |
 \__,_||___/ \___||_|    \__, ||_|    \___/  \__,_|| .__/
                         |___/                     |_| 
 _
| |__    __ _  _ __   _ __    ___  __   __  ___  _ __
| '_ \  / _` || '_ \ | '_ \  / _ \ \ \ / / / _ \| '__|
| | | || (_| || | | || | | || (_) | \ V / |  __/| |
|_| |_| \__,_||_| |_||_| |_| \___/   \_/   \___||_|

#>

$PSDefaultParameterValues = @{"Write-Host:ForegroundColor" = "Green";"Write-Host:BackgroundColor" = "Black"}
throw "Ups, mark the code and use F8"

# Autosequencer in the he Windows Assessment and Deployment Kit (Windows ADK)
# https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install
# Auto Sequencer
# C:\Program Files (x86)\Windows Kits\10\Microsoft Application Virtualization\AutoSequencer

# Base Image from install.wim: Convert-WindowsImage
# https://gallery.technet.microsoft.com/scriptcenter/convert-windowsimageps1-0fe23a8f 
# Error with Windows 10 1709 - take https://github.com/nerdile/convert-windowsimage

Install-Module -Name Convert-WindowsImage

$script:SystemDrive = $Env:SystemDrive #Bugfix error Systemdrive not found

# $deltatime = [System.Diagnostics.Stopwatch]::StartNew()
# 8 Minutes
#  Convert-WindowsImage -SourcePath 'c:\temp\psconf\SW_DVD9_Win_Pro_10_1709.1_64BIT_English_Pro_Ent_EDU_N_MLF_X21-67518.ISO' `
#  -VHDFormat VHD -VHDPartitionStyle MBR -WorkingDirectory 'C:\temp\psconf' `
#  -Edition Enterprise 

  #1709
  C:\temp\psconf\Convert-WindowsImage\Convert-WindowsImage -SourcePath 'c:\temp\psconf\en_windows_10_enterprise_version_1703_updated_march_2017_x64_dvd_10189290.iso' `
  -VHDFormat VHD -VHDPartitionStyle MBR -WorkingDirectory 'C:\temp\psconf' 

  #1703
  C:\temp\psconf\Convert-WindowsImage -SourcePath 'c:\temp\psconf\en_windows_10_enterprise_version_1703_updated_march_2017_x64_dvd_10189290.iso' `
  -VHDFormat VHD -VHDPartitionStyle MBR -WorkingDirectory 'C:\temp\psconf\newimage\'

#$deltatime.Elapsed


# Requirements
# PS Remoting
Enable-PSRemoting -SkipNetworkProfileCheck -Force
Set-Item -Path wsman:\localhost\client\trustedhosts -Value *


# Hyper-V
# Install Hyper-V
Enable-WindowsOptionalFeature -Feature 'Microsoft-Hyper-V-All' -Online 

# vswitch 
New-VMSwitch -name ExternalSwitch  -NetAdapterName Ethernet -AllowManagementOS $true 

# Roll out the image
# Error for German OS: Get unknown architecture: , from VHD: c:\temp\psconf\16299.15.amd64fre.rs3_release.170928-1534_Client_Enterprise
# _en-US.vhd
# In New-AppVSequencerVM.psm1
# Line 31: $local:architecture = $local:DismResult | findstr /i "Architecture" | findstr /i "x86"
# and
# Line 37: $local:architecture = $local:DismResult | findstr /i "Architecture" | findstr /i "x64"
#
# Change "Architecture" to "Architektur"!


import-module "C:\Program Files (x86)\Windows Kits\10\Microsoft Application Virtualization\AutoSequencer\New-AppVSequencerVM\New-AppVSequencerVM.psm1" -Force

# 5 Minutes
#1709

$deltatime = [System.Diagnostics.Stopwatch]::StartNew()
New-AppVSequencerVM -VMName SEQ2 -ADKPath 'C:\temp\psconf\ADK-1709' `
                    -VHDPath 'C:\temp\psconf\16299.15.amd64fre.rs3_release.170928-1534_Client_Enterprise_en-US-2.vhd' `
                    -VMMemory 4096MB -CPUCount 1 -VMSwitch vswitch -Verbose
$deltatime.Elapsed

#1703
New-AppVSequencerVM -VMName SEQ3 -ADKPath 'C:\temp\psconf\ADK-1703' `
                    -VHDPath 'C:\temp\psconf\newimage\15063.0.amd64fre.rs2_release.170317-1834_Client_Enterprise_en-US.vhd' `
                    -VMMemory 2048MB -CPUCount 1 -VMSwitch Standardswitch -Verbose


# Auto Sequecer XML

[xml] $autoxml = @'
<?xml version="1.0"?>
<Applications>
  <Application>
    <AppName>Free_AppDeploy_Repackager</AppName>
    <InstallerFolder>C:\packages\msi</InstallerFolder>
    <Installer>Free_AppDeploy_Repackager.msi</Installer>
    <InstallerOptions>/qn</InstallerOptions>
    <Cmdlet>true</Cmdlet>
    <Enabled>true</Enabled>
  </Application>
</Applications>
'@

$autoxml.Save("$env:temp\autoseq.xml")

# Show the Module
#
#

#import-module -Name "C:\Program Files (x86)\Windows Kits\10\Microsoft Application Virtualization\AutoSequencer\New-BatchAppVSequencerPackages\New-BatchAppVSequencerPackages.psm1" -force
import-module -Name "C:\Program Files (x86)\Windows Kits\10\Microsoft Application Virtualization\AutoSequencer\AutoSequencer.psd1" -Force



# 5 Minutes
$deltatime = [System.Diagnostics.Stopwatch]::StartNew()
New-BatchAppVSequencerPackages -ConfigFile "C:\packages\autoseq.xml" -VMName "SEQ1" -OutputPath "C:\packages\output\" -Verbose
$deltatime.Elapsed


Connect-AppVSequencerVM -VMName SEQ1


#Join-Path : Cannot bind argument to parameter 'Path' because it is null.
#At C:\Program Files (x86)\Windows Kits\10\Microsoft Application Virtualization\AutoSequencer\AutoSequencingTelemetry.psm1:9 
#char:38
#+     $autoSeqTelemetryDll = Join-Path $AutoSequencingRoot $AUTO_SEQUEN ...

#Modified
# DLL that implements telemetry logging for Auto Sequencer
#$AUTO_SEQUENCER_TELEMETRY_DLL = 'C:\Program Files (x86)\Windows Kits\10\Microsoft Application Virtualization\AutoSequencer\Microsoft.AppV.AutoSequencing.Telemetry.dll'

# Diagnostic Event Source DLL
#$TRACING_EVENTSOURCE_DLL = 'C:\Program Files (x86)\Windows Kits\10\Microsoft Application Virtualization\AutoSequencer\Microsoft.Diagnostics.Tracing.EventSource.dll'

#function LoadAutoSequencingTelemetryProvider($AutoSequencingRoot)
#{
#    $autoSeqTelemetryDll = $AUTO_SEQUENCER_TELEMETRY_DLL
#    $autoseqlib = [Reflection.Assembly]::LoadFile($autoSeqTelemetryDll)
#    if ($autoseqlib  -ne $null)
#    {
#        $eventSourceDll = $TRACING_EVENTSOURCE_DLL
#        $eventsrclib = [Reflection.Assembly]::LoadFile($eventSourceDll)

import-module "C:\Program Files (x86)\Windows Kits\10\Microsoft Application Virtualization\AutoSequencer\AutoSequencingTelemetry.psm1" -Force

#Password: C:\ProgramData\Microsoft Application Virtualization\AutoSequencer\SequencerMachines


#Test
Enable-Appv
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

Add-AppvClientPackage C:\Packages\output\Free_AppDeploy_Repackager\Free_AppDeploy_Repackager.appv | 
Publish-AppvClientPackage

Get-AppvClientPackage free* | Unpublish-AppvClientPackage
Get-AppvClientPackage free* -all |Remove-AppvClientPackage

<#                 _                                    _        _
  __ _  _ __    __| | _ __   ___   __ _  ___     _ __  (_)  ___ | | __
 / _` || '_ \  / _` || '__| / _ \ / _` |/ __|   | '_ \ | | / __|| |/ /
  (_| || | | || (_| || |   |  __/| (_| |\__ \   | | | || || (__ |   <
 \__,_||_| |_| \__,_||_|    \___| \__,_||___/   |_| |_||_| \___||_|\_\
                _
 ___  _ __    __| |  ___
/ _ \| '_ \  / _` | / _ \
  __/| | | || (_| ||  __/
\___||_| |_| \__,_| \___|

#>

