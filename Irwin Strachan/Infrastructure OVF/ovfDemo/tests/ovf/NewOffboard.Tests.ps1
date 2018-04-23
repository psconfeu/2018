
<#

Author: ing. I.C.A. Strachan
Version: 1.0
Version History:

Purpose: Verify that OU Structure and default security groups for offboarding a Customer

#>
[CmdletBinding(SupportsShouldProcess = $True)]
param(
  $CustomerName,
  $CustomerCode,
  $exportDate = $(Get-Date -Format ddMMyyyy),
  $processedDate = (Get-Date).ToShortDateString()
)

#region Import Customer ADObjects that were saved before deletion
$exportFolder = 'C:\exports\offboard'
$OffBoardADObjects = Import-Clixml "$exportFolder\Offboard - $CustomerCode - DSAObjects - $exportDate.xml"

$ouCustomer = '{0} ({1})' -f $CustomerName, $CustomerCode
#endregion

#region Get Deleted objects that have just been processed
$paramADObject = @{
    Filter = 'isDeleted -eq $true -and name -ne "Deleted Objects"'
    includeDeletedObjects = $True
    Properties = @(
        'Name'
        'WhenChanged'
        'ObjectClass'
        'IsDeleted'
    )
}

$DeletedADObjects = Get-ADObject @paramADObject |
Where-Object{
    $_.WhenChanged.ToShortDateString() -match $processedDate
} |
ForEach-Object{
    $arrName = $_.Name -split "`n"
    $LookupKey = $arrName[0]
    $ObjectGUID = ($arrName[-1] -split ':')[-1]

    [PSCustomObject]@{
        Key = $LookupKey
        Deleted = $_.Deleted
        IsDeleted = $_.IsDeleted
        ObjectClass = $_.ObjectClass
        ObjectGUID = ([GUID]$ObjectGUID).Guid
        Name = $_.Name
        WhenChanged = $_.WhenChanged
    }
}

#region Verify that Deleted ADObjects have been found on $processedDate
if(!($DeletedADObjects.Key.Contains($ouCustomer.Trim()))){
    throw "Didn't find the OU AD objects `'$($ouCustomer)`' deleted on $($processedDate)"
}
#endregion

$LookupDeletedObjects = $DeletedADObjects | Group-Object -AsHashTable -AsString -Property ObjectGUID
$LookupOffboardingObjectsOUs = $OffBoardADObjects.OUs | Group-Object -AsHashTable -AsString -Property ObjectGUID
$LookupOffboardingObjectsGroups = $OffBoardADObjects.Groups | Group-Object -AsHashTable -AsString -Property ObjectGUID
$LookupOffboardingObjectsUsers = $OffBoardADObjects.Users | Group-Object -AsHashTable -AsString -Property ObjectGUID
#endregion

#region OVF Main
Describe 'Customer Offboarding operational readiness' {
    Context "Verifying organizational units for `'$CustomerName`' have been deleted" {
        $LookupOffboardingObjectsOUs.Keys |
        ForEach-Object{
            $key = $_
            Context "OU `'$($LookupOffboardingObjectsOUs.$key.Name)`' has been deleted"{

                it "Objectclass is organizational unit"{
                    $LookupDeletedObjects.$key.ObjectClass |
                    Should -Be $LookupOffboardingObjectsOUs.$key.ObjectClass
                }

                it "ObjectGUID is equal to $($LookupOffboardingObjectsOUs.$key.ObjectGUID)" {
                    $LookupDeletedObjects.$key.ObjectGUID |
                    Should -Be $LookupOffboardingObjectsOUs.$key.objectGUID
                }

                it "OU has been deleted"{
                    $LookupDeletedObjects.$key.IsDeleted |
                    Should -Be $True
                }

                it "Was deleted on $processedDate" {
                    $LookupDeletedObjects.$key.WhenChanged.ToShortDateString() -match $processedDate |
                    Should -Be $True
                }
            }
        }
    }

    Context "Verifying security groups for `'$CustomerName`' have been deleted" {
        $LookupOffboardingObjectsGroups.Keys |
        ForEach-Object{
            $key = $_
            Context "Security group `'$($LookupOffboardingObjectsGroups.$key.Name)`' has been deleted"{

                it "Objectclass is group"{
                    $LookupDeletedObjects.$key.ObjectClass |
                    Should -Be $LookupOffboardingObjectsGroups.$key.ObjectClass
                }

                it "ObjectGUID is equal to $($LookupOffboardingObjectsGroups.$key.ObjectGUID)" {
                    $LookupDeletedObjects.$key.ObjectGUID |
                    Should -Be $LookupOffboardingObjectsGroups.$key.objectGUID
                }

                it "Security group has been deleted"{
                    $LookupDeletedObjects.$key.IsDeleted |
                    Should -Be $True
                }

                it "Was deleted on $processedDate" {
                    $LookupDeletedObjects.$key.WhenChanged.ToShortDateString() -match $processedDate |
                    Should -Be $True
                }
            }
        }
    }

    if ($LookupOffboardingObjectsUsers.Keys) {
        Context "Verifying users for `'$CustomerName`' have been deleted" {

            $LookupOffboardingObjectsUsers.Keys |
                ForEach-Object {
                $key = $_
                Context "User `'$($LookupOffboardingObjectsUsers.$key.DisplayName)`' has been deleted" {

                    it "Objectclass is user" {
                        $LookupDeletedObjects.$key.ObjectClass |
                            Should -Be $LookupOffboardingObjectsUsers.$key.ObjectClass
                    }

                    it "User ObjectGUID is equal to $($LookupOffboardingObjectsUsers.$key.ObjectGUID)" {
                        $LookupDeletedObjects.$key.ObjectGUID |
                            Should -Be $LookupOffboardingObjectsUsers.$key.objectGUID
                    }

                    it "User has been deleted" {
                        $LookupDeletedObjects.$key.IsDeleted |
                            Should -Be $True
                    }

                    it "User was deleted on $processedDate" {
                        $LookupDeletedObjects.$key.WhenChanged.ToShortDateString() -match $processedDate |
                            Should -Be $True
                    }
                }
            }
        }
    }
}