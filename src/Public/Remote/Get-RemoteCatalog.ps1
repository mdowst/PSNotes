<#
.SYNOPSIS
Gets remote catalogs registered with PSNotes.

.DESCRIPTION
Get-RemoteCatalog retrieves remote catalog registrations from the PSNotes configuration. Remote catalogs
represent external sources (such as a URL) that can be imported into PSNotes or kept registered for future
imports.

Use -Catalog to return a specific remote catalog by name, or provide a wildcard pattern to match multiple
registrations. If no remote catalogs are configured, this cmdlet returns an empty array.

.FUNCTIONALITY
PSNotes Remote Catalogs

.ROLE
Public

.COMPONENT
RemoteCatalogs

.PARAMETER Catalog
The name or wildcard pattern of the remote catalog registration to retrieve.

The default value is '*' which returns all configured remote catalogs.

.EXAMPLE
PS> Get-RemoteCatalog

Returns all configured remote catalogs.

.EXAMPLE
PS> Get-RemoteCatalog -Catalog 'github'

Returns the remote catalog registration named 'github'.

.EXAMPLE
PS> Get-RemoteCatalog -Catalog 'git*'

Returns all remote catalog registrations with names that match the pattern 'git*'.

.OUTPUTS
System.Object

.NOTES
- Remote catalog registrations are stored in the PSNotes configuration (for example, in the note store config file).
- If the PSNotes store is not initialized or no remote catalogs are configured, an empty array is returned.
- See also: Import-RemoteCatalog, Remove-RemoteCatalog

.LINK
    Remove-RemoteCatalog
    Import-RemoteCatalog
#>
function Get-RemoteCatalog {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$false)]
        [string]$Catalog = '*'
    )

    if (-not $script:_noteStore.Config -or -not $script:_noteStore.Config.RemoteCatalogs) { return @() }

    $remote = $script:_noteStore.Config.RemoteCatalogs | Where-Object { $_.Name -like $Catalog }
    return $remote
}
