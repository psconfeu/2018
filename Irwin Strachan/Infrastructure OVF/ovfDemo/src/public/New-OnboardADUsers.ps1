Function New-OnboardADUsers {
    [CmdletBinding()]
    Param(
        $File,
        $Path,
        $WorkSheetName,
        $CustomerName,
        $customerCode
    )

    #region Helper functions
    function ConvertTo-ADUserHashTable {
        param(
            [PSObject]$PSObject,
            $ExcludeProperty = @('CustomerCode')
        )
        $Splat = @{}

        $PSObject |
            Get-Member -MemberType *Property |
            ForEach-Object {
            if (!$ExcludeProperty.Contains($_.Name)) {
                if ($_.Name -eq 'Password') {
                    $Splat.AccountPassword = ConvertTo-SecureString $PSObject.$($_.Name) -AsPlainText -Force
                }
                else {
                    $Splat.$($_.Name) = $PSObject.$($_.Name).Trim()
                }
            }
        }

        #Add Manadatory Name Parameter
        $Splat.Name = '{0} {1}' -f $PSObject.GivenName, $PSObject.SurName
        $Splat.DisplayName = '{0} {1}' -f $PSObject.GivenName, $PSObject.SurName
        $Splat.UserPrincipalName = ('{0}_{1}@pshirwin.local' -f $PSObject.CompanyPrefix , $PSObject.SamAccountName).ToLower()

        #Enable Account
        $Splat.Enabled = $True

        #return HashTable
        $Splat
    }
    #endregion

    #region Get xlsx File
    $source = Join-Path -Path $Path -ChildPath $File
    if (!(Test-Path $source)) {
        $(Throw "Cannot verify Source $($source)")
    }
    else {
        $xlsxInput = Import-Excel -Path $Source  -WorksheetName $WorkSheetName
    }
    #endregion

    #region Main
    $domainDN = (Get-ADDomain).DistinguishedName
    $ouCustomer = 'OU=Users,OU={0} ({1}),OU=Customers,{2}' -f $CustomerName, $CustomerCode, $domainDN

    $ouExists = Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $ouCustomer}

    If ($ouExists) {
        #Create New AD Users
        $xlsxInput |
            ForEach-Object {
            #Convert Input to HashTable for splatting
            $paramADUser = ConvertTo-ADUserHashTable -PSObject $_ -ExcludeProperty @('CompanyPrefix')

            try {
                $findUserUPN = Get-ADUser -Filter "UserPrincipalName -eq  '$($paramADUser.UserPrincipalName)'"
                $findUserSamAccountName = Get-ADUser -Filter "SamAccountName -eq  '$($paramADUser.SamAccountName)'"

                if (!($findUserUPN)) {
                    Write-Verbose -Message "UserPrincipalName $($paramADUser.UserPrincipalName) is unique"
                    if ( !($findUserSamAccountName)) {
                        Write-Verbose "SamAccountName `'$($paramADUser.SamAccountName)`' is unique"
                        Write-Verbose "Creating user $($paramADUser.UserPrincipalName)"
                        New-ADUser @paramADUser -Path $ouCustomer -PassThru
                    }
                    else {
                        Write-Warning -Message "SamAccountName $($paramADUser.SamAccountName) isn't unique"
                    }
                }
                else {
                    Write-Warning -Message "UserPrincipalName $($paramADUser.UserPrincipalName) isn't unique"
                }
            }
            Catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException] {
                Write-Warning -Message "User `'$($paramADUser.Name)`' already exists."
            }
            Catch {
                Write-Warning -Message "Something went wrong creating user `'$($paramADUser.Name)`'"
            }
        }

    }
    else {
        throw "Cannot find OU $($ouCustomer)"
    }
    #endregion
}