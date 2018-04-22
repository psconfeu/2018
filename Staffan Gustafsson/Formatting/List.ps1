# let's look at the measure object
Get-ChildItem -Recurse | Measure-Object -Property Length -Average

# lzybkr wrote this to improve on that
code $demoHome\Measure.format.ps1xml

# Update the format data with a list view that removes empty properties
# Notice -Prepend, since we need to be added before the existing definition
Update-FormatData -prepend $demoHome\Measure.format.ps1xml

# look again
gci -Recurse | Measure-Object -Property Length -Sum -Average

# load our heros
. $demohome\SuperHero.ps1
Import-Hero

# Lets look at a list format view for our heroes
code $demoHome\List.format.ps1xml

# Load the view
Update-FormatData $demoHome\List.format.ps1xml
# Show the heroes
Import-Hero

# one view for our visitors from overseas
Import-Hero | format-list -view us

# and one view for brexiters
Import-Hero | format-list -view uk

# Look what data is available
Get-FormatData SuperHero

# That's about it for lists
Invoke-Item $demoHome\formatting.pptx
exit
