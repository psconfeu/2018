# Calling Linux scripts and commands from PowerShell Core (pws)

# the same way you would call
# it natively from Linux
./hello.sh

# with parameters
./hello2.sh WSL

# and the same problem with line endings
./hello3.sh

# alternatively specify the shell to
# use when executing the script
/bin/bash ./hello.sh

# python script
python hello.py
python sum.py 1 2

# running native Linux commands from pwsh

# GOTCHA! Bug in pwsh for linux?
cd ~
# compare running 
grep "PowerShell" test1.txt
grep "PowerShell" .test2.txt
grep "PowerShell" test*
grep "PowerShell" .test*
# from pwsh and then from bash
# can also be replicated with ls

# the workaround, use the PowerShell commands
# when you need to include hidden files
get-content .test* -force | grep "PowerShell"

# it's important to realize that ls is not an alias
# for get-content when on Linux!