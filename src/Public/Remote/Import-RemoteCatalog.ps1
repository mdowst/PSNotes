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
