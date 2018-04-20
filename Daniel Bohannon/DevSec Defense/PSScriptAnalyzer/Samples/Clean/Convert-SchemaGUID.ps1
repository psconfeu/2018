# List of  Guids not properly defined in AD but used
# Used to initialize GuidCache. 
New-Variable -Name GuidCache -Force -Option AllScope -Scope Script -Description "Cached GUIDs from AD. :: [redtoo]" 
$Script:GuidCache = @{
    "a05b8cc2-17bc-4802-a710-e7c15ab866a2" = "Autoenroll"
    "00000000-0000-0000-0000-000000000000" = "All"
}
$Script:GuidObjects = @{}
function Convert-SchemaGUIDtoLDAPDisplayName {
    <#
        .Synopsis
            Convert-SchemaGUIDtoLDAPDisplayName converts a schema GUId to the LDAP Display Name
    
        .DESCRIPTION
            Convert-SchemaGUIDtoLDAPDisplayName converts a schema GUId to the LDAP Display Name
    
        .PARAMETER  guid
            The schema guid to lookup

        .EXAMPLE
            PS C:\\>  Convert-SchemaGUIDtoLDAPDisplayName "bf96793f-0de6-11d0-a285-00aa003049e2"

        .INPUTS
            System.String
    
        .OUTPUTS
            System.String
    
        .NOTES
            NAME:      Convert-SchemaGUIDtoLDAPDisplayName
            AUTHOR:    Patrick Sczepanski
            VERSION    20120105
            #Requires -Version 2.0
    
        .LINK
            http://PoshCode.org/embed/3788
    #>
    [Cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true,Position=0)]
        [GUID]$guid 
    )

        $ThisFunctionName = $MyInvocation.MyCommand.Name

        if ( $GuidCache.Contains($guid.Tostring()) ) {
            Write-Verbose "[$ThisFunctionName] :: Found in script cache."
            return $GuidCache.($guid.Tostring())
        } 
        $RootDSE = [DirectoryServices.DirectoryEntry]"LDAP://RootDSE"
        $escapedGuid =  "\\" + ((([GUID]$guid).ToByteArray() |% {"{0:x}" -f $_}) -join '\\')
        $Filter = "(&(|(objectcategory=classschema)(objectcategory=attributeschema)(objectcategory=controlAccessRight))" +
                  "(|(schemaIdGuid=$escapedGuid)(rightsGuid=$guid)))"
        Write-Verbose "[$ThisFunctionName] :: Query Schema and configuration"
        Write-Verbose "[$ThisFunctionName] :: Base $($RootDSE.configurationNamingContext)"
        Write-Verbose "[$ThisFunctionName] :: Filter $Filter"
        Write-Verbose "[$ThisFunctionName] :: Attr ldapdisplayname"
        $SearchResult = Search-AD -Searchbase $RootDSE.configurationNamingContext `
                      -Filter $Filter `
                      -Attributes ("distinguishedname","name","ldapdisplayname","displayname") `
                      -Scope Subtree `
                      -FindOne  `
                      -ReferralChasing Subordinate `
                      -PageSize 0 
                      

        if ( $SearchResult.properties.distinguishedname[0] -like "*Schema*" ) {
            $GuidCache.($guid.Tostring()) = $SearchResult.properties.ldapdisplayname[0]
            Write-Verbose "[$ThisFunctionName] :: Found in schema, added to cache."
            Write-Output $SearchResult.properties.ldapdisplayname[0]
        } elseif ( $SearchResult.properties.distinguishedname[0] -like "*Configuration*" )  {
            $GuidCache.($guid.Tostring()) = $SearchResult.properties.displayname[0]
            Write-Verbose "[$ThisFunctionName] :: Found in configuration context, added to cache."
            Write-Output $SearchResult.properties.displayname[0]
        } else {
            Write-Verbose "[$ThisFunctionName] :: Not found return GUID, added 'unknown'."
            Write-Output $guid.ToString()
        }    
}
#endregion Convert-Schema
