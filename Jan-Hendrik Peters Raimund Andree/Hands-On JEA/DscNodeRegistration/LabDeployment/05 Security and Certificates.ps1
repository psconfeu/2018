$labName = 'DscLab1'
if (-not (Get-Lab -ErrorAction SilentlyContinue).Name -eq $labName)
{
    Import-Lab -Name $labName -NoValidation
}

$pullServers = Get-LabVM -Role DSCPullServer
$sqlServer = Get-LabVM -Role SQLServer2016 | Select-Object -First 1
$nodes = Get-LabVM | Where-Object Name -like *Node*
$mofEncCertificatesFolder = 'C:\MofEncCertificates' 

#-------------------------------------------------------------------------------------------------

$ca = Get-LabIssuingCA

#Each node requests a document encryption certificate
$certificates = $nodes | ForEach-Object {
    Request-LabCertificate -Subject "CN=$($_.FQDN)" -TemplateName DscMofEncryption -ComputerName $_ -PassThru
}

#create Create MofEncCertificates folder on pull server(s)
Invoke-LabCommand -ActivityName 'Create MofEncCertificates folder' -ComputerName $pullServers -ScriptBlock {
    mkdir -Path $mofEncCertificatesFolder -Force | Out-Null
} -Variable (Get-Variable -Name mofEncCertificatesFolder)

#save the certificates (public key only) to the pull server(s)
$certificates | ForEach-Object {
    $mofEncCert = $_
    Invoke-LabCommand -ActivityName 'Storing MofEncCertificate' -ComputerName $pullServers -ScriptBlock {

        $path = Join-Path -Path $mofEncCertificatesFolder -ChildPath "$($mofEncCert.PSComputerName).cer"
        [System.IO.File]::WriteAllBytes($path, $mofEncCert.RawData)
    
    } -Variable (Get-Variable -Name mofEncCert, mofEncCertificatesFolder) -PassThru
}