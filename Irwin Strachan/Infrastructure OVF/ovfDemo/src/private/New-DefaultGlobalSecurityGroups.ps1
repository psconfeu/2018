Function New-DefaultGlobalSecurityGroups{

    [CmdletBinding(SupportsShouldProcess = $True)]
    param(
        $CustomerName,
        $CustomerCode
    )

    $domainDN = (Get-ADDomain).DistinguishedName
    $ouCustomerName = 'OU={0} ({1}),OU=Customers,{2}' -f $CustomerName, $CustomerCode, $domainDN
    $ouExists = Get-ADOrganizationalUnit -Filter { DistinguishedName -like $ouCustomerName}

    If ($ouExists) {

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

        $defaultGlobalGroups |
        ForEach-Object {
            $groupName = $_
            $distinguishedNameGroup = 'CN={0},{1}' -f $groupName, $ouCustomerName

            $groupExists = Get-ADGroup -f {DistinguishedName -like $distinguishedNameGroup}

            If ($groupExists) {
                Write-Verbose $('{0} exists' -f $distinguishedNameGroup)
            }
            else {
                Write-Verbose $("{0} doesn`'t exists. Creating group" -f $distinguishedNameGroup)
                $paramGlobalGroup = @{
                    Name          = $groupName
                    Path          = $ouCustomerName
                    Description   = $groupName
                    GroupScope    = 'Global'
                    GroupCategory = 'Security'
                }

                New-ADGroup @paramGlobalGroup
            }
        }

        #Add member to default groups
        $defaultGlobalGroups | Add-MemberToParentGroup -CustomerCode $CustomerCode
        $defaultGlobalGroups | Add-MemberToParentFSGroup
    }
    else {
        throw "Aborting creation of default global security groups"
    }
}