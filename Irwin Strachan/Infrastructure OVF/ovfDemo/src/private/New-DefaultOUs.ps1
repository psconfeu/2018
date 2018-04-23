Function New-DefaultOUs{
    [CmdletBinding(SupportsShouldProcess = $True)]
    param(
        $CustomerName,
        $CustomerCode
    )

    #Default OU Structure
    $defaultOUs = @(
        'Contacts'
        'Servers'
        'Workstations'
        'Resources'
        'Groups'
        'Users'
    )

    $domainDN = (Get-ADDomain).DistinguishedName
    $ouCustomerName = 'OU={0} ({1}),OU=Customers,{2}' -f $CustomerName, $CustomerCode, $domainDN

    #region 1.2 Creating default OUs
    $defaultOUs |
    ForEach-Object {
        $ouName = $_
        $defaultOUCustomerName = 'OU={0},{1}' -f $ouName, $ouCustomerName
        $defaultOUExists = Get-ADOrganizationalUnit -Filter { DistinguishedName -like $defaultOUCustomerName}

        If ($defaultOUExists) {
            Write-verbose $('{0} exists' -f $defaultOUCustomerName)
        }
        else {
            Write-Verbose $("{0} doesn`'t exists. Creating OU" -f $defaultOUCustomerName)
            $paramDefaultOU = @{
                Name                            = $ouName
                Path                            = $ouCustomerName
                Description                     = $ouName
                ProtectedFromAccidentalDeletion = $false
            }

            New-ADOrganizationalUnit @paramDefaultOU
        }
    }
    #endregion
}