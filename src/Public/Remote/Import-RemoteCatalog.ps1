function Import-RemoteCatalog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Name,
        [Parameter(Mandatory)]
        [string] $Url
    )

    $script:_noteStore.RegisterRemoteCatalog($Name,$Url)
}