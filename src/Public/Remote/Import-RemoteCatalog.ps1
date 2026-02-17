<#
.SYNOPSIS
    Registers or imports a remote catalog.

.DESCRIPTION
    Registers a remote catalog URL in the note store, or downloads it immediately
    as a local catalog when -AsLocal is specified.

.PARAMETER Name
    The name to register for the remote catalog.

.PARAMETER Url
    The URL of the remote catalog JSON.

.PARAMETER AsLocal
    Downloads the remote catalog immediately and creates a LOCAL catalog.
    When specified, the URL is not registered.

.PARAMETER Force
    Only applies to -AsLocal. Overwrites the local catalog if it already exists.

.PARAMETER PassThru
    Returns the created or registered catalog object.

.EXAMPLE
    PS> Import-RemoteCatalog -Name 'github' -Url 'https://example.com/psnotes.json'
    Registers the remote catalog URL for later use.

.EXAMPLE
    PS> Import-RemoteCatalog -Name 'github' -Url 'https://example.com/psnotes.json' -AsLocal
    Downloads the remote catalog and creates a local catalog.

.EXAMPLE
    PS> Import-RemoteCatalog -Name 'github' -Url 'https://example.com/psnotes.json' -AsLocal -Force -PassThru
    Overwrites the local catalog and returns the created catalog object.

.OUTPUTS
    System.Object
    Returns catalog objects when -PassThru is specified; otherwise returns nothing.

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
