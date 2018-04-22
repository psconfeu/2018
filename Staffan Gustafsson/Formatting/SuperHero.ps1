
class SuperHero {
    [string] $Name
    [string] $AlterEgo
    [string] $PlaceOfBirth
    [string] $Gender
    [int]    $Height
    [int]    $Weight
    [NameDesc[]] $Power
    [NameDesc[]] $Ability
    [NameDesc[]] $Weakness
}

class NameDesc {
    [string] $Name
    [string] $Description
}

function Import-Hero {
    [Alias("iph")]
    [CmdletBinding()]
    [OutputType("SuperHero")]
    param()
    [SuperHero[]] (Get-Content -Raw $PSScriptRoot\Heroes.json | ConvertFrom-Json)
}
