# Enable presentation mode
PresentationSettings.exe /Start

& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon

# Remove all containers (including stopped)
docker ps -a -q | foreach {docker rm -v $PSItem -f}

# Inspect
docker ps -a

# Remove all containers (including stopped)
docker ps -a -q | foreach {docker rm -v $PSItem -f}

# Inspect
docker ps -a

# Remove all volumes
docker volume ls -q | foreach {

    docker volume rm $PSItem

}

# Inspect
docker volume ls

# Remote machine where Image2Docker is run
# dir D:\temp\Image2DockerDemo | Remove-Item -Recurse -Force