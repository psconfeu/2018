# Añadimos el modulo de exchange
If ((Get-PSSnapin | where {$_.Name -match "Exchange.Management"}) -eq $null)
{
	Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
}
$lista= ""
[int]$tam=30
$server = "MAILBOX"
$discos=get-wmiobject -class win32_volume -filter "DriveType=3" -computer $server
$databases = Get-MailboxDatabase -Server $server -Status
foreach ($database in $databases)
{
        # Continuar solo si la bbdd no es de recovery 
         if (-not $database.Recovery) 
         { 
            # Continuar solo si la bbdd esta montada 
            if ($database.Mounted) 
            { 
               # Continuar solo si la bbdd no esta en modo backup 
               if (-not $database.BackupInProgress) 
               { 
                  # A partir de aqui, sacamos los tamaños de la unidad de log
                    #Sacamos la unidades en la que se encuentra el log
                    $logpath = (get-storagegroup $database.storagegroup).logfolderpath
                    foreach ($disco in $discos)
                        {
                            #Verficamos que el server tenga la unidad log
                             if ($disco.driveletter -eq $logpath.drivename)
                                {
                                    $tamlog= ($disco.freespace/1GB)
                                    #Comparamos el tamaño
                                        if ($tamlog -lt $tam)
                                                {
                                                    if ($lista.Length -gt 0) 
                     			                            { 
                        			                             $lista += "," 
                     			                            } 
                    			                    $lista += "`"" + $($database.StorageGroupname) + "`"" 
                                                    $tamlog = $tam
                                                 }

                                }   
                        }
                }
           }
         }
}
# Ejecutar el full 
$hoy = Get-Date 
$fecha = $hoy.ToString("yyyyMMdd") 
$log_full = "Full_" + $fecha + ".log" 
cd "Ruta ejecutable del tdpexcc"
. ".\\tdpexcc.exe" "backup" $lista "full" >> $log_full
#Guardamos la lista de backups por dia
$fechac = Get-date
if ((Test-Path "F:\\Logs_BCKP\\full.txt") -ne $true)
{
New-Item -path "F:\\Logs_BCKP" -name "full.txt" -type File
}
Write "------------------------------------------" >> "F:\\Logs_BCKP\\full.txt"
Write $fechac >> "F:\\Logs_BCKP\\full.txt"
Write "FULL" $lista_full >> "F:\\Logs_BCKP\\full.txt"
Write "------------------------------------------" >> "F:\\Logs_BCKP\\full.txt"
# Limpiar logs, conservar 60 dias
foreach ($oldfile in (Get-ChildItem Full_*.log))
{ 
   if ($oldfile.LastWriteTime -le $hoy.AddDays(-60)) 
   { 
      Remove-Item $oldfile 
   } 
} 
