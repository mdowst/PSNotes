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
