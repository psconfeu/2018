### Running Windows executables from within WSL

#### Start notepad
/mnt/c/Windows/notepad.exe

#### Open file in Code
'/mnt/c/Program Files/Microsoft VS Code/Code.exe' -n ./01_windows_callNativeCommands.ps1

#### Run PowerShell script
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoLogo -NoProfile -File ./hello.ps1

#### Run PowerShell Core script
'/mnt/c/Program Files/PowerShell/6.1.0-preview.1/pwsh.exe' -NoLogo -NoProfile -File ./hello.ps1

#### Inception!

##### start with clean Ubuntu WSL shell
cat /etc/os-release

##### Start PowerShell Core
pwsh
$psversiontable

##### Start Windows PowerShell
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
$psversiontable

##### Start cmd
cmd.exe
ls (should fail because we are in dos)
dir c:\
ver

##### Run a PowerShell script!
c:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -noprofile -nologo -file c:\Users\grave\Documents\github\_presentations\PowerShell_and_the_rest\demos\hello.ps1