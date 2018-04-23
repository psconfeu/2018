
<#

Author: I. Strachan
Version: 1.0
Version History:

Purpose: Verify AD User in specified xlsx File

#>
[CmdletBinding(SupportsShouldProcess = $True)]

Param(
    $File,
    $Path,
    $WorkSheetName,
    $CustomerName,
    $customerCode
)

#region Get xlsx File
$source = Join-Path -Path $Path -ChildPath $File
if(!(Test-Path $source)){
    $(Throw "Cannot verify Source $($source)")
}
else{
    $xlsxInput = Import-Excel -Path $Source  -WorksheetName $WorkSheetName
}

$ExcludeProperty = @('CompanyPrefix','Password')
$userProperties = ($xlsxInput | Get-Member -MemberType NoteProperty).Name |
   Where-Object {!($ExcludeProperty.Contains($_))}
#endregion

#region Main
$xlsxInput |
    Foreach-Object {

    $Expected = $_

    Describe "Processing User: $($Expected.SamAccountName)" {

        Context "Verifying AD User properties" {
            #Get AD user properties
            $Actual = Get-ADUser -Identity $Expected.SamAccountName -Properties $userProperties

            ForEach( $property in $userProperties){
                if (([string]::isNullOrEmpty($Expected.$property))) {
                     $Expected.$property = $null
                     $lableExpected = '<not set>'
                }
                else{
                    $lableExpected = $Expected.$property
                }

                it "Verifying user property: $($property) / $($lableExpected)"{
                    $Actual.$property | Should -Be $Expected.$property
                }
            }
        }
    }
}
#endregion

