break #Safety net. This script is supposed to be run line by line interactively, not all at once.

<#

PowerShell Desired State Configuration is currently not supported on PowerShell Core (per April 2018).

Quote from "Desired State Configuration (DSC) Planning Update – January 2018":
"We also expect to have LCM providers for PowerShell Core, C++, and Python. 
These providers will introduce the ability to Get/Set/Test across Windows, Linux, and MacOS, by a common LCM."
Source: https://blogs.msdn.microsoft.com/powershell/2018/01/26/dsc-planning-update-january-2018/
#>

# For container images running Windows PowerShell 4 or higher, DSC can be leveraged as we`re used to.

<#
Gotcha: Remember RunAsAdministrator/--privileged when working with DSC commands interactively:
[9594f3487b1c...]: PS C:\Users\ContainerUser\Documents> Get-DscLocalConfigurationManager
Get-DscLocalConfigurationManager : Access denied
    + CategoryInfo          : PermissionDenied: (MSFT_DSCLocalConfigurationManager:root/Microsoft/...gurationManager)
#>

#cd ~\Documents\github\psconfeu2018-shared\docker

Open-EditorFile -Path .\DSCContainerDemo\DSCContainerDemo.ps1
Open-EditorFile -Path .\DSCContainerDemo\Dockerfile

docker build DSCContainerDemo -t psconfeu:dsccontainerdemo

docker run -it  psconfeu:dsccontainerdemo powershell

# Takes a few seconds to spin up (Server Core is much slower than Nano to initialize), when ready we can check that the Spooler configuration is applied
Get-DscConfiguration

exit

<#

*Discussion point*

Whether DSC, Docker files or something else is used for configuration management inside a container is a design decision.

Some ideas:
-Push a DSC configuration as the above demo
-Use pull mode, for example against Azure Automation DSC, to dynamically retrieve the latest configuration when the container spins up

#>