#region Get-LargestNumbers functions

#Function Limited to INT32
function Get-LargestNumber ([int32[]]$targetArray) {
    $max = $targetArray[0]

    for ($i = 1; $i -lt $targetArray.count; $i++) {
        if ($targetArray[$i] -gt $max) {
            $max = $targetArray[$i]
        }
    }

    $max
}

#Function Limited to INT64
function Get-LargestNumberRefactored ([int64[]]$targetArray) {
    $max = $targetArray[0]

    for ($i = 1; $i -lt $targetArray.count; $i++) {
        if ($targetArray[$i] -gt $max) {
            $max = $targetArray[$i]
        }
    }

    $max
}
#endregion

#region Testcases for Get-LargestNumber

#Default Test
$testCasesLargestNumber = @(
    @{
        Set      = @(5, 4, 3, 2)
        Expected = 5
    }
    @{
        Set      = @(2, 5, 4, 3)
        Expected = 5
    }
    @{
        Set      = @(-5, -2, -4, -3)
        Expected = -2
    }
    @{
        Set      = @(-5, -2, -4, -1)
        Expected = -1
    }
    @{
        Set      = @(-1, -2, -8, -5)
        Expected = -1
    }
    @{
        Set      = @(100000, 243, -8, 2147483647) # [int32]::MaxValue
        Expected = 2147483647
    }
)

#Test with overflow error. On of the testcase has an entry > [INT32]::MaxValue
$testCasesLargestNumberOverflow = @(
    @{
        Set      = @(5, 4, 3, 2)
        Expected = 5
    }
    @{
        Set      = @(2, 5, 4, 3)
        Expected = 5
    }
    @{
        Set      = @(-5, -2, -4, -3)
        Expected = -2
    }
    @{
        Set      = @(-5, -2, -4, -1)
        Expected = -1
    }
    @{
        Set      = @(-1, -2, -8, -5)
        Expected = -1
    }
    @{
        Set      = @(100000, 243, -8, 2147483647) #[int32]::MaxValue
        Expected = 2147483647
    }
    @{
        Set      = @(100657, 249903, -8987, 2147483648) #[int32]::MaxValue + 1
        Expected = 2147483648
    }
)
#endregion

#region Refactor tests

#Default test
Describe "Test function Get-LargestNumber" {

    It "Given the set <set> Should Return <expected>" -TestCases $testCasesLargestNumber {
        param($set, $expected)

        $(Get-LargestNumber $set) | should be $expected
    }
}

#This test will generate an error
Describe "Test function Get-LargestNumber" {

    It "Given the set <set> Should Return <expected>" -TestCases $testCasesLargestNumberOverflow {
        param($set, $expected)

        $(Get-LargestNumber $set) | should be $expected
    }
}

#Refactored test with testcase that generated an error
Describe "Test function Get-LargestNumberRefactored" {

    It "Given the set <set> Should Return <expected>" -TestCases $testCasesLargestNumberOverflow {
        param($set, $expected)

        $(Get-LargestNumberRefactored $set) | should be $expected
    }
}
#endregion