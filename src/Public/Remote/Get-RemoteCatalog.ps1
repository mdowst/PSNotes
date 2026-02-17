<#
.SYNOPSIS
    Gets configured remote catalogs.

.DESCRIPTION
    Retrieves one or more remote catalogs from the note store configuration. 
    Remote catalogs are external sources used to import notes from other locations.

.PARAMETER Catalog
    The name or wildcard pattern of the catalog to retrieve. 
    Supports wildcards (e.g., 'git*' to match 'github', 'gitlab', etc.).
    Default value is '*' which returns all configured remote catalogs.

.EXAMPLE
    PS> Get-RemoteCatalog
    Returns all configured remote catalogs.

.EXAMPLE
    PS> Get-RemoteCatalog -Catalog 'github'
    Returns the remote catalog named 'github'.

.EXAMPLE
    PS> Get-RemoteCatalog -Catalog 'git*'
    Returns all remote catalogs matching the pattern 'git*'.

.NOTES
    This cmdlet requires the PSNotes module to be initialized with remote catalogs configured.

.OUTPUTS
    System.Object
    Returns remote catalog configuration objects or an empty array if no catalogs are configured.

.LINK
    Import-RemoteCatalog
    Remove-RemoteCatalog
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
