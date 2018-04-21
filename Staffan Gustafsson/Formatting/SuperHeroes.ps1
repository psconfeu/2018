# we will use Super Heros as sample data for this session
Get-Content $demohome\SuperHero.ps1

# we will use Super Heros as sample data for this session
colorize (Get-Content $demohome\SuperHero.ps1 -raw)


# Lets load it into our session
. $demohome\SuperHero.ps1
Import-Hero

# Update the typedata for the type 'SuperHero' - This is how I want it displayed by default
Update-TypeData -typename SuperHero -DefaultDisplayPropertySet "Name", "Power" -Force
Import-Hero

# So, what is this 'Update-TypeData'
Get-Command -syntax Update-TypeData

# To demonstrate the effect of the DefaultDisplayProperty,
# the heroes are put in a property as members of an array
$a = [pscustomobject] @{
    HeroArray = Import-Hero
  }
$a

# Update the DefaultDisplayProperty and take a new look
Update-TypeData -typename SuperHero -DefaultDisplayProperty AlterEgo -Force
$a

# Let's look at formatdata
# Remember PowerShell has a database in it's ExecutionContext
# Where it keeps track of format information
Get-ChildItem | Measure-Object

Get-ChildItem | Measure-Object | Get-Member

Get-FormatData *.GenericMeasureInfo

# Why the deserialized
$deserialized = pwsh -nop -command {ls | measure-object -Property Length -Sum }

$deserialized

$deserialized.pstypenames

$deserialized.psbase

# GenericMeasureInfo: meet Format-Custom!
# This is often a good way to get a detailed view of an object
Get-FormatData *.GenericMeasureInfo | format-custom

(Get-FormatData *.GenericMeasureInfo | format-custom | out-string) -split '\n' |sls \.\.\. -Context 6,0

# What is this ... ???

$FormatEnumerationLimit = 20
Get-FormatData *.GenericMeasureInfo | format-custom

# Why do we only see 'System.Management.Automation.ListControlEntryItem's !!!

Get-FormatData *.GenericMeasureInfo | format-custom -Depth 7 | more

# Special handling of 'Name', 'ID' and 'key':
# Create classes with a mix of name and/or Id
# This does not work for types that has an implementation
# of ToString
class NameClass       { $Name = "Value of Name" }
class IdClass         { $ID = 42 }
class NameIdClass     { $Name = "Name Chosen Over Id"
                        $ID = 4711 }
class NoNameNoIdClass { $None = "NoNameNoId - Not displayed"}
class SpecialKeyClass { $MySpecialKey = "SpecialKey"}

# Create instances and put them in something that triggers the default property display
$o = [PSCustomObject] @{
           MyHeroes = [NameClass]::new(), [IdClass]::new(), [NameIdClass]::new(),
                        [NoNameNoIdClass]::new(), [SpecialKeyClass]::new()
     }

$FormatEnumerationLimit=5
$o

# Back to presentation
Invoke-Item $demohome\Formatting.pptx
exit
