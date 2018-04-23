Function Set-ACEParentOU {

    [CmdletBinding(SupportsShouldProcess = $True)]
    param(
        $CustomerName,
        $CustomerCode
    )

    $domainDN = (Get-ADDomain).DistinguishedName
    $domainNetBiosName = (Get-ADDomain).NetBIOSName
    $ouCustomerName = 'OU={0} ({1}),OU=Customers,{2}' -f $CustomerName, $CustomerCode, $domainDN
    $ouExists = Get-ADOrganizationalUnit -Filter { DistinguishedName -like $ouCustomerName}

    If ($ouExists) {

    $ProxyUsersACE = ('{0}\{1} Users:GR' -f $domainNetBiosName, $CustomerCode)
    $null = dsacls $($ouCustomerName) /G $($ProxyUsersACE) /I:T
    #endregion

    #region Disable & Copy Inheritance from Parent OU
    $ContainerPath = "AD:\$ouCustomerName"

    # Get the Current ACL
    $aclContainerPath = Get-Acl -Path $ContainerPath
    $aclContainerPath.SetAccessRuleProtection($True, $True)
    Set-Acl -Path $ContainerPath -AclObject $aclContainerPath
    }
    else{
        throw "$($ouCustomerName) doesn't exist"
    }

}
