
<#

Author: ing. I.C.A. Strachan
Version: 1.0
Version History:

Purpose: Create OU Structure and default security groups for onboardinga a new Customer

#>
[CmdletBinding(SupportsShouldProcess = $True)]
param(
    $CustomerName ='Diva ONE',
    $CustomerCode = '099910'
)

#region Default Settings
$defaultOUs = @(
    'Contacts'
    'Servers'
    'Workstations'
    'Resources'
    'Groups'
    'Users'
)

$defaultGlobalGroups = @(
    ('{0} ADMINS' -f $CustomerCode)
    ('{0} NONE' -f $CustomerCode)
    ('{0} PARTIAL' -f $CustomerCode)
    ('SVCADMINS {0}' -f $CustomerCode)
    ('FS {0} FULL' -f $CustomerCode)
    ('FS {0} READ' -f $CustomerCode)
    ('FS {0} NONE' -f $CustomerCode)
    ('FS {0} LIST' -f $CustomerCode)
)

$defaultUniversalGroups = @(
    ('{0} Users' -f $CustomerCode)
)

$domainDN = (Get-ADDomain).DistinguishedName
$ouCustomerName = 'OU={0} ({1}),OU=Customers,{2}' -f $CustomerName,$CustomerCode,$domainDN
#endregion

#region OVF Main
Describe 'Customer Onboarding operational readiness' {

    Context "Verifying Customer default OU Structure for Customer $($CustomerName)"{

        $defaultOUs |
        ForEach-Object{
            $ouName = $_
            $defaultOUCustomerName = 'OU={0},{1}' -f $ouName,$ouCustomerName

            $ouExists = Get-ADOrganizationalUnit -Filter { DistinguishedName -like $defaultOUCustomerName}
            it "OU $($ouName) exists" {
               $ouExists.DistinguishedName | Should -Be $defaultOUCustomerName
            }
        }
    }

    Context "Verifying Customer default global security groups for Customer $($CustomerName) exists"{
        $defaultGlobalGroups |
        ForEach-Object{
            $groupName = $_
            $distinguishedNameGroup = 'CN={0},{1}' -f $groupName,$ouCustomerName

            $groupExists = Get-ADGroup -f {DistinguishedName -like $distinguishedNameGroup}

            it "Security group `'$($groupName)`' exists" {
                $groupExists.DistinguishedName |
                Should -Be $distinguishedNameGroup
            }
            it "Security group `'$($groupName)`' scope is Global" {
                $groupExists.GroupScope |
                Should -Be 'Global'
            }
        }
    }

    Context "Verifying Customer default universal security groups for Customer $($CustomerName) exists"{
        $defaultUniversalGroups |
        ForEach-Object{
            $groupName = $_

            $distinguishedNameGroup = 'CN={0},{1}' -f $groupName,$ouCustomerName

            $groupExists = Get-ADGroup -f {DistinguishedName -like $distinguishedNameGroup}

            it "Security group `'$($groupName)`' exists" {
                $groupExists.DistinguishedName |
                Should -Be $distinguishedNameGroup
            }
            it "Security group `'$($groupName)`' scope is Universal" {
                $groupExists.GroupScope |
                Should -Be 'Universal'
            }
        }
    }
}
#endregion

#region Get current Group memberships
$defaultSecurityGroupsMembers = @{}

$defaultSecurityGroups = @(
    'Proxy ADMINS'
    'Proxy NONE'
    'Proxy PARTIAL'
    'SERVICEADMINS Proxy'
    'Proxy Users'
    'FS FULL'
    'FS NONE'
    'FS READ'
    'FS LIST'
)

$defaultSecurityGroups |
ForEach-Object{
   $defaultSecurityGroupsMembers.$($_) = Get-ADGroupMember -Identity $_ | Select-Object -ExpandProperty SamAccountName
}
#endregion

Function Get-ADGroupMembershipToParentGroup{
    [CmdletBinding()]
    param(
        $defaultGroupMembers,
        $GroupMember,
        $CustomerCode
    )

    process {
        $result = @{}
        foreach ($member in $GroupMember) {
            switch -Wildcard ($member) {
                "$($CustomerCode)*ADMINS"{
                    $result.'PROXY ADMINS' = "{0}, {1}" -f $member, $defaultGroupMembers.$('PROXY ADMINS').contains($member)
                }
                "$($CustomerCode)*NONE"{
                    $result.'PROXY NONE' = "{0}, {1}" -f $member, $defaultGroupMembers.$('PROXY NONE').contains($member)
                }
                "$($CustomerCode)*PARTIAL"{
                    $result.'PROXY PARTIAL' = "{0}, {1}" -f $member, $defaultGroupMembers.$('PROXY PARTIAL').contains($member)
                }
                "$($CustomerCode)*Users"{
                    $result.'PROXY Users' = "{0}, {1}" -f $member, $defaultGroupMembers.$('PROXY Users').contains($member)
                }
                "SVCADMINS*$($CustomerCode)"{
                    $result.'SERVICEADMINS Proxy' = "{0}, {1}" -f $member, $defaultGroupMembers.$('SERVICEADMINS Proxy').contains($member)
                }
                'FS*FULL'{
                    $result.'FS FULL' = "{0}, {1}" -f $member, $defaultGroupMembers.$('FS FULL').contains($member)
                }
                'FS*NONE'{
                    $result.'FS NONE' = "{0}, {1}" -f $member, $defaultGroupMembers.$('FS NONE').contains($member)
                }
                'FS*READ'{
                    $result.'FS READ' = "{0}, {1}" -f $member, $defaultGroupMembers.$('FS READ').contains($member)
                }
                'FS*LIST'{
                    $result.'FS LIST' = "{0}, {1}" -f $member, $defaultGroupMembers.$('FS LIST').contains($member)
                }
            }
        }
        $result
    }
}
#endregion

#region OVF Security group membership
$globalSecurityGroupMembership = Get-ADGroupMembershipToParentGroup -GroupMember $defaultGlobalGroups -defaultGroupMembers $defaultSecurityGroupsMembers -CustomerCode $CustomerCode

Describe "Default global security group membership"{
    $globalSecurityGroupMembership.Keys |
    ForEach-Object{
        $parentGroup = $_
        $arrGroupMembership = $globalSecurityGroupMembership[$_] -split ','
        $group = $arrGroupMembership[0]
        $isMember = $arrGroupMembership[1].Trim()

        It "$group is member of $parentGroup is $isMember" {
            [System.Convert]::ToBoolean($isMember)  | should be $true
        }
    }
}

$universalSecurityGroupMembership = Get-ADGroupMembershipToParentGroup -GroupMember $defaultUniversalGroups -defaultGroupMembers $defaultSecurityGroupsMembers -CustomerCode $CustomerCode

Describe "Default universal security group membership"{
    $universalSecurityGroupMembership.Keys |
    ForEach-Object{
        $parentGroup = $_
        $arrGroupMembership = $universalSecurityGroupMembership[$_] -split ','
        $group = $arrGroupMembership[0]
        $isMember = $arrGroupMembership[1].Trim()

        It "$group is member of $parentGroup is $isMember" {
            [System.Convert]::ToBoolean($isMember)  | should be $true
        }
    }
}
#endregion