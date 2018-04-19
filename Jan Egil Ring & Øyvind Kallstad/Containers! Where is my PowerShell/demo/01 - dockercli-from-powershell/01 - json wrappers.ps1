break #Safety net. This script is supposed to be run line by line interactively, not all at once.

docker run hello-world

docker ps --all

docker ps --all --format '{{json .}}' | ConvertFrom-Json

docker ps --all --format '{{json .}}' | ConvertFrom-Json | Get-Member

docker images

docker images --format '{{json .}}' | ConvertFrom-Json

# Proof-of-concept module - PSDockerTools
Get-Content .\module\PSDockerTools\Functions\Get-DockerContainer.ps1
Get-Content .\module\PSDockerTools\Functions\Get-DockerImage.ps1
Get-Content .\module\PSDockerTools\Functions\Get-DockerObject.ps1

Import-Module .\module\PSDockerTools
Get-Command -Module PSDockerTools

Get-DockerContainer
Get-DockerImage

$Container = Get-DockerContainer | Select-Object -First 1
Get-DockerObject -ObjectID $Container.ID

# Hey! Let`s  not reinvent the wheel... Are there any existing Docker modules?

#region Microsoft module: PowerShell for Docker

<#
https://github.com/Microsoft/Docker-PowerShell
This repo contains a PowerShell module for the Docker Engine. It can be used as an alternative to the Docker command-line interface (docker), 
or along side it. It can target a Docker daemon running on any operating system that supports Docker, including both Windows and Linux.
#>

Register-PSRepository -Name DockerPS-Dev -SourceLocation https://ci.appveyor.com/nuget/docker-powershell-dev
Install-Module -Name Docker -Repository DockerPS-Dev -Scope CurrentUser
Get-Command -Module Docker

Get-Container
Get-ContainerImage

New-Container -ImageIdOrName microsoft/windowsservercore:1709 -Terminal -Command powershell | Start-Container

Get-Container | Select-Object -First 1 | Get-ContainerNetDetail # Docker API responded with status code=NotFound, response={"message":"network Docker.DotNet.Models.ContainerListResponse not found"}
Enter-ContainerSession -ContainerIdOrName (Get-Container | Select-Object -First 1).Id # Hangs

# "Note that this module is still in alpha status and is likely to change rapidly." 

# Module last updated 2 years ago and is probably not invested in anymore.

#endregion

#region Docker modules on PowerShell Gallery

Find-Module -Name *Docker*

# Microsoft`s official PackageManagement provider for installing Docker Enterprise Edition on Windows Server
Install-Module DockerMsftProvider -Scope CurrentUser -Force
Find-Package -ProviderName DockerMsftProvider

# posh-docker - Intellisense for docker.exe
Find-Module -Name posh-docker
Install-Module -Name posh-docker -Scope CurrentUser
Import-Module -Name posh-docker

# docker -> Tab from console

# That`s nice, but wrappers for Docker CLI is what we was looking for - let`s try out a few

#endregion

#region PSDockerHub

Find-Module -Name PSDockerHub
Install-Module -Name PSDockerHub -Scope CurrentUser
Get-Command -Module PSDockerHub

Find-DockerImage -SearchTerm powershell -MaxResults 5
Get-DockerImageDockerfile -Name microsoft/powershell
Get-DockerImageDetail -Name microsoft/powershell

#endregion

#region DockerPowershell

Find-Module -Name DockerPowershell
Install-Module -Name DockerPowershell -Scope CurrentUser -AllowClobber
Get-Command -Module DockerPowershell

$ContainerId = Get-ContainerId | Select-Object -First 1
Get-ContainerIp -ContainerId $ContainerId

Get-Content function:Invoke-DockerCommand
Get-Content function:Invoke-DockerPs

Invoke-DockerPs -Arguments --all

#endregion

#region DockerHelpers

Find-Module -Name DockerHelpers
Install-Module -Name DockerHelpers -Scope CurrentUser
Get-Command -Module DockerHelpers

Get-DockerContainer -All
Get-Content function:Get-DockerContainer

Get-DockerContainer -All -Inspect

Get-DockerVolume

#endregion

#region Other useful Docker-related PowerShell modules

Install-Module -Name DockerDsc -Scope CurrentUser
Get-DscResource -Module DockerDsc

#endregion