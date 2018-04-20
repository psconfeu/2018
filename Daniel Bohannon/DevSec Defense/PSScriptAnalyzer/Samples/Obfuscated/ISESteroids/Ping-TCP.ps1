function Ping-TCP {
	#.SYNOPSIS
	# Tests TCP connectivity to a computer
	#.DESCRIPTION
	# Uses System.Net.Webclient to test TCP connectivity
	#.PARAMETER ComputerName
	# The target computer to test TCP connectivity against. This parameter accepts pipeline input.
	#.PARAMETER TcpPort
	# The TCP port to test
	#.EXAMPLE
	# # Tests LDAP connectivity on the server 'mydomaincontroller'
	# Ping-TCP mydomaincontroller 389
	#.LINK
	# http://gallery.technet.microsoft.com/scriptcenter/Ping-TCP-c6b1330c
	param (
	      [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)][string]$ComputerName,         
	      [parameter(Mandatory=$true,Position=1)][Int]$TcpPort		  
    )	
	$Error.Clear()
	$Error.RemoveRange(0,$Error.Count)	
	try {
		${/=\/===\_/\_/==\/} = [System.Net.Dns]::GetHostAddresses($ComputerName)		
	}
	catch {		
		${_/\_____/=\_/\__/} = "Ping-TCP request could not find host $ComputerName. Please check the name and try again."
		Write-Host ${_/\_____/=\_/\__/} -ForegroundColor Red							
	}
	if (!($Error)) {
		[bool]${/=\___/\/\_/\__/\} = $false
	    try { 
		    ${__/====\_____/\/=} = New-Object System.Net.Sockets.TcpClient($ComputerName, $TcpPort)        
	        if (${__/====\_____/\/=} -ne $null) {   
	        	${/=\___/\/\_/\__/\} = $true		            
	    	}          
		}         
		catch 
		{				
			${/=\___/\/\_/\__/\} = $false			
		}
		finally {			
			${__/====\_____/\/=}.Close | Out-Null
			${__/====\_____/\/=}.Dispose | Out-Null				
		}
		if (${/=\___/\/\_/\__/\}) { 
			${_/\_____/=\_/\__/} = "Reply from ${/=\/===\_/\_/==\/} on TCP port $TcpPort`: Connection succeeded."					
			Write-Host ${_/\_____/=\_/\__/}
		}
		else {
			${_/\_____/=\_/\__/} = "Could not open connection to ${/=\/===\_/\_/==\/} on TCP port $TcpPort`: Connection failed."
			Write-Host ${_/\_____/=\_/\__/} -ForegroundColor Red						
		}
	}
	$Error.Clear()
	$Error.RemoveRange(0,$Error.Count)		
}