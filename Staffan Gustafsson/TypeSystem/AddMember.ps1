# Add-Member:
Get-Command -syntax Add-Member

# Simple objects with a single "Value" property
$objs = [pscustomobject] @{Value = 4.1}, [pscustomobject] @{Value = 5.7}
$objs

# Adding "Square", depending on the existing property Value
$objs | Add-Member -MemberType ScriptProperty -Name Square -Value {$this.Value * $this.Value}

# we can also add a typename
$objs | Add-Member -TypeName 'MyValueType'
$objs | Get-Member

# But wait!!!
$objs | Group-Object Square

# That ain't pretty!
# Adding a ToString()
$objs | Add-Member -MemberType ScriptMethod -Name ToString -Value { "My Square is $($this.Square)"} -Force
$objs | Group-Object Square

# CodeProperties:
# Let us create a C# code property
# this works around the PowerShell way of doing
# bankers rounding on conversions to int.
# Very surprising to people with a programming
# background!
Add-Type -TypeDefinition @"
using System;
using System.Management.Automation;
namespace PSConfEU.Types {
    public class CodeProperties {
        public static long AsHackerLong(PSObject obj) {
            return (long) LanguagePrimitives.ConvertTo<double>(obj.Properties["value"]. Value);
        }
    }
}
"@


# Add the code property to our objects
$codeProperty = [PSConfEU.Types.CodeProperties].GetMethod("AsHackerLong")
$objs | Add-Member -MemberType CodeProperty -Name LongValue -Value $codeProperty
$objs

# compare to a powershell conversion
[int] 5.7

# now for something secret!
# create an object with a range validated member
[ValidateRange(1,10)]
$myInteger = 5
$myVar = Get-Variable myInteger
$o = [pscustomobject] @{}

# Add the variable-property! to it
# psvariableproperty is a type accelerator pointing to SMA.PSVariableProperty
$o.psobject.properties.add([psvariableproperty]::new($myVar))
$o

# Change the value of the property
$o.myInteger = 9

# Note: that also changes  the variable
$myInteger

# try to set the integer value
$o.myInteger = 20

# Back to presentation
Invoke-Item $demohome\Typesystem.pptx
exit
