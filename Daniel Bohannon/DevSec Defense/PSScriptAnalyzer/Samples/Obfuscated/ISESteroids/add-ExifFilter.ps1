Function Add-exifFilter {
<#
        .Synopsis
            Adds an Exif Filter to a list of filters, or creates a new filter
        .Description
            Adds an Exif Filter to a list of filters, or creates a new filter
        .Example
            Add-exifFilter -passThru -ExifID $ExifIDKeywords -typeid 1101 -string "Ocean,Bahamas"    |      
            Adds a filter to set the keywords to Ocean; Bahamas, using the numeric type ID 
            and getting the function to convert the string to the vector type required
         .Example
            Add-exifFilter -passThru -ExifID $ExifIDTitle -typeName "vectorofbyte" -string "fish"
            Add a filter to set the Title to "fish", using the name of the type 
            and getting the function to convert the string to the vector type required
         .Example   
            Add-exifFilter -passThru -ExifID $ExifidCopyright -typeName "String" -value "© James O'Neill 2009" 
            Sets the copyright field (note this is a normal string, not a vector of bytes containing a unicode string)
         .Example      
            Add-exifFilter -passThru -ExifID $ExifIDGPSAltitude -typeName "uRational" -Numerator 123 -denominator 10
            Add a filter to set the GPS Altitude to 12.3M 
            getting the function to create the unsigned rational required
        .Parameter ExifID
            The ID of the field to be added / updated
        .Parameter TypeID
            The code representing the data type for this field (String, byte, integer, ratio, vector etc)
        .Parameter Value
            The new value for the field
        .Parameter TypeName
            Reserved Will allow the type to specified as a name rather than a numeric code
        .Parameter Numerator
            Reserved will ratios to be passed as numerator / denominator
        .Parameter Denominator
            Reserved will ratios to be passed as numerator / denominator
        .Parameter String
            Reserved will allow the value for Vectors which hold strings to be passed as a string
        .Parameter passthru
            If set, the filter will be returned through the pipeline.  This should be set unless the filter is saved to a variable.
        .Parameter filter
            The filter chain that the rotate filter will be added to.  If no chain exists, then the filter will be created
    #>
param(
    [Parameter(ValueFromPipeline=$true)]
    [__ComObject]
    $filter,
    [Parameter(Mandatory=$true)]$ExifID, 
    $typeid , $value , $string , $Numerator, $denominator , $typeName,
    [switch]$passThru                      
    )
    process {
        if (-not $filter) { $filter = New-Object -ComObject Wia.ImageProcess } 
        if ($typeName -and -not $typeiD) {$typeid = @{"Undefined"=1000; "Byte"=1001;"String"=1002;"uInt"=1003;"Long"=1004;"uLong"=1005;"Rational"=1006;"URational"=1007
                                                      "VectorOfUndefined"=1100; "VectorOfByte"=1101; "VectorOfUint" = 1102; "VectorOfLong"= 1103; "VectorOfULong"= 1104; "VectorOfRational" = 1105; "VectorOfURational" = 1106;}[$typeName] }
        if ((-not $filter.Apply) -or (-not $typeID)) { return }
        if ((@(1006,1007) -contains $Typeid) -and (-not $value) -and ($numerator -ne $null) -and $denominator) {
            $value =New-Object -ComObject wia.rational                                                                                                                                                                                                         
            $value.Denominator = $denominator                                                                                                                                                                                                                     
            $value.Numerator = $Numerator                                                                                                                                                                                                                      
        }
        if ((@(1100,1101) -contains $TypeID) -and (-not $value) -and $string) {$value = New-Object -ComObject $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VwBJAEEALgBWAGUAYwB0AG8AcgA=')))
                                                                                 $value.SetFromString($string)
        }
        if ((1002 -eq $TypeID) -and (-not $value) -and $string) {$value = $string } 
        $filter.Filters.Add($filter.FilterInfos.Item($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('RQB4AGkAZgA=')))).FilterId)
        $filter.Filters.Item($filter.Filters.Count).Properties.Item("ID")   = $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('JABFAHgAaQBmAEkARAA=')))       
        $filter.Filters.Item($filter.Filters.Count).Properties.Item($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VAB5AHAAZQA=')))) = $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('JABUAHkAcABlAEkARAA=')))
        $filter.Filters.Item($filter.Filters.Count).Properties.Item($([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('VgBhAGwAdQBlAA=='))))= $Value 
        if ($passthru) { return $filter }         
    }
}
${_/=====\__/===\/=}                 = 1000
${/=====\/\/=\/\_/=}                      = 1001
${_/===\___/=\/\/==}                    = 1002
${/=\____/\____/===}           = 1003
${_/\_/\__/=\/\/===}                      = 1004
${/==\/\/\/\___/=\/}              = 1005
${_/\/\___/=\___/\_}                  = 1006
${/=\___/\/=\__/\/=}          = 1007
${__/\___/\/\__/=\_}         = 1100
${__/==\____/==\/=\}             = 1101
${__/=\__/=\/\/\___}  = 1102
${____/\______/====}             = 1103
${/=\___/\/=\_/\/==}     = 1104
${___/\/=\/=\_/\/=\}         = 1105
${/===\__/==\_/==\_} = 1106
