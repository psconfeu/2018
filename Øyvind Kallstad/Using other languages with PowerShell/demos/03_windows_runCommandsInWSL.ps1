# running commands in WSL, from PowerShell

# first some weirdness
bash -c echo "Hello World"
# this doesn't work at all

# let's pack the entire command
# in quotation marks
bash -c 'echo "Hello World"'
# only hello is returned

# switch the single and double
# quotation marks
bash -c "echo 'Hello World'"
# now it works as expected

# the weird thing is that inside wsl
# it doesn't make a difference

# more weirdness
# in the project folder we have a simple
# bash script
Set-Location "C:\Users\grave\Documents\github\_presentations\PowerShell_and_the_rest\demos"
bash -c hello.sh
# not found? let's check if it's there
bash -c ls
# clearly it's there!
# this is similar to in PowerShell
# you have to include the path
# but luckily we can use .
bash -c ./hello.sh
# just remember that in Linux we use
# forward slash!

# Remember to wrap the command in quotes if you want to send arguments!
bash -c "./hello2.sh WSL"
# vs
bash -c ./hello2.sh WSL

# Also mind your line endings!
bash -c ./hello3.sh
# this file was created on Windows, and gets CRLF by default!
# it will give a weird error until you change it to LF!

# if you have different Linux distros
# you can use this format also:
ubuntu -c ls -la

# usefull examples
bash -c top
# remember to use 'q' to quit out of top

# can't wait for ssh for Windows?
# no problem!
bash -c 'ssh git@github.com'

function ssh($remote) {
    bash -c "ssh $remote"
}
ssh git@github.com