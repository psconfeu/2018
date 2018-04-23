Function Remove-CustomerOU {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param(
        $CustomerName,
        $CustomerCode
    )

    $domainDN = (Get-ADDomain).DistinguishedName
    $ouCustomerName = 'OU={0} ({1}),OU=Customers,{2}' -f $CustomerName, $CustomerCode, $domainDN
    $ouExists = Get-ADOrganizationalUnit -Filter { DistinguishedName -like $ouCustomerName}

    If (!($ouExists)) {
        throw "OU: $ouCustomerName doesn't exist"
    }
    else{
        Get-ADOrganizationalUnit -Identity $ouCustomerName |
        Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion:$false -PassThru |
        Remove-ADObject -Recursive -Confirm:$false
    }

}