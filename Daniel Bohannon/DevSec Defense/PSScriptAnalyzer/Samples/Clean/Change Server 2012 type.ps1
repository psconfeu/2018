<#
.SYNOPSIS
Use this script to change Windows Server 2012 to 1 of 4 types.  The script installs or uninstalls
windows features to get to the desired type.  The 4 types are:
Core - just a commandline
Minimal - commandline with added binaries to run some MMCs and Server Manager
Full GUI - standard desktop look with all GUI tools
RemoteDesktop - Add the desktop experience pack to be used in a Remote Desktop farm setting.

.DESCRIPTION
Convert-Win2012ServerType -Type (Core, Min, Gui, RemoteDesktop)

.PARAMETER Type
Choose one of the following - Core, Min, Gui, RemoteDesktop

.Notes
	* Author  - Nate Pope
	* Date	  - 11/28/2012
	* Version - .3
.EXAMPLE
To convert to a core install:
Convert-Win2012ServerType -Type Core

Convert to a GUI install:
Convert-Win2012ServerType -Type GUI

 #>
 param(
 [Parameter(Mandatory=$true)]
 [String[]]$Type
 )
 
Function InstallMask {
$InstallMask = 0
if ((get-windowsfeature server-gui-mgmt-infra).installed) {
	$InstallMask += 1
}
if ((get-windowsfeature server-gui-Shell).installed) {
	$InstallMask += 2
}
if ((get-windowsfeature Desktop-Experience).installed) {
	$InstallMask += 4
}
return $InstallMask
}

Function Covert2Core($mask) {
if ($mask -eq 0){ 
Write-Verbose "Already Core"
return
}
$inst = uninstall-windowsFeature -Name Desktop-Experience, server-gui-Shell, server-gui-mgmt-infra 

return $inst.RestartNeeded
}

Function Covert2Min($mask) {
if ($mask -eq 1){ 
Write-Verbose "Already Min"
return
}else {
uninstall-windowsFeature -name server-gui-shell, desktop-Experience 
}
$inst = install-windowsFeature server-gui-mgmt-infra
return $inst.RestartNeeded
}

Function Covert2Gui($mask) {
if ($mask -eq 3){ 
Write-Verbose "Already Full Gui"
return
}elseif ($mask -gt 4 ) {
uninstall-windowsFeature -name Desktop-Experience
}
$inst = install-windowsFeature -Name server-gui-Shell, server-gui-mgmt-infra
return $inst.RestartNeeded
}

Function Covert2RD($mask) {
if ($mask -eq 7){ 
Write-Verbose "Already Remote Desktop "
return
}
$inst = install-windowsFeature -Name Desktop-Experience, server-gui-Shell, server-gui-mgmt-infra
return $inst.RestartNeeded
}

 
########################################################################################################### 
 

 $mask = InstallMask
 switch ($Type) {
	Core {
		$reboot = Covert2Core($mask)
		break
	}
	Min {
		$reboot = Covert2Min($mask)
		break
	}
	Gui {
		$reboot = Covert2Gui($mask)
		break
	}
	RemoteDesktop {
		$reboot = Covert2RD($mask)
		break
	}
	default {
		Write-Warning "The TYPE parameter must be specified (Core, Min, Gui, or RemoteDesktop)"
		break
	}
}
if ($reboot) { Restart-Computer }

