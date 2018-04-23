<#  Andreas Nick PSConf.EU Werde zum XML Ninja mit PowerShell                                   
    
     _ __    ___  __      __  ___  _ __  ___ | |__    ___ | || |
    | '_ \  / _ \ \ \ /\ / / / _ \| '__|/ __|| '_ \  / _ \| || |
    | |_) || (_) | \ V  V / |  __/| |   \__ \| | | ||  __/| || |
    | .__/  \___/   \_/\_/   \___||_|   |___/|_| |_| \___||_||_|     ,.
    |_|                                                              \-'__
                                                                     / o.__o____
     _   _  ___   ___  _ __   __ _  _ __   ___   _   _  _ __          \/_/ /.___/--,  XML     
    | | | |/ __| / _ \| '__| / _` || '__| / _ \ | | | || '_ \         ||\' PowerShell
    | |_| |\__ \|  __/| |   | (_| || |   | (_) || |_| || |_) |        | /
     \__,_||___/ \___||_|    \__, ||_|    \___/  \__,_|| .__/          \_\
                             |___/                     |_|             -''
     _
    | |__    __ _  _ __   _ __    ___  __   __  ___  _ __
    | '_ \  / _` || '_ \ | '_ \  / _ \ \ \ / / / _ \| '__|
    | | | || (_| || | | || | | || (_) | \ V / |  __/| |
    |_| |_| \__,_||_| |_||_| |_| \___/   \_/   \___||_|               #PSUGH
	
  Andreas Nick 
  Twitter:@nickinformation 
  www.software-virtualisierung.de 
  www.andreasnick.com

#>

$PSDefaultParameterValues = @{"Write-Host:ForegroundColor" = "Green";"Write-Host:BackgroundColor" = "Black"}

throw "break - mark code and use F8"

#
#Start as a ninja student
#
#A very simple XML
$myxml = [xml] '<?xml version="1.0"?>
  <settings>
  <setting1/>
  <setting2/>
  <setting3/>
</settings>'

#Simple editing
$myxml.settings.setting1 = "100" #only String
$myxml.settings.setting2 = "Hallo"
$myxml.settings.setting3 = "Wert"
$myxml.settings.setting1

$myxml.settings.setting1.gettype() #a String!

Write-Host $myxml.settings.setting1 $myxml.settings.setting2 $myxml.settings.setting3


#[System.Xml]
#Escape Characters ``, `#,  `', `"

#
#A simple XML
#

[xml] $myxml = '<?xml version="1.0"?>
  <Applications>
  <Global/>
  <Application>
  <AppName>FreeAppDeployRepackager</AppName>
  <InstallerFolder>C:\packages\msi</InstallerFolder>
  <Installer>Free_AppDeploy_Repackager.msi</Installer>
  <InstallerOptions>/qn</InstallerOptions>
  <Cmdlet>true</Cmdlet>
  <Enabled>true</Enabled>
  </Application>
  <Application>
  <AppName>XmlNotepad</AppName>
  <InstallerFolder>C:\packages\msi</InstallerFolder>
  <Installer>XmlNotepad.msi</Installer>
  <InstallerOptions>/qn</InstallerOptions>
  <Cmdlet>true</Cmdlet>
  <Enabled>true</Enabled>
  </Application>
</Applications>'



#
# How is the output beautifully formatted for young students?
# $xml returns only the trunk
# Print as string

$myxml
$myxml.Save("$env:TEMP\myxml.xml")
Write-Host "Formatet XML output over a files" 
get-content "$env:TEMP\myxml.xml"

#
#Formatet XML output over a filestream
#

function Format-XML  
{
  param
  (
    [Parameter(Mandatory=$true)][xml] $xml,
    [int]$indent = 4
  )
 
  $StringWriter = New-Object System.IO.StringWriter 
  $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter 
  $xmlWriter.Formatting = "indented" 
  $xmlWriter.Indentation = $Indent 
  $xml.WriteContentTo($XmlWriter) 
  $XmlWriter.Flush() 
  $StringWriter.Flush() 
  Write-Output $StringWriter.ToString() 
}

# Output via the function"
Write-Host "Output over the funktion Format-XML" 
Format-Xml $myxml 

# Load XML from File
[xml] $myxml2 = New-Object xml 
$myxml2.Load("$env:TEMP\myxml.xml")

Write-Host "XML Reloaded..." 

# How can I customize the output?
Format-Xml $myxml2 -indent 8

#Change and read elements and attributes

# Read element
$myxml2.applications #return two elements
$myxml2.applications.Application.appname[0] 
$myxml2.applications.Application.appname[1] 
$myxml2.applications | ForEach-Object { "Application " + $_.Application.AppName} #return all "Appname" Elements as string

# Only one element in the xml!
$myxml2.Applications.Global = "Test"

$myxml2.applications.Application #!!! Is an array
$myxml2.applications.Application[0].AppName = "TestApp"

Format-Xml $myxml2 -indent 4

#Howto set attributes?

$myxml2.Applications.SetAttribute("NewAttribute","Value123")
$myxml2.Applications.Global.SetAttribute("NewAttribute","Value123") #Error! 

$myxml2.Applications.Global.GetType() #Object / String

$myxml2.Applications.GetType() #XmlLinkedNode  
$myxml2.applications.Application.AppName[0].GetType() #String

# XPATH Finally becoming a ninja?
# Solution is xPath

#                  .===
#                 / __)        _
#                 (  ||_.''.  {_}
#       Smash     | =/ \   /' :                
#                 /\_~/() \__.'     ____       _  ___  ___    
#      Kick      |_   \   //  |''''`    |-'8,  \\//| \/ ||  
#         --   _ :  |_ '-[]___/   '.....\--.O  //\\|    ||__|
#             {_}'' .'\ //  |':````
#              '...'   /\\_/    `,
#                         '.._.'
#                    

# / Selects from the root node
# // Selects from the current node on, anywhere in the document
# . Selects the current node
# .. Selects parent of current node
# @ Selects an attribute

$myxml2.SelectSingleNode("/Applications/Global").GetType() #System.Xml.XmlLinkedNode
$myxml2.SelectSingleNode("/Applications/Global").SetAttribute("NewAttribute","Value123")
$myxml2.SelectSingleNode("/Applications/Global").SetAttribute("NewAttribute2","12345")

# Read an Attribute
$myxml2.Applications.Global.NewAttribute
($myxml2.Applications.Global | Select-Object NewAttribute).NewAttribute


Format-Xml $myxml2 -indent 4

#XPath specifix element in a List
$myxml2.SelectSingleNode("//Application[AppName='XmlNotepad']") #Use "//" for a subsearch
$myxml2.SelectSingleNode("/Applications/Application[AppName='FreeAppDeployRepackager']") #Use "/" for root


$myxml2.SelectNodes("//Application[contains(AppName,'XmlNotepad')]") #contains
$myxml2.SelectNodes("//Application[contains(AppName,'')]") #return all
$myxml2.SelectNodes("//Application[contains(AppName,'X')]") #return XmlNotepad
$myxml2.SelectNodes("//Application[starts-with(AppName,'X')]") #return XmlNotepad

#Search by attribute
#Set Attribute (typecast)
([System.Xml.XmlElement]$myxml2.SelectSingleNode("//Application[starts-with(AppName,'X')]/Installer")).SetAttribute("TestAttributeValue","999")
$myxml2.SelectSingleNode("//Application[starts-with(AppName,'X')]/Installer")

Write-Host "Mit Attribute" 
Format-Xml $myxml2 -indent 4


#Remove a attribute
([System.Xml.XmlElement]$myxml2.SelectSingleNode("//Application[starts-with(AppName,'X')]/Installer")).RemoveAttribute("TestAttributeValue")


#Search for a attribute
$nodes = $myxml2.SelectNodes("//Installer[@TestAttributeValue='999']")
$nodes
$nodes.Count # = 1
$nodes = $myxml2.SelectNodes("//Installer[not(@TestAttributeValue)]") #appsend attribute
$nodes
$nodes.Count # = 1
$nodes = $myxml2.SelectNodes("//Installer") #appsend attribute
$nodes
$nodes.Count # = 2



# Create XML with Powershell
# Create a new XML 
[System.XML.XMLDocument]$mynewXML = New-Object System.XML.XMLDocument
[System.XML.XmlNode]$mynewNode = $mynewXML.CreateXmlDeclaration("1.0", $null, $null) #"1.0", "UTF-16", $null -> Codepage example UTF-8, iso-8859-1 etc.
$mynewXML.appendChild($mynewNode)
$mynewApps = [System.XML.XMLElement]$mynewXMLRoot = $mynewXML.CreateElement("Applications")
$mynewXML.appendChild($mynewXMLRoot)


[System.XML.XMLElement]$AppNode = $mynewXML.CreateElement("Application")
$mynewApps.AppendChild($AppNode)
$AppNode.AppendChild($mynewXML.CreateElement("AppName")).InnerText = "NewApp"
$AppNode.AppendChild($mynewXML.CreateElement("InstallerFolder")).InnerText = 'c:\install'
$AppNode.AppendChild($mynewXML.CreateElement("Installer")).InnerText = 'msi'
$AppNode.AppendChild($mynewXML.CreateElement("InstallerOptions")).InnerText = "/qb"
$AppNode.AppendChild($mynewXML.CreateElement("Cmdlet")).InnerText = "true"
$AppNode.AppendChild($mynewXML.CreateElement("Enabled")).InnerText = "true"

Write-Host "Neue xml with commands" 
Format-Xml $mynewXML -indent 4


#
#Now it's time for the championship my student: master the XML namespaces and your training is finished
#
#

#Change Declaration (Codepage)

$newxmlDeclaration = $mynewXML.CreateXmlDeclaration("1.0", "UTF-16", $null)
$mynewXML.ReplaceChild($newxmlDeclaration, $mynewXML.FirstChild)

Write-Host "New codepage" 
Format-Xml $mynewXML -indent 4


#Namespaces
$mynewXML.DocumentElement.SetAttribute("xmlns", "http://schemas.nick-it.de/coolxml/2017/manifest")
$mynewXML.DocumentElement.SetAttribute("xmlns:ns2", "http://schemas.nick-it.de/coolxml/2018/manifest")

Write-Host "With Namespace" 
Format-Xml $mynewXML -indent 4

$mynewXML.SelectSingleNode("//Application/AppName") 

$AppNode.AppendChild($mynewXML.CreateElement("ns2:NewImportantentry",  `
"http://schemas.nick-it.de/coolxml/2018/manifest")).InnerText = "By Andreas Nick"

Format-Xml $mynewXML -indent 4

$mynewXML.SelectSingleNode("//Application/ns2:NewImportententry") 

#Create namespace manager
[System.Xml.XmlNamespaceManager] $ns = $mynewXML.NameTable
$ns.AddNamespace("ns2", "http://schemas.nick-it.de/coolxml/2018/manifest")

$mynewXML.SelectSingleNode("//Application/ns2:NewImportantentry", $ns) 

#
# That was all just.NET what a hoax! I wanted to see this in PowerShell (Bonus)
#

[xml] $Xml = @'
<?xml version="1.0" encoding="utf-8"?>
  <Book xmlns="http://:schemas-Nick-it.de/AppVBooks" >
    <projects>
      <project name="Softwarevirtualisierung mit App-V 5" date="2017-04-01">
        <editions>
          <edition language="English">2019-04-01</edition>
          <edition language="German">2017-04-01</edition>
          <edition language="French">Never-ever</edition>
        </editions>
      </project>
    </projects>
  </Book>
'@

  $namespace = @{ns="http://:schemas-Nick-it.de/AppVBooks"}
  $nodes = Select-Xml -xml $Xml -XPath "//ns:edition" -Namespace $namespace
  $nodes | %{ $_.Node }
  
  #Export/Import XML Object

  (Get-Process | Export-Clixml -Path "$env:temp\process.xml")
  $procobj =  Import-Clixml -Path "$env:temp\process.xml"
  $procobj | Get-Member


  $exportxml = $procobj | select -First 2 | ConvertTo-Xml -Depth 4 

  $exportxml.Save("$env:temp\xmlexport.xml")

  Get-Content "$env:temp\xmlexport.xml"

#
# Complex practical example
#

[xml] $unattendedxml = @'
<!-- <?xml version="1.0" encoding="utf-8"?> -->
<unattend xmlns="urn:schemas-microsoft-com:unattend">
  <settings pass="specialize">
    <component name="Microsoft-Windows-UnattendedJoin" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
      <Identification>
        <Credentials>
          <Username>Test</Username>
          <Domain></Domain>
          <Password></Password>
        </Credentials>
        <JoinDomain></JoinDomain>
        <JoinWorkgroup></JoinWorkgroup>
        <MachineObjectOU></MachineObjectOU>
      </Identification>
    </component>
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
      <ComputerName></ComputerName>
      <ProductKey></ProductKey>
      <RegisteredOrganization>NW</RegisteredOrganization>
      <RegisteredOwner>IT</RegisteredOwner>
      <DoNotCleanTaskBar>true</DoNotCleanTaskBar>
      <TimeZone>Pacific Standard Time</TimeZone>
    </component>
    <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <RunSynchronous>
        <RunSynchronousCommand wcm:action="add">
          <Description>EnableAdmin</Description>
          <Order>1</Order>
          <Path>cmd /c net user Administrator /active:yes</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Description>UnfilterAdministratorToken</Description>
          <Order>2</Order>
          <Path>cmd /c reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v FilterAdministratorToken /t REG_DWORD /d 0 /f</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Description>disable user account page</Description>
          <Order>3</Order>
          <Path>reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Setup\OOBE /v UnattendCreatedUser /t REG_DWORD /d 1 /f</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Description>disable async RunOnce</Description>
          <Order>4</Order>
          <Path>reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer /v AsyncRunOnce /t REG_DWORD /d 0 /f</Path>
        </RunSynchronousCommand>
      </RunSynchronous>
    </component>
    <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <InputLocale>0409:00000409</InputLocale>
      <SystemLocale>en-US</SystemLocale>
      <UILanguage>en-US</UILanguage>
      <UserLocale>en-US</UserLocale>
    </component>
  </settings>
  <settings pass="oobeSystem">
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
      <UserAccounts>
        <AdministratorPassword>
          <Value>Passw0rd</Value>
          <PlainText>true</PlainText>
        </AdministratorPassword>
      </UserAccounts>
      <AutoLogon>
        <Enabled>true</Enabled>
        <Username>Administrator</Username>
        <Domain>.</Domain>
        <Password>
          <Value>Passw0rd</Value>
          <PlainText>true</PlainText>
        </Password>
        <LogonCount>999</LogonCount>
      </AutoLogon>
      <Display>
        <ColorDepth></ColorDepth>
        <HorizontalResolution></HorizontalResolution>
        <RefreshRate></RefreshRate>
        <VerticalResolution></VerticalResolution>
      </Display>
      <FirstLogonCommands>
        <SynchronousCommand wcm:action="add">
          <CommandLine>wscript.exe %SystemDrive%\LTIBootstrap.vbs</CommandLine>
          <Description>Lite Touch new OS</Description>
          <Order>1</Order>
        </SynchronousCommand>
      </FirstLogonCommands>
      <OOBE>
        <HideEULAPage>true</HideEULAPage>
        <NetworkLocation>Work</NetworkLocation>
        <ProtectYourPC>1</ProtectYourPC>
        <HideLocalAccountScreen>true</HideLocalAccountScreen>
        <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
        <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
      </OOBE>
      <RegisteredOrganization>NW</RegisteredOrganization>
      <RegisteredOwner>IT</RegisteredOwner>
      <TimeZone></TimeZone>
    </component>
    <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <InputLocale>0409:00000409</InputLocale>
      <SystemLocale>en-US</SystemLocale>
      <UILanguage>en-US</UILanguage>
      <UserLocale>en-US</UserLocale>
    </component>
  </settings>
  <settings pass="offlineServicing">
    <component name="Microsoft-Windows-PnpCustomizationsNonWinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <DriverPaths>
        <PathAndCredentials wcm:keyValue="1" wcm:action="add">
          <Path>\Drivers</Path>
        </PathAndCredentials>
      </DriverPaths>
    </component>
  </settings>
</unattend>
'@

$namespace = @{wc="urn:schemas-microsoft-com:unattend"}

$nodes = Select-Xml -Xml $unattendedxml -XPath "//wc:ProductKey" -Namespace $namespace

$nodes[0].Node.InnerText = [system.guid]::NewGuid()

$nodes[0].Node

(Select-Xml -Xml $unattendedxml -XPath "//wc:ProductKey" -Namespace $namespace).node.innerText




<#
 
  Andreas Nick 2018

#>

