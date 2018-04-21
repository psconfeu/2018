. $demohome\SuperHero.ps1
# let us look at how our heroes look by default
Import-Hero | Select-Object -first 1 | Format-Custom | more

# let us look at how our heroes look by default
Update-FormatData $demoHome\Custom.format.ps1xml
Import-Hero | Format-Custom | more

# That is sooo cool! How did that happen?!?
code $demohome\custom.format.ps1xml

# We must have another look
iph

# Back to presentation
ii $demohome\Formatting.pptx

