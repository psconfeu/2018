Function New-DefaultUniversalSecurityGroups {

    [CmdletBinding(SupportsShouldProcess = $True)]
    param(
        $CustomerName,
        $CustomerCode
    )

    $domainDN = (Get-ADDomain).DistinguishedName
    $ouCustomerName = 'OU={0} ({1}),OU=Customers,{2}' -f $CustomerName, $CustomerCode, $domainDN
    $ouExists = Get-ADOrganizationalUnit -Filter { DistinguishedName -like $ouCustomerName}

    If ($ouExists) {

        $defaultUniversalGroups = @(
            ('{0} Users' -f $CustomerCode)
         )

        $defaultUniversalGroups |
            ForEach-Object {
            $groupName = $_
            $distinguishedNameGroup = 'CN={0},{1}' -f $groupName, $ouCustomerName

            $groupExists = Get-ADGroup -f {DistinguishedName -like $distinguishedNameGroup}

            If ($groupExists) {
                Write-Verbose $('{0} exists' -f $distinguishedNameGroup)
            }
            else {
                Write-Verbose $("{0} doesn`'t exists. Creating group" -f $distinguishedNameGroup)
                $paramUniversalGroup = @{
                    Name          = $groupName
                    Path          = $ouCustomerName
                    Description   = $groupName
                    GroupScope    = 'Universal'
                    GroupCategory = 'Security'
                }

                New-ADGroup @paramUniversalGroup
            }
        }

        #Add member to default group
        $defaultUniversalGroups | Add-MemberToParentGroup
    }
    else {
            throw "Aborting creation of default universal security groups"
    }
}