Function Get-DockerContainer {
    
    docker ps --all --format '{{json .}}' | ConvertFrom-Json

}