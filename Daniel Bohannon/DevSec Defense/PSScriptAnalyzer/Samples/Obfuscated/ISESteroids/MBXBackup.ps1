
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
${/===\__/\______/=} = Get-ADServerSettings
if (${/===\__/\______/=}.ViewEntireForest -eq "False")
	{
		Set-ADServerSettings -ViewEntireForest $true
	}
${__/=\/\________/\} = "heading1"
${/==\/\__/=\/==\__} = Get-MailboxDatabase -Status | where {$_.Recovery -eq $False -AND $_.ReplicationType -ne "Remote"} | sort Server
foreach (${_/=\/\/==\/\_/=\_} in ${/==\/\__/=\/==\__})
        {
            ${/====\/=====\____} = ${_/=\/\/==\/\_/=\_}.Server
            ${/=\/\/==\/====\/\} = ${_/=\/\/==\/\_/=\_}.LastFullBackup
            ${_/\/\___/\/===\__}  = ${_/=\/\/==\/\_/=\_}.Identity
			${_/\____/=\/\/\_/\} = ${_/=\/\/==\/\_/=\_}.LastIncrementalBackup
			${/==\_/=\__/\/\/\_} = ${_/=\/\/==\/\_/=\_}.LastDifferentialBackup
			${_/\/\_/=\/==\_/\_} = ${_/=\/\/==\/\_/=\_}.LastCopyBackup
    ${/==\/\___/\__/\_/}+=  "					<tr>"
    ${/==\/\___/\__/\_/}+=  "						<td width='15%'><font color='#0000FF'><b>$(${/====\/=====\____})</b></font></td>"
    ${/==\/\___/\__/\_/}+=  "						<td width='15%'><font color='#0000FF'><b>$(${_/\/\___/\/===\__})</b></font></td>"
    ${/==\/\___/\__/\_/}+=  "						<td width='15%'><font color='#0000FF'><b>$(${_/\____/=\/\/\_/\})</b></font></td>"
    ${/==\/\___/\__/\_/}+=  "						<td width='15%'><font color='#0000FF'><b>$(${/==\_/=\__/\/\/\_})</b></font></td>"
    ${/==\/\___/\__/\_/}+=  "						<td width='15%'><font color='#0000FF'><b>$(${_/\/\_/=\/==\_/\_})</b></font></td>"	
    if(${/=\/\/==\/====\/\} -eq $null)
    {
    ${__/=\/\________/\} = "heading10"       
	${/==\/\___/\__/\_/}+=  "					<td width='15%'><font color='#FF0000'><b>Never Backuped</b></font></td>"
    ${Global:/=====\__/==\_/\_} = 0
    }
    else
    {
	${/==\/\___/\__/\_/}+=  "						<td width='15%'><font color='#0000FF'><b>$(${/=\/\/==\/====\/\})</b></font></td>"
              if(${/=\/\/==\/====\/\} -gt (Get-Date).adddays(-1))
               {
			   ${/==\/\___/\__/\_/}+=  "			<td width='10%'><font color='#0000FF'><b>Valid</b></font></td>"
			   }
               else
               {
                    if(${/=\/\/==\/====\/\} -gt (Get-Date).adddays(-2))
                    {
					${__/=\/\________/\} = "heading10" 					 
					${/==\/\___/\__/\_/}+=  "						<td width='10%'><font color='#FF9900'><b>One Day Old</b></font></td>"                       
                    ${Global:/=====\__/==\_/\_} = 0
                    }
                    else
                    {
					${__/=\/\________/\} = "heading10"  
					${/==\/\___/\__/\_/}+=  "						<td width='10%'><font color='#FF0000'><b>More Than 2 Days</b></font></td>"                          
                    ${Global:/=====\__/==\_/\_} = 0
                    }
                }
    }
				${/==\/\___/\__/\_/}+=  "					</tr>"  
	}
foreach (${_/=\/\/==\/\_/=\_} in ${/==\/\__/=\/==\__})
        {
            ${/====\/=====\____} = ${_/=\/\/==\/\_/=\_}.Server
            ${/=\/==\_/\_/\/===} = ${_/=\/\/==\/\_/=\_}.SnapshotLastFullBackup
            ${_/\/\___/\/===\__}  = ${_/=\/\/==\/\_/=\_}.Identity
			${__/=\__/\/=\_/==\} = ${_/=\/\/==\/\_/=\_}.SnapshotLastIncrementalBackup
			${__/\/=\/\/\__/=\_} = ${_/=\/\/==\/\_/=\_}.SnapshotLastDifferentialBackup
			${__/\__/\/\/==\/=\} = ${_/=\/\/==\/\_/=\_}.SnapshotLastCopyBackup
    ${_/\_/\/\___/\/\/\}+=  "					<tr>"
    ${_/\_/\/\___/\/\/\}+=  "						<td width='15%'><font color='#0000FF'><b>$(${/====\/=====\____})</b></font></td>"
    ${_/\_/\/\___/\/\/\}+=  "						<td width='15%'><font color='#0000FF'><b>$(${_/\/\___/\/===\__})</b></font></td>"
    ${_/\_/\/\___/\/\/\}+=  "						<td width='15%'><font color='#0000FF'><b>$(${__/=\__/\/=\_/==\})</b></font></td>"
    ${_/\_/\/\___/\/\/\}+=  "						<td width='15%'><font color='#0000FF'><b>$(${__/\/=\/\/\__/=\_})</b></font></td>"
    ${_/\_/\/\___/\/\/\}+=  "						<td width='15%'><font color='#0000FF'><b>$(${__/\__/\/\/==\/=\})</b></font></td>"
    ${_/\_/\/\___/\/\/\}+=  "						<td width='15%'><font color='#0000FF'><b>$(${/=\/==\_/\_/\/===})</b></font></td>"
	${_/\_/\/\___/\/\/\}+=  "					</tr>"  	
}
${_/==\__/====\___/} += @"
	</TABLE>
	</div>
	</DIV>
    <div class='container'>
        <div class='$(${__/=\/\________/\})'>
            <SPAN class=sectionTitle tabIndex=0>Mailbox Server - Databases Backup Status</SPAN>
            <a class='expando' href='#'></a>
        </div>
        <div class='container'>
            <div class='tableDetail'>
                <table>
	  				<tr>
	  						<th width='15%'><b>Server Name</b></font></th>
							<th width='15%'><b>Database Name</b></font></th>
	  						<th width='15%'><b>LastIncrementalBackup</b></font></th>
	  						<th width='15%'><b>LastDifferentialBackup</b></font></th>
	  						<th width='15%'><b>LastCopyBackup</b></font></th>							
	  						<th width='15%'><b>LastFullBackup</b></font></th>							
	  						<th width='10%'><b>Backup Validity</b></font></th>					
	  				</tr>
                    $(${/==\/\___/\__/\_/})
                </table>
               <table>
	  				<tr>
	  						<br><th width='15%'><b>Server Name</b></font></th>
							<th width='15%'><b>Database Name</b></font></th>
	  						<th width='15%'><b>SnapshotLastIncrementalBackup</b></font></th>
	  						<th width='15%'><b>SnapshotLastDifferentialBackup</b></font></th>
	  						<th width='15%'><b>SnapshotLastCopyBackup</b></font></th>							
	  						<th width='15%'><b>SnapshotLastFullBackup</b></font></th>							
	  				</tr>
                    $(${_/\_/\/\___/\/\/\})
                </table>				
            </div>
        </div>
        <div class='filler'></div>
    </div>                     
"@
Return ${_/==\__/====\___/}