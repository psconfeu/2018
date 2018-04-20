function Get-FSMORole {
<#
.SYNOPSIS
Retrieves the FSMO role holders from one or more Active Directory domains and forests.
.DESCRIPTION
Get-FSMORole uses the Get-ADDomain and Get-ADForest Active Directory cmdlets to determine
which domain controller currently holds each of the Active Directory FSMO roles.
.PARAMETER DomainName
One or more Active Directory domain names.
.EXAMPLE
Get-Content domainnames.txt | Get-FSMORole
.EXAMPLE
Get-FSMORole -DomainName domain1, domain2
#>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        [string[]]$DomainName = $env:USERDOMAIN
    )
    BEGIN {
        Import-Module ActiveDirectory -Cmdlet Get-ADDomain, Get-ADForest -ErrorAction SilentlyContinue
    }
    PROCESS {
        foreach ($domain in $DomainName) {
            Write-Verbose "Querying $domain"
            Try {
            $problem = $false
            $addomain = Get-ADDomain -Identity $domain -ErrorAction Stop
            } Catch { $problem = $true
            Write-Warning $_.Exception.Message
            }
            if (-not $problem) {
                $adforest = Get-ADForest -Identity (($addomain).forest)

                New-Object PSObject -Property @{
                    InfrastructureMaster = $addomain.InfrastructureMaster
                    PDCEmulator = $addomain.PDCEmulator
                    RIDMaster = $addomain.RIDMaster
                    DomainNamingMaster = $adforest.DomainNamingMaster
                    SchemaMaster = $adforest.SchemaMaster
                }
            }
        }
    }
}
