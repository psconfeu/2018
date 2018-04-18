Function Get-DockerObject {
    param (
        $ObjectID
    )

    docker inspect --format '{{json .}}' $ObjectID | ConvertFrom-Json

}