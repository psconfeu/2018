Write-Warning 'NO WAY!'
break

# Be aware of aliases!
dir /a:h

# Generate ssh key (you need git for windows installed for this example)
$pw = 'mypass'
ssh-keygen -t rsa -b 4096 -f c:\temp\mykey -N $pw
# the above command fails as the ssh-keygen command is not in the path
# so let's assign the full path and command name to a variable
$sshKeygen = 'C:\Program Files\Git\usr\bin\ssh-keygen.exe'
$sshkeygen -t rsa -b 4096 -f c:\temp\mykey -N $pw
# this will not work - PowerShell doesn't understand that the stuff
# that comes after the ssh-keygen is it's parameters.
& $sshkeygen -t rsa -b 4096 -f c:\temp\mykey -N $pw
# when using the call operator on the other hand, PowerShell
# knows how to handle the parameters correctly
# but the command still don't work
# this time because it don't understand the value given to the
# -N parameter!
& $sshkeygen -t rsa -b 4096 -f c:\temp\mykey -N `"$pw`"
# when properly escaping the quotation marks we get the command to work

# BONUS!
# if you want to generate a key with a blank passphrase, it looks something like this:
& $sshkeygen -t rsa -b 4096 -f c:\temp\mykey -N "`"`""

# Another variation
# this time there is no spaces in the path, so we get away with not
# wrapping the file path in quotation marks
C:\temp\bin\ssh-keygen.exe -t rsa -b 4096 -f c:\temp\mykey -N ""
# the problem arises this time however, regarding the input
# to the -N parameter
C:\temp\bin\ssh-keygen.exe --% -t rsa -b 4096 -f c:\temp\mykey -N ""
# here we are using the stop-parsing operator to stop PowerShell
# from trying to parse the 

& $sshkeygen --% -t rsa -b 4096 -f c:\temp\mykey -N $pw
# combing the two techniques works, but since PowerShell is not parsing
# after the stop-parsing operator, the $pw variable is never
# unpacked - and we get an error that the passphrase is too short.

# consider the following
$algorithm = 'rsa'
$bits = 4096
$keyName = 'mykey'
& $sshkeygen -t $algorithm -b $bits -f "c:\temp\$keyName" -N $pw
# using variables like this works for all parameters except -N
# just something to be aware of
# if you are using a blank passphrase, consider using it like this:
& $sshkeygen -t $algorithm -b $bits -f "c:\temp\$keyName" --% -N ""

# if command is in the path we can call it directly, and don't
# need to use the call operator
# + another way of escaping the quotation marks for the
# weird -N parameter
$env:Path = $env:Path + ";C:\Program Files\Git\usr\bin"
ssh-keygen -t $algorithm -b $bits -f "c:\temp\$keyName" """-N $pw""" 

# it's easy to try the following approach when you have
# dynamic parameter values
$params = "-t $algorithm -b $bits -f c:\temp\$keyName -N $pw"
ssh-keygen $params
# but this doesn't work
# as you see it interpretes -t correctly but assumes everything else is
# input to this parameter