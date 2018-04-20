#######################################################################################
#Backup Exchange 2007 
#Fecha: 14/01/2012
#Pedro Genil
#Realizamos un backup de los SG del mailbox
#Se realizara de todos un incremental, y un full del que lleve X dias sin hacerse
######################################################################################

# Añadimos el moduklo de exchange
If ((Get-PSSnapin | where {$_.Name -match "Exchange.Management"}) -eq $null)
{
	Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
}
# Inicializar variables 
$lista_incremental = "" 
$lista_full = ""
$oldest_full = $(Get-Date).AddDays(4) 
# Obtener los datos del servidor 
$server = "MAILBOX" 

   # Procesar todas sus bases de datos excepto las que tienen "TSMRSG" como parte del nombre 
   foreach ($database in Get-MailboxDatabase -Server $server -Status | where { $_.storagegroupname -notlike "TSMRSG" }) 
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
                  # A partir de aqui, la bbdd es candidato a backup 
                  # Creamos el listado con los fulls 

                  # Para el backup full, solo nos quedamos con la que hace mas tiempo que no tiene backup full 
                  if ($database.LastFullBackup -lt $oldest_full) 
                  { 
                     $lista_full = "`"" + $($database.StorageGroupname) + "`"" 
                     $oldest_full = $database.LastFullBackup 
                  } 
                  
               } 
            } 
         } 
   } 

   # Procesar todas sus bases de datos excepto las que tienen "TSMRSG" como parte del nombre 
   foreach ($database in Get-MailboxDatabase -Server $server -Status | where { $_.storagegroupname -notlike "TSMRSG" }) 
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
                  # A partir de aqui, la bbdd es candidato a backup 
                  # Quitamos el full de los incremental 
			
                  if (-not $database.CircularLoggingEnabled) 
                  { 
			if ($lista_full -ne "`"" + $($database.StorageGroupname) + "`"")
			{
                     		if ($lista_incremental.Length -gt 0) 
                     			{ 
                        			$lista_incremental += "," 
                     			} 
                    			 $lista_incremental += "`"" + $($database.StorageGroupname) + "`"" 
			}
                  } 

               } 
            } 
         } 
   } 


#Añadimos las public Folder

foreach ($pf in Get-PublicFolderDatabase -Server $server -Status) 
   { 
      if ($pf.Mounted -and -not $pf.BackupInProgress) 
      { 
         if ($lista_full.Length -gt 0) 
         { 
            $lista_full += "," 
         } 
         $lista_full += "`"" + $($pf.storagegroupname) + "`"" 
      } 
   } 

# Ejecutar los jobs de backup, primero el incremental y luego el full 
$hoy = Get-Date 
$fecha = $hoy.ToString("yyyyMMdd") 
$log_incr = "Incr_" + $fecha + ".log" 
$log_full = "Full_" + $fecha + ".log" 
Write-Output (Get-Date) | out-file -File $log_incr -Append
cd "Ruta donde este el tdpexcc"
. ".\\tdpexcc.exe" "backup" $lista_incremental  >> $log_incr
Write-Output (Get-Date) | out-file -File $log_full -Append
. ".\\tdpexcc.exe" "backup" $lista_full "full" >> $log_full
#Guardamos la lista de backups por dia
$fechac = Get-date
if ((Test-Path "F:\\Logs_BCKP\\sg.txt") -ne $true)
{
New-Item -path "F:\\Logs_BCKP" -name "sg.txt" -type File
}
Write "------------------------------------------" >> "F:\\Logs_BCKP\\sg.txt"
Write $fechac >> "F:\\Logs_BCKP\\sg.txt"
Write "FULL" $lista_full >> "F:\\Logs_BCKP\\sg.txt"
Write "INCREMENTAL" $lista_incremental >> "F:\\Logs_BCKP\\sg.txt"
Write "------------------------------------------" >> "F:\\Logs_BCKP\\sg.txt"
# Limpiar logs, conservar 60 dias
foreach ($oldfile in (Get-ChildItem Incr_*.log,Full_*.log))
{ 
   if ($oldfile.LastWriteTime -le $hoy.AddDays(-60)) 
   { 
      Remove-Item $oldfile 
   } 
} 
#END
