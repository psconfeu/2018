Function Export-CustomerADObjects {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param(
        $exportDate = $(Get-Date -Format ddMMyyyy),
        $CustomerCode,
        $CustomerName
    )

    $domainDN = (Get-ADDomain).DistinguishedName
    $ouCustomerName = 'OU={0} ({1}),OU=Customers,{2}' -f $CustomerName, $CustomerCode, $domainDN
    $ouExists = Get-ADOrganizationalUnit -Filter { DistinguishedName -like $ouCustomerName}
    $exportFolder = 'C:\exports\offboard'

    If (!($ouExists)) {
        throw "OU: $ouCustomerName doesn't exist"
    }
    $xmlFile = "$exportFolder\Offboard - $CustomerCode - DSAObjects - $exportDate.xml"
    Write-Verbose "xmlFile: $xmlFile"
    $DSAObjects = @{}

    #region 1 export AD Objects to XML file

    #region 1.1 Get ADUser objects

    $paramADUser = @{
        Properties = '*'
        LDAPFilter = '(objectClass=user)'
        SearchBase = $ouCustomerName
    }

    Write-Verbose "Exporting Users"
    $DSAObjects.Users = Get-ADUser @paramADUser  |
        Foreach-Object {
        [PSCustomObject]@{
            SamAccountName    = $_.SamAccountName
            DistinguishedName = $_.DistinguishedName
            CanonicalName     = $_.CanonicalName
            Enabled           = $_.Enabled
            GivenName         = $_.GivenName
            Initials          = $_.Initials
            SurName           = $_.SurName
            EmailAddress      = $_.EmailAddress
            Description       = $_.Description
            Displayname       = $_.DisplayName
            OfficePhone       = $_.OfficePhone
            MobilePhone       = $_.MobilePhone
            Department        = $_.Department
            LastLogonDate     = $_.LastLogonDate
            AccountExpiresOn  = $_.accountExpirationDate
            ObjectGUID        = $_.ObjectGUID
            ObjectClass       = $_.ObjectClass
            Changed           = $_.whenChanged
            Created           = $_.whenCreated
            CreatedDate       = Get-Date (Get-Date $_.whenCreated).Date -format yyyyMMdd
        }
    }
    #endregion

    #region 1.2 Get ADGroup objects
    $propertiesADGroup = @(
        'Member'
        'MemberOf'
        'whenChanged'
        'whenCreated'
    )

    $paramADGroup = @{
        Properties = $propertiesADGroup
        LDAPFilter = '(objectClass=group)'
        SearchBase = $ouCustomerName
    }

    Write-Verbose "Exporting Groups"
    $DSAObjects.Groups = Get-ADGroup @paramADGroup  |
        Foreach-Object {
        [PSCustomObject]@{
            DistinguishedName = $_.DistinguishedName
            SamAccountName    = $_.SamAccountName
            Name              = $_.Name
            ObjectGUID        = $_.ObjectGUID
            ObjectClass       = $_.ObjectClass
            Changed           = $_.whenChanged
            Created           = $_.whenCreated
            Member            = $_.Member
            MemberOf          = $_.MemberOf
        }
    }
    #endregion

    #region 1.3 Get DFSn Link & Target
    Write-Verbose "Exporting DFSn ADObjects"
    $DSAObjects.DFSn = Get-DfsnRoot -ErrorAction SilentlyContinue |
        Where-Object {$_.Path -like '*GroupData'}|
        foreach-object {
        Get-DfsnFolder "$($_.Path)\*" |
            Where-Object {$_.Path -like "*$CustomerCode"} |
            Get-DfsnFolderTarget
    }
    #endregion

    #region 1.4 Get AD Organizational unit objects
    Write-Verbose "Exporting OUs"
    $DSAObjects.OUs = Get-ADOrganizationalUnit -SearchBase $ouCustomerName -Filter *
    #endregion

    #region 1.5 Export DSAObject to XML File
    Write-Verbose "Exporting AD Objects to $($xmlfile)"
    $DSAObjects |
        Export-Clixml -Path $xmlFile -Encoding UTF8
    #endregion

    #endregion
}