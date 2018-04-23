function Set-ADUsersTests {
    [CmdletBinding()]
    Param(
        $CustomerCode
    )

    $exportFolder = 'C:\exports\adusers'

    #Import failed tests
    $FailedTests =  Import-Csv -Path "$exportFolder\FailedTests-$CustomerCode.csv" -Delimiter "`t" -Encoding UTF8

    #Get Set-ADUser Parameters
    $setADUserParameters = (Get-Command Set-ADUser).ParameterSets.Parameters.Where{ $_.IsDynamic -eq $true} |
        Select-Object -ExpandProperty Name

    #Get User Property
    $FailedTests |
    Foreach-object{
        #Set Expected to null if <not set>
        $Expected = @{$true = $null; $false = $_.Expected}[$_.Expected -eq '<not set>']

        If ($setADUserParameters.Contains($_.Property)){
            Write-Verbose $('Using Set-ADUser parameter to modify: {0}' -f $_.Property)
            $paramSetADUser = @{
                Identity = $_.SamAccountName
                $_.Property = $Expected
            }
            Write-Verbose "Setting $($_.Property) to $($expected)"
            Set-ADUser @paramSetADUser
        }
        else{
            Write-Verbose $('Using LDAP DisplayName to modify: {0}' -f $_.Property)
            if($Expected){
                Write-Verbose "Setting $($_.Property) to $($expected)"
                Set-ADUser -Identity $($_.SamAccountName) -Replace @{$_.Property = $Expected}
            }
            else{
                Write-Verbose "Clearing $($_.Property)"
                Set-ADUser -Identity $($_.SamAccountName) -Clear $($_.Property)
            }
        }
    }
}
