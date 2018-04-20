#Get-Services - Job Version 1.0
clear-host

if (${h`oSt}.Runspace.ApartmentState -notlike "STA")
    { # PresentationCore requires -STA mode
    powershell -STA -file ${mY`i`NV`oCAT`iON}.myCommand.definition
    exit
    }

# =============================================================================#
#* THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF          *#
#* ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED           *#
#* TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A          *#
#* PARTICULAR PURPOSE.                                                        *#
# =============================================================================#
# AUTHOR: Georges Maheu, Microsoft
# PFE Blog: OpsVault.com

Write-Host `
" ==============================================================================
 
 NAME:           3 - Get-Services - Job Version
 
 DATE:           2012-01-15
 Version:        1.0
 
 COMMENT:        Will populate an Excel spreadsheet with information about 
                 services for selected computers.

 IMPORTANT NOTE: Both the computer running the script and Excel must be using 
                 the same culture.
          
 ==============================================================================
" -ForegroundColor Cyan

Get-Culture  #http://support.microsoft.com/default.aspx?scid=kb;en-us;320369
             # both Excel and the computer must use US English

#the following code can help you generate the computer.txt file

#([adsisearcher]"objectCategory=computer").findall()    `
#    | foreach-object {([adsi]$_.path).cn}              `
#    | out-file -Encoding ascii -FilePath computerList.txt

clear-host
${ST`AR`Ttime}     = Get-Date
${Sc`R`iPTpAth}    = Split-Path -parent ${M`YIN`V`ocAtIOn}.myCommand.definition

${e`XCEl}         = New-Object -comObject excel.application 
${E`XcEL}.visible = ${tR`Ue} # or = $false
${E`xc`eL}.displayAlerts = ${fal`SE}
${W`Orkb`Ook}      = ${e`x`cEl}.workbooks.add()  

${c`Om`PUterS}     = Get-Content "$scriptPath\Computers.txt" 
${ResPO`NdinGCoMp`UT`erS} = 0  #Keep count of responding computers.

Add-Type -Assembly PresentationCore

${Ma`In`He`Ader`Row} = 3
${fiRst`D`At`ArOw}  = 4

${pr`oper`T`iES} =                               `
                "SystemName",               `
                "DisplayName",              `
                "Name",                     `
                "StartName",                `
                "AcceptPause",              `
                "AcceptStop",               `
                "Caption",                  `
                "CheckPoint",               `
                "CreationClassName",        `
                "Description",              `
                "DesktopInteract",          `
                "DisconnectedSessions",     `
                "ErrorControl",             `
                "ExitCode",                 `
                "InstallDate",              `
                "PathName",                 `
                "ProcessId",                `
                "ServiceSpecificExitCode",  `
                "ServiceType",              `
                "Started",                  `
                "StartMode",                `
                "State",                    `
                "Status",                   `
                "SystemCreationClassName",  `
                "TagId",                    `
                "TotalSessions",            `
                "WaitHint"

${Wor`kbO`Ok}.workSheets.item(1).name = "Info"  #Sheets index start at 1.
${Wor`Kb`Ook}.workSheets.item(2).name = "Exceptions"
#Delete the last sheet as there will be an extra one.    
${WO`RKBO`oK}.workSheets.item(3).delete() 

${i`NFOs`He`et} = ${WO`RK`BOok}.workSheets.item("Info")
${i`NFoshe`et}.cells.item(1,1).value2              = "Nb of computers:"
${Inf`o`sh`eeT}.cells.item(1,2).value2              = $(${CoMput`E`RS}).count
${I`N`FOshEET}.cells.item(1,2).horizontalAlignment = -4131 #$xlLeft 

${eXcE`pT`Ion`SsHeET} = ${WO`Rk`BOoK}.workSheets.item("Exceptions")
${ExCEp`TIOn`s`SHEEt}.cells.item(${m`AINheADErr`ow},1)  = "SystemName"
${EXcep`TiO`NSs`HEeT}.cells.item(${mA`inHeAdER`R`ow},2)  = "DisplayName"
${excE`P`T`ionsShe`eT}.cells.item(${m`AIN`HEA`derRoW},3)  = "StartName"
${ex`C`epT`IONSs`hEEt}.cells.item(${MAIN`HEaDe`RrOw},1).entireRow.font.bold = ${T`RUE}
#The next line will be overwritten if exceptions are found.
${eX`cePtIO`NsSHEET}.cells.item(${FiRstD`AtA`ROw},1)   = "No exceptions found"
${Ex`Cep`Ti`OnrOw} = ${fIR`StdAta`R`OW}

${I} = 1
foreach (${COmpu`T`ErNAME} in ${COmp`U`T`ERS})
    {
    ${COmpu`TeRNa`Me} = ${Co`MpuTer`NAme}.trim()
    ${WO`RkB`o`OK}.workSheets.add() | Out-Null
    "Creating sheet for $computerName"
    ${WoR`k`BooK}.workSheets.item(1).name = "$i - $computerName"         
    ${cO`MPUTer`shEeT} = ${W`ORKB`OoK}.workSheets.item("$i - $computerName")

    Start-Job -ScriptBlock `
                {
                param(${cOM`pUTeR`NA`ME}); 
                Get-WmiObject `
                    -class win32_service `
                    -ComputerName ${cOm`PU`Tern`AME}
                } `
              -Name "$i - $computerName" `
              -ArgumentList ${C`Om`puT`erNAmE}

#    needs to be run as admin
#    invoke-command -ScriptBlock `
#                     {
#                     param($computerName); 
#                     Get-WmiObject `
#                         -class win32_service `
#                         -ComputerName $computerName
#                     } `
#                  -asJob                        `
#                  -JobName "$i - $computerName" `
#                  -ThrottleLimit 3              `
#                  -ArgumentList $computerName   `
#                  -ComputerName LocalHost  
              
    ${i}++ 
    } #forEach computer

do
    {
    while (@(Get-Job -State Completed).count -gt 0)
        {
        "============"
        ${CUrR`ENtjO`BN`Ame} = (Get-Job -State Completed `
                              | Select-Object -First 1).name 
        ${SE`RV`iceS} = Receive-Job -name ${cu`R`ReNtjObnamE}
        Remove-Job -Name ${cUrrEnTJ`Ob`NA`ME}
        ${c`om`PU`T`ErsheET} = ${WOR`K`BooK}.workSheets.item(${Cur`RenT`job`NA`ME})
        ${cO`M`pUT`ErshE`eT}.select() #Show some activity on screen.

        if (${SE`RvIces}.count -gt 10) #less than 10 would indicate an error condition
            {
            ${c`O`mpUT`eRs`HeET}.cells.item(${m`Ai`NHEADERRoW},1).entireRow.font.bold = ${T`RUE}
            Write-Host "Processing $currentJobName." -ForegroundColor Green

            ${dA`TA} = (${S`erviC`es}                 `
                | Select-Object  ${p`R`O`perTiEs}   `
                | ConvertTo-Csv -Delimiter "`t" -NoTypeInformation ) -join "`r`n"

            [Windows.Clipboard]::setText(${Da`Ta}) | Out-Null

            ${coMpUt`ERs`HE`et}.range("a$mainHeaderRow").pasteSpecial(-4104) `
                | Out-Null #Const xlPasteAll = -4104
            [Windows.Clipboard]::setText("") | Out-Null #clear the buffer

            ${comP`UterS`he`Et}.usedRange.entireColumn.autoFit() | Out-Null
            ${RESP`oNdINGcO`m`PUtErs}++
            
            forEach (${SE`R`Vice} in ${se`RVIC`eS})
                {
    #            $service.displayName
               
                ################################################
                # EXCEPTION SECTION
                # To be customized based on your criteria
                ################################################
                if (     ${sEr`VI`ce}.startName -notmatch "LocalService"              `
                    -and ${sE`RVICE}.startName -notmatch "Local Service"             `
                    -and ${SeR`VICE}.startName -notmatch "NetworkService"            `
                    -and ${s`ERVI`ce}.startName -notmatch "Network Service"           `
                    -and ${SeRvi`cE}.startName -notmatch "LocalSystem"               `
                    -and ${S`eRvIce}.startName -notmatch "Local System")
                    {
                    ${Ex`CePtI`onss`hEeT}.cells.item(${eX`Ce`p`TiON`Row},1)  = ${S`e`RvICe}.systemName
                    ${ExCE`pT`IoNs`ShEeT}.cells.item(${ex`cEP`T`io`NRow},2)  = ${sEr`V`ICe}.displayName
                    ${exC`EP`TIon`s`SheET}.cells.item(${exCe`pTiON`R`oW},3)  = ${S`e`RvICe}.startName
                    ${eXC`ePt`iOnr`OW}++
                    } #if ($service.startName
                } #foreach ($service in $services)
            } 
        else 
            {
            ${CoM`p`uter`SHEET}.cells.item(${FI`R`s`TDAt`ArOw},1)   = "Computer $computerName did not respond to WMI query." 
            ${COmpuTeR`S`H`E`eT}.cells.item(${FiRsT`DAtaR`OW}+1,1) = "See $($scriptPath)\Unresponsive computers for additional information"
            ${Co`MpU`T`e`RSheeT}.cells.item(${firs`Td`A`T`AROW}+2,1) = "$Error[0]"

            Add-Content -Path "$($scriptPath)\Unresponsive computers.log" -Encoding Ascii `
                        -Value "$currentJobName did not respond to win32_pingStatus"
            Add-Content -Path "$($scriptPath)\Unresponsive computers.log" -Encoding Ascii `
                        -Value ${eR`RoR}[0]
            ${ErR`OR}.Clear()
            Add-Content -Path "$($scriptPath)\Unresponsive computers.log" -Encoding Ascii `
                        -value (Test-Connection -ComputerName ${cOM`P`UtERN`AmE} -Verbose -Count 1)
            Add-Content -Path "$($scriptPath)\Unresponsive computers.log" -Encoding Ascii `
                        -Value "----------------------------------------------------"
            Write-Host "Computer $currentJobName is not responding. Moving to next computer in the list." -ForegroundColor red
            
            }#if ($services.count -gt 10)
        } #while ((Get-Job -State Completed).count -gt 0)
        "============"
        get-job
        @(get-job).count
    } until (@(get-job -State Running).count -eq 0 -and @(get-job -State Completed).count -eq 0)

"============"
get-job

while (@(Get-Job -State Failed).count -gt 0)
    {
    "============"
    ${E`RROR}.Clear()
    ${C`UrrENtjo`B`NAMe} = (Get-Job -State Failed | Select-Object -First 1).name 
    ${SERV`I`Ces} = receive-job -name ${CuRR`ENt`JObnamE}
    ${cOMp`UTER`s`hEet} = ${w`orKBOok}.workSheets.item(${cu`RReN`TJO`BnaMe})
    ${cO`Mpu`TER`s`hEEt}.select() #Show some activity on screen.
    ${cOmpU`TE`R`sh`EEt}.cells.item(${F`IrSt`daT`AroW},1)   = "Computer $computerName did not respond to WMI query." 
    ${cOm`put`e`RsHeet}.cells.item(${FIrs`Tda`T`ARoW}+1,1) = "See $($scriptPath)\Unresponsive computers for additional information"
    ${coMpu`TErSH`EET}.cells.item(${fiRsTdaT`A`ROW}+2,1) = "$Error[0]"
    Add-Content -Path "$($scriptPath)\Unresponsive computers.log" -Encoding Ascii `
                -Value "$currentJobName did not respond to win32_pingStatus"
    Add-Content -Path "$($scriptPath)\Unresponsive computers.log" -Encoding Ascii `
                -Value ${E`R`Ror}[0]
    ${eR`Ror}.Clear()
    Add-Content -Path "$($scriptPath)\Unresponsive computers.log" -Encoding Ascii `
                -value (Test-Connection -ComputerName ${c`Om`PU`TEr`NAMe} -Verbose -Count 1)
    Add-Content -Path "$($scriptPath)\Unresponsive computers.log" -Encoding Ascii `
                -Value "----------------------------------------------------"
    Write-Host "Computer $currentJobName is not responding. Moving to next computer in the list." -ForegroundColor red
    Remove-Job -Name ${CUrreN`TJO`Bn`AME}
    } #while ((Get-Job -State Completed).count -gt 0)

${E`XCEPT`ION`SSheeT}.usedRange.entireColumn.autoFit() | Out-Null

${i`Nf`os`HEET}.cells.item(2,1).value2              = "Nb of responding computers:"
${In`Fo`sHeeT}.cells.item(2,2).value2              = ${RESPONdIng`CoM`p`uterS}
${iN`FosH`eet}.cells.item(2,2).horizontalAlignment = -4131 #$xlLeft 
${i`N`FoshE`eT}.usedRange.entireColumn.autoFit()    | Out-Null

${wOrK`BOOK}.saveAs("$($scriptPath)\services.xlsx")
${WO`Rkbo`OK}.close() | Out-Null

${EXc`El}.quit()

#Remove all com related variables
Get-Variable -Scope script                                               `
    | Where-Object {${_}.Value.pstypenames -contains 'System.__ComObject'} `
    | Remove-Variable -Verbose
[GC]::Collect() #.net garbage collection
[GC]::WaitForPendingFinalizers() #more .net garbage collection

${eND`TIme}     = get-date

"" #blank line
Write-Host "-------------------------------------------------" -ForegroundColor Green
Write-Host "Script started at:   $startTime"                   -ForegroundColor Green
Write-Host "Script completed at: $endTime"                     -ForegroundColor Green
Write-Host "Script took $($endTime - $startTime)"              -ForegroundColor Green
Write-Host "-------------------------------------------------" -ForegroundColor Green
"" #blank line

# ******************************************************************************
# The sample scripts are not supported under any Microsoft
# standard support program or service. The sample scripts
# are provided AS IS without warranty of any kind. Microsoft
# further disclaims all implied warranties including, without
# limitation, any implied warranties of merchantability or of
# fitness for a particular purpose. The entire risk arising out
# of the use or performance of the sample scripts and documentation
# remains with you. In no event shall Microsoft, its authors, or 
# anyone else involved in the creation, production, or delivery of 
# the scripts be liable for any damages whatsoever (including, without
# limitation, damages for loss of business profits, business 
# interruption, loss of business information, or other pecuniary loss)
# arising out of the use of or inability to use the sample scripts or
# documentation, even if Microsoft has been advised of the possibility
# of such damages.
# ******************************************************************************





