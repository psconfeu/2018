#Function Get-DockerImage {

#    docker image ls --format '{{json .}}' | ConvertFrom-Json

#}

function Get-DockerImage {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch] $All
    )

    if ($All) {
        $images = docker images -a --format '{{json .}}' | ConvertFrom-Json
    }
    else {
        $images = docker images --format '{{json .}}' | ConvertFrom-Json
    }

    foreach ($image in $images) {
        $dtArray = ($image.CreatedAt -replace '[-:]',' ').Split(' ')
        $createdAt = [DateTime]::new(
            $dtArray[0],
            $dtArray[1],
            $dtArray[2],
            $dtArray[3],
            $dtArray[4],
            $dtArray[5],
            [System.DateTimeKind]::Local
        )
        $outputObject = [PSCustomObject] @{
            Containers = $image.Containers
            CreatedAt = $createdAt
            CreatedSince = $image.CreatedSince
            Digest = $image.Digest
            ID = $image.ID
            Repository = $image.Repository
            SharedSize = $image.SharedSize
            Size = $image.Size
            Tag = $image.Tag
            UniqueSize = $image.UniqueSize
            VirtualSize = $image.VirtualSize
        }
        $outputObject.pstypenames.insert(0,'docker.image')
        Write-Output $outputObject
    }
}