# CIM instances are interesting as they have an adaption
$c = Get-CimInstance Win32_BIOS
$c

# psobject is the entry point for the abstraction
$c.psobject

# psbase is before the adaptation
$c.psbase

# or we can use Get-Member with the -View parameter
$c | Get-Member -View Base

# Look at the type name:
# we can find out more with
$c.pstypenames

# psadapted is after the adaptation
$c.psadapted

# Let's look at a small subset of the adapted properties
$c | Get-Member b* -View Adapted | Format-Table Name, Definition

# Let's look again at the CimInstanceProperties, unadapted, property
# Same subset
$c.psbase.CimInstanceProperties | Where-Object Name -like b* | Sort-Object Name | Format-Table Name, CimType, Value

# psextended is after PowerShell has added extened properties
$c | Get-Member -View Extended

# psadapted is after the adaptation
$c.psextended

# It is extended by a PropertySet
$c | Format-List PSStatus


# Back to presentation
Invoke-Item $demohome\Typesystem.pptx
exit
