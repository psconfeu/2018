
















${_/=====\_/=\/===\} = "dc-Local","google.com","rediff.com","yahoo.com"

foreach (${___/\_/\/\_/\_/=\} in ${_/=====\_/=\/===\}) {
	
	${_/\_____/\_/=\/\/} = (Test-Connection -ComputerName ${___/\_/\/\_/\_/=\} -Count 4  | measure-Object -Property ResponseTime -Average).average
	${___/==\_/\_/==\/=} = (${_/\_____/\_/=\/\/} -as [int] )
		
	write-Host "The Average response time for" -ForegroundColor Green -NoNewline;write-Host $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('IAAiACQAewBfAF8AXwAvAFwAXwAvAFwALwBcAF8ALwBcAF8ALwA9AFwAfQAiACAAaQBzACAA'))) -ForegroundColor Red -NoNewline;;Write-Host $ExecutionContext.InvokeCommand.ExpandString([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('JAB7AF8AXwBfAC8APQA9AFwAXwAvAFwAXwAvAD0APQBcAC8APQB9ACAAbQBzAA=='))) -ForegroundColor Black -BackgroundColor white
	  
}

