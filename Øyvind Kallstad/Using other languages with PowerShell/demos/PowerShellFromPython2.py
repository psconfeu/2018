import subprocess
psscript = "./hello.ps1"
process=subprocess.check_call(["pwsh.exe","-File",psscript])

# subprocess.check_call(args, *, stdin=None, stdout=None, stderr=None, shell=False)
# Run command with arguments. Wait for command to complete.