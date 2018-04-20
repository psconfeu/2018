function AddTo-HostsFile{

	<#
		.DESCRIPTION
			This function checks to see if an entry exists in the hosts file.
			If it does not, it attempts to add it and verifies the entry.

		.EXAMPLE
			Networkign.AddTo-Hosts -IPAddress 192.168.0.1 -HostName MyMachine

		.EXTERNALHELP
			None.

		.FORWARDHELPTARGETNAME
			None.

		.INPUTS
			System.String.

		.LINK
			None.

		.NOTES
			None.

		.OUTPUTS
			System.String.

		.PARAMETER IPAddress
			A string representing an IP address.

		.PARAMETER HostName
			A string representing a host name.

		.SYNOPSIS
			Add entries to the hosts file.
	#>

  param(
    [parameter(Mandatory=$true,position=0)]
	[string]
	$IPAddress,
	[parameter(Mandatory=$true,position=1)]
	[string]
	$HostName
  )

	$HostsLocation = "$env:windir\\System32\\drivers\\etc\\hosts";
	$NewHostEntry = "`t$IPAddress`t$HostName";

	if((gc $HostsLocation) -contains $NewHostEntry)
	{
	  Write-Host "$(Time-Stamp): The hosts file already contains the entry: $NewHostEntry.  File not updated.";
	}
	else
	{
    Write-Host "$(Time-Stamp): The hosts file does not contain the entry: $NewHostEntry.  Attempting to update.";
		Add-Content -Path $HostsLocation -Value $NewHostEntry;
	}

	# Validate entry
	if((gc $HostsLocation) -contains $NewHostEntry)
	{
	  Write-Host "$(Time-Stamp): New entry, $NewHostEntry, added to $HostsLocation.";
	}
	else
	{
    Write-Host "$(Time-Stamp): The new entry, $NewHostEntry, was not added to $HostsLocation.";
	}
}
