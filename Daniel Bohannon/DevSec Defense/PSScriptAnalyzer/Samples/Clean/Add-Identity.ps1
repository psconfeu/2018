param(
[Parameter(Position=0,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$true)]
[alias("Name","ComputerName")] $Computer = @($env:computername),
[string] $NTDomain = ($env:UserDomain),
[string[]] $LocalGroups = @("Administrators"),
[string[]] $Identities, # can be domain user or group
[switch] $Output,
[switch] $Add,
[switch] $Remove
)
begin{
$Global:objReport = @()
# list current members in defined group
Function ListMembers ($Group){
	$members = $Group.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
	return $members
	}
}

process{
if (Test-Connection -ComputerName $Computer -Count 1 -Quiet -EA "Stop"){
	foreach ($Group in $LocalGroups){
		try{
			$tmpComputer = [ADSI]("WinNT://" + $Computer + ",computer")
			$tmpGroup = $tmpComputer.psbase.children.find($Group)
			foreach ($User in $(ListMembers $tmpGroup)){
				$objOutput = New-Object PSObject -Property @{
					Machinename = [string]$Computer
					GroupName = $Group
					UserName = $User
					Action = "Existing"
					}#end object
				$Global:objReport+= $objoutput
				}
			if ($Identities){
				foreach ($User in $Identities){
					$Action = "none"
					If ($Add){
						$tmpGroup.Add("WinNT://" + $NTDomain + "/" + $User)
						$Action = "Added"
						}
					If ($Remove){
						$tmpGroup.Remove("WinNT://" + $NTDomain + "/" + $User)
						$Action = "Removed"
						}
					$objOutput = New-Object PSObject -Property @{
						Machinename = [string]$Computer
						GroupName = $Group
						UserName = $User
						Action = $Action
						}#end object
					$Global:objReport+= $objoutput
					}
				}
			}
		catch{
			$continue = $False
			$objOutput = New-Object PSObject -Property @{
				Machinename = [string]$Computer
				GroupName = $Group
				UserName = $User
				Action = $Error[0].Exception.InnerException.Message.ToString().Trim()
				}#end object
			$Global:objReport+= $objoutput
			}
		}
	}
}

end{
$Global:objReport
}
