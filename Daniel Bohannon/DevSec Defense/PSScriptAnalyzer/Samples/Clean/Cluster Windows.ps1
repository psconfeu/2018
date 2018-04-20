#Comprobacion del estado de los clusters#
#########################################
# Add Exchange Admin module
If ((Get-PSSnapin | where {$_.Name -match "Exchange.Management"}) -eq $null)
{
	Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
}
#Fichero donde estan los nombres de los cluster
$activos= Get-content "F:\\Scripts\\Cluster\\activos.txt"
#Creamos la tabla
$notabla = @()
$notabla += "<table width='200' border='2' cellspacing='0'>"
$contador = 0
 #Nos recorremos los activos
    foreach($activo in $activos)
    {
    $datos= gwmi -q "select * from MSCluster_ResourceGroup" -namespace root\\mscluster -computername $activo -Authentication PacketPrivacy | select Name,InternalState,State,__SERVER 
    $name = gwmi -q "select * from MSCluster_ResourceGroup" -namespace root\\mscluster -computername $activo -Authentication PacketPrivacy | where {$_.name -like "*CLUS*"} | Select name
    $namecluster= $name.name
    foreach ( $propdatos in $datos)
                        {
                          #Miramos el servidor activo de dicho cluster
                          $ClusterStatus = Get-ClusteredMailboxServerStatus -Identity $namecluster | Select -Expand OperationalMachines | ForEach {If($_ -like "*Owner*") {$_}}
                          $ActiveNode = $ClusterStatus.Split(" ")[0]
                          #miramos si coincide el activo con el que tiene que ser
                          if ($ActiveNode -eq $propdatos.__SERVER)
                              {
                              #Miramos si algun recurso se encuentra offline
                              if ($propdatos.name -ne "Available Storage")
                              {
                                if ($propdatos.internalstate -eq "Offline")
                                    {
                                        $notabla += "<tr><td>" + $propdatos.name + "</td><td><font color='red'>" +  $propdatos.internalstate + "</font></td><td>" + $activeNode +"</td></tr>"
                                        $contador = $contador + 1
                                    } 
                                    #Todo está correcto                    
                                else
                                    {
                                    if ($contador -gt 0)
                                    {
                                        $notabla += "<tr><TH COLSPAN=3> <font color='blue'>" + $namecluster + "</th></font></tr>"
                                        
                                     }   
                                    }
                              }
                              } 
                              #Si no coincide
                           else
                               { 
                               
                               $contador = $contador + 1 
                               
                               if ($propdatos.name -ne "Available Storage")
                               {
                               if ($propdatos.internalstate -eq "Offline")
                                    {                                       
                                        
                                        $notabla += "<tr><td>" + $propdatos.name + "</td><td><font color='red'>" +  $propdatos.internalstate + "</font></td><td BGCOLOR='red'>" + $activeNode +"</td></tr>"
                                    }                      
                                else
                                    {
                                        
                                        $notabla += "<tr><td>" + $propdatos.name + "</td><td><font color='red'>" +  $propdatos.internalstate + "</font></td><td BGCOLOR='red'>" + $activeNode +"</td></tr>"
                                    }
                               }
                              }
                                 
                              
                        }
       }#Cerramos los activos      

$notabla += "</table><br>" 
$notabla > estado.html
if ($contador -gt 0)
{
#Terminada la recofida de datos, lo mandamos por email               
    $smtpServer = "xx.xx.xx.xx"
	$smtpFrom = "Cluster Windows <email@dominio.es>"
	$smtpTo = "email2@dominio.es"
    $message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto
	$message.Subject = "Chequeo Cluster Windows"
	$message.IsBodyHTML = $true
    $message.Body = $notabla
	$smtp = New-Object Net.Mail.SmtpClient($smtpServer)
	$smtp.Send($message)
}
