import subprocess
pscommand = "Write-Host Hello World from Python!"
process=subprocess.check_call(["pwsh.exe","-Command",pscommand])

# subprocess.check_call(args, *, stdin=None, stdout=None, stderr=None, shell=False)
# Run command with arguments. Wait for command to complete.