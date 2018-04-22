# Load our hero objects
. $demohome\SuperHero.ps1
# output them, this time as a table
Import-Hero | Format-Table

# update our format definition xml
Update-FormatData $demoHome\Table.format.ps1xml
# reload the imports
Import-Hero

# import and group them by height
Import-Hero | Format-Table -group Height

#oops! They have to be sorted!

Import-Hero | Sort Height | Format-Table -group Height

# We can use a hashtable with @{name="x"; expression={'value'}}
   # or @{n = "label";ex = {<scripblock>} } for shortness 
Import-Hero | Format-Table -group @{n = 'Powers'; ex = {$_.Power.Count}}

# back to powerpoint
Invoke-Item $demohome\Formatting.pptx
exit
