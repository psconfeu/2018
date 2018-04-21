. $demohome\SuperHero.ps1
# Divide by 0 in the formatter by using an expression
Import-Hero |  Format-Table Name, @{n = 'Powers'; ex = {$_.Power.Count / 0}}

# Don't hide the errors. -DisplayError - Something has gone wrong
Import-Hero |  Format-Table Name, @{n = 'Powers'; ex = {$_.Power.Count / 0}} -DisplayError

# Show the errors. -ShowError
# Note 'MshExpression' :) 
Import-Hero |  Format-Table Name, @{n = 'Powers'; ex = {$_.Power.Count / 0}} -ShowError

# show all details about an error object
$error[0] | Format-List -ShowError -Force *

# When you have a smaller font
$error[0] | Format-Custom -ShowError -Force * -Depth 1

# Back to PowerPoint
Invoke-Item $demohome\Formatting.pptx
exit
