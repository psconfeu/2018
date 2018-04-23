Write-Warning "Not a Script.... Don't <F5> me...";Break
########### PSConfEU2018 - BloodHound/PowerShell #########

# CypherDog Source
start-process https://github.com/SadProcessor/SomeStuff/blob/master/CypherDog14.ps1

# More Info Bloodhound
start-process https://github.com/BloodHoundAD/BloodHound/wiki
# + Refs @ end of Slides


##########################################################
#region ######################################## CypherDog


# Cmdlets/Help
BloodHound

### Nodes

# All nodes
Node

# All Users
Node -User
# All Computers
Node -Computer
# All Groups
Node -Group

# Specifc node
Node -User ACHAVARIN@EXTERNAL.LOCAL
Node -Computer ZEUS.EXTERNAL.LOCAL

# Search
NodeSearch -user acha
NodeSearch -User ^a
NodeSearch -Computer secret
NodeSearch -group Admin



### Edges

# AdminTo
Edge -AdminToComputer ZEUS.EXTERNAL.LOCAL -Return Groups
# AdminBy (reverse edge)
EdgeReverse -AdminByGroup AUDIT_A@EXTERNAL.LOCAL -Return Computers

# Diff in Cypher
Edge -AdminToComputer ZEUS.EXTERNAL.LOCAL -Return Groups -Cypher
EdgeR -AdminByGroup AUDIT_A@EXTERNAL.LOCAL -Return Computers -Cypher

# Member of group 
# direct
Edge -MemberOfGroup CONTRACTINGF@INTERNAL.LOCAL -Return Users

# nested
Edge -MemberOfGroup CONTRACTINGF@INTERNAL.LOCAL -Return Users -Degree 3
Edge -MemberOfGroup CONTRACTINGF@INTERNAL.LOCAL -Return Users -Degree 3 | measure
Edge -MemberOfGroup CONTRACTINGF@INTERNAL.LOCAL -Return Users -Degree * | measure
Edge -MemberOfGroup CONTRACTINGF@INTERNAL.LOCAL -Return Users -Degree * -Cypher

## Pipeline is awesome!!

# List all Computers with session from any Users AdminTo specified target Computer
Edge -AdminToComputer NYX.EXTERNAL.LOCAL -Return Groups | 
Edge -MemberOfGroup -Return Users -Degree * |
Edge -SessionFromUser -Return Computers

# List all Users admin to Computers where specified User has a Session
Edge -SessionFromUser BREYES.ADMIN@INTERNAL.LOCAL -Return Computers -verbose|
Edge -AdminToComputer -Return Groups -verbose|
Edge -MemberOfGroup -Return Users -Degree * -verbose




### Paths

Bloodhound-Path -UserToGroup -from ACHAVARIN@EXTERNAL.LOCAL -to 'DOMAIN ADMINS@EXTERNAL.LOCAL' | Format-Table

# With|Without ACL Edges
Path -UserToGroup ACHAVARIN@EXTERNAL.LOCAL -to 'DOMAIN ADMINS@INTERNAL.LOCAL' | ft
Path -UserToGroup ACHAVARIN@EXTERNAL.LOCAL -to 'DOMAIN ADMINS@INTERNAL.LOCAL' -NoACL | ft

# Cypher to clipboard
Path -UTG ACHAVARIN@EXTERNAL.LOCAL -to 'DOMAIN ADMINS@INTERNAL.LOCAL' -NoACL -Cypher

# Path via
PathVia -UserToGroup -ViaUser -From ACHAVARIN@EXTERNAL.LOCAL -To 'DOMAIN ADMINS@EXTERNAL.LOCAL' -ViaName AMEADORS@EXTERNAL.LOCAL
PathVia -UserToGroup -ViaUser -From ACHAVARIN@EXTERNAL.LOCAL -To 'DOMAIN ADMINS@EXTERNAL.LOCAL' -ViaName AMEADORS@EXTERNAL.LOCAL -NoACL





############# Questions so far ?? - Stuff want to see in code ?? ####################




### Manipulating DB <---------- Really Cool!! Do what you like...

### Create Node
Node -User bob
NodeCreate -User bob -Verbose
Node -User bob

# Add Props to Node
NodeUpdate -User bob -Properties @{age=23; eyes='green'; hair='black'; city='honolulu'} -verbose
Node -User bob

# Clear/Remove prop (/!\ not same as set value to $Null)
NodeUpdate -User bob -Properties @{city=''} -verbose
Node -user bob
NodeUpdate -User bob -Delete -PropertyName city
Node -User bob

# Create Node with Props
NodeCreate -user alice -Properties @{age=25;eyes='blue';hair='black'} -verbose
Node -user alice

# Search by Prop
NodeSearch -User -Property age
NodeSearch -User -Property age -Value 23
NodeSearch -User -Property age -NotExist
# /!\ Case sensitive server side filtering
NodeSearch -User -Property hair -Value Black
NodeSearch -User -Property hair -Value black
NodeSearch -User -Property hair -Value black | where EYes -eq bLUe  <# after pipe = PoSh :) #>



# Cool Combos...
NodeSearch -User -Property age -verbose | NodeUpdate -User -Delete -PropertyName hair -Verbose
NodeSearch -User -Property age

# Create Edge
EdgeCreate -UserToUser -CustomEdge likes -From bob -to alice -verbose
EdgeCreate -UserToUser -CustomEdge likes -From alice -to bob -verbose
#
Path -UserToUser -From bob -To alice
Path -UserToUser -From alice -To bob

# Delete Edge
EdgeDelete -UserToUser -CustomEdge likes -From alice -to bob -verbose
# Check Paths
Path -UserToUser -From bob -To alice
Path -UserToUser -From alice -To bob
# Show in UI
Path -UserToUser -From bob -To alice -Cypher

# Delete Nodes by name
NodeDelete -user alice
# Multiple over pipeline
'alice','bob'| NodeDelete -user -Verbose

# delete by prop value
NodeSearch -user -Property age -Value 23 | NodeDelete -user -verbose


## BloodHound example usage

# Add blacklist prop to all computer nodes
Node -Computer | NodeUpdate -Computer -Properties @{blacklist=$false}
Node -Computer
# Blacklist some nodes
NodeSearch -Computer ^system | NodeUpdate -Computer -Properties @{blacklist='True'}
Node -Computer
NodeSearch -Computer -Property blacklist -value True
Node -Computer | where Blacklist -eq $true
# Remove prop from nodes
Node -Computer | NodeUpdate -Computer -Delete -PropertyName blacklist
Node -Computer

# Add a domain property to all users
node -user | %{NodeUpdate -User $_.name -Properties @{domain=$_.name.split('@')[1]}}
Node -User
# Remove
#node -user | NodeUpdate -User -Delete -PropertyName domain -verbose
#Node -User





### Extras <-------------- /!\ Experimental/WorkInProgress

## Path Query Builder

$Q1 = cypher -UserToUser -From ACHAVARIN@EXTERNAL.LOCAL -to BREYES@INTERNAL.LOCAL -PathType AllShortest -Edges AdminTo,HasSession,MemberOf -MaxHop 12
# Paste in UI
$Q2 = cypher -UserToUser -From ACHAVARIN@EXTERNAL.LOCAL -to BREYNOLDS@EXTERNAL.LOCAL -PathType All -Edges AdminTo,HasSession,MemberOf -MaxHop 7
# Paste in UI
Cypher -Union -QueryA $Q1 -QueryB $Q2
# Paste in UI


## Wald0Index <---------- Check Wald0's Talk/Posts on AD resilience
Cypher -Wald0Index 'DOMAIN ADMINS@EXTERNAL.LOCAL' -verbose

Nodesearch -group "Contracting" | %{Cypher -Wald0Index $_.name} | ft

Nodesearch -group "Contracting" | %{Cypher -Wald0Index $_.name} | sort AvgPathLength| ft
#endregion ###############################################

##########################################################
###################################################### EOF