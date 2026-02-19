<#
.SYNOPSIS
Registers a remote PSNotes catalog or imports it as a local catalog.

.DESCRIPTION
Import-RemoteCatalog adds a remote catalog source to PSNotes or downloads it immediately as a local
catalog.

By default, the cmdlet registers the remote catalog URL in the PSNotes store under the provided name.
This allows you to keep the catalog “linked” for future imports.

When -AsLocal is specified, the remote catalog is downloaded immediately and saved as a LOCAL catalog.
In this mode, the URL is not registered as a remote source. Use -Force to overwrite an existing local
catalog with the same name.

.FUNCTIONALITY
PSNotes Remote Catalogs

.ROLE
Public

.COMPONENT
RemoteCatalogs

.PARAMETER Name
The name to register for the remote catalog (or the name of the local catalog to create when -AsLocal is used).

.PARAMETER Url
The URL of the remote catalog JSON.

.PARAMETER AsLocal
Downloads the remote catalog immediately and creates a LOCAL catalog.

When specified, the remote catalog URL is not registered.

.PARAMETER Force
Only applies to -AsLocal.

Overwrites the local catalog if it already exists.

.PARAMETER PassThru
Returns the created or registered catalog object.

.EXAMPLE
PS> Import-RemoteCatalog -Name 'github' -Url 'https://example.com/psnotes.json'

Registers the remote catalog URL for later use.

.EXAMPLE
PS> Import-RemoteCatalog -Name 'github' -Url 'https://example.com/psnotes.json' -AsLocal

Downloads the remote catalog immediately and creates a local catalog. The URL is not registered.

.EXAMPLE
PS> Import-RemoteCatalog -Name 'github' -Url 'https://example.com/psnotes.json' -AsLocal -Force -PassThru

Overwrites the existing local catalog and returns the created catalog object.

.OUTPUTS
System.Object

.NOTES
- -AsLocal creates a local catalog immediately and does not register the URL as a remote catalog.
- Use Get-RemoteCatalog to view registered remote sources.
- See also: Get-RemoteCatalog, Remove-RemoteCatalog

.LINK
    Get-RemoteCatalog
    Remove-RemoteCatalog
#>
function Import-RemoteCatalog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $Url,

        # If set: downloads immediately and creates a LOCAL catalog. Does NOT register the URL.
        [switch] $AsLocal,

        # Only applies to -AsLocal. Overwrite local catalog if it exists.
        [switch] $Force,

        [switch] $PassThru
    )

    if ($AsLocal) {
        $local = $script:_noteStore.ImportRemoteCatalogAsLocal($Name, $Url, [bool]$Force)
        if ($PassThru) { return $local }
        return
    }

    $script:_noteStore.RegisterRemoteCatalog($Name, $Url) | ForEach-Object {
        if ($PassThru) { $_ }
    }
}
