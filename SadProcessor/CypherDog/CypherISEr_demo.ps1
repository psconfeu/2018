Write-Warning "Not a Script.... Don't <F5> me...";Break
##############################################################
######## Demo BloodHound/CypherISEr - PSConfEU 2018 ##########

# CypherISEr Source
start-process "https://github.com/SadProcessor/SomeStuff/blob/master/Invoke-CypherISEr.ps1"

# More Cypher
start-process "https://github.com/SadProcessor/Cheats/blob/master/DogWhispererV2.md"


##############################################################

### Node
$Query = "MATCH (U:User {name: 'ACHAVARIN@EXTERNAL.LOCAL'}) RETURN U"
CypherISER $Query -Expand data,data
 
# Members Of group - direct
$Group = 'CONTRACTINGH@INTERNAL.LOCAL'
$Query = "MATCH (U:User)-[r:MemberOf]->(G:Group {name: '$Group'}) RETURN U"
CypherISER $Query -Expand data,data

# Members of Group - indirect
$Degree = 1
$Query = "MATCH p=shortestPath((U:User)-[r:MemberOf*1..$Degree]->(G:Group {name: '$Group'})) RETURN U"
CypherISER $Query -Expand data,data

$Degree = 3
$Query = "MATCH p=shortestPath((U:User)-[r:MemberOf*1..$Degree]->(G:Group {name: '$Group'})) RETURN U"
CypherISER $Query -Expand data,data

$Degree = 6
$Query = "MATCH p=shortestPath((U:User)-[r:MemberOf*1..$Degree]->(G:Group {name: '$Group'})) RETURN U"
CypherISER $Query -Expand data,data
CypherISER $Query -Expand data,data | measure




# Script - 6 Degrees of Group Membership...
## Prep stuff
$Group  = 'CONTRACTINGH@INTERNAL.LOCAL'
$Output = @()
## Loop 6 Degrees
$Output = foreach($Degree in 1..6){
    # Prep Query
    $Query    = "MATCH p=shortestPath((U:User)-[r:MemberOf*1..$Degree]->(G:Group {name: '$Group'})) RETURN U"
    # Get Result
    $Members  = CypherISER $Query -Expand data,data
    # Add to Output
    New-Object PSCustomObject -Prop @{
        Group      = [string]$Group
        Degree     = [int]$Degree
        MemberList = [Array]$Members.Name
        Count      = [int]$Members.Count
        }}
## Return Output
Return $Output | Select Degree,Count,MemberList





#### Script to Function 


# Advanced Function - 6 Degrees of Group Membership...
<#HelpPageStuff#>
function Get-SixDegreesOfGroupMembership{
    [CmdletBinding()]
    [Alias('SixDegree')]
    Param(
        [Parameter(Mandatory=1,ValueFromPipelineByPropertyName=1)][Alias('Name')][String]$Group
        )
    ## PREP
    Begin{$Output = @()}
    ## LOOP/PIPELINE
    Process{
        foreach($Degree in 1..6){
            # Prep Query
            $Query    = "MATCH p=shortestPath((U:User)-[r:MemberOf*1..$Degree]->(G:Group {name: '$Group'})) RETURN U"
            # Get Result
            $Members  = CypherISER $Query -Expand data,data
            # Add to Output
            $Output  += New-Object PSCustomObject -Prop @{
                Group      = [string]$Group
                Degree     = [int]$Degree
                MemberList = [Array]$Members.Name
                Count      = [int]$Members.length
                }}}
    ## OUTPUT
    End{Return $Output | Select Group,Degree,Count,MemberList}
    }
#End

# PowerShell...
$Data = CypherISEr "MATCH (G:Group) RETURN G" -Expand Data,Data | SixDegree | Group-object -Property Group


$Data
$Data | ? name -eq HELPDESK@INTERNAL.LOCAL 
$Data | ? name -eq HELPDESK@INTERNAL.LOCAL | Select -Expand Group
$Data | ? name -eq HELPDESK@INTERNAL.LOCAL | Select -Expand Group | ? Degree -eq 4
$Data | ? name -eq HELPDESK@INTERNAL.LOCAL | Select -Expand Group | ? Degree -eq 4 | Select -Expand MemberList


########################### Metrics (Show me the Data...)

## "How to Build Adversary Resilience into your Active Directory Environment" by @_wald0
##  https://www.brighttalk.com/webcast/15713/301931  <---- /!\ BlueTeam: This is HOT /!\

# Top5 Users with most adminTo (Group Delegated)
$Query1 = "
MATCH 
(U:User)-[r:MemberOf|:AdminTo*1..]->(C:Computer)
WITH
U.name as n,
COUNT(DISTINCT(C)) as c 
RETURN {Name: n, Count: c} as SingleColumn
ORDER BY c DESC
LIMIT 5
"

CypherISEr $Query1


## Top 10 Users with most Sessions
$Query2 = "
MATCH 
(U:User)<-[r:HasSession*1..]-(C:Computer)
WITH
U.name as n,
COUNT(DISTINCT(C)) as c 
RETURN {Name: n, Count: c} as SingleColumn
ORDER BY c DESC
LIMIT 5
"

CypherISEr $Query2


## BONUS - ISE
CypherISEr 113,120 <#from CmdLine...#> 
<#+show F12#>


#######################################################

## FineTune/Debug Query - Explain/Profile 

CypherISEr $Query2 -Explain
CypherISEr $Query2 -Profile | fl



############################################### Back to Slides...



