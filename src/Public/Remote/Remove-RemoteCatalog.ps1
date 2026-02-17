<#
.SYNOPSIS
    Removes a remote catalog registration.

.DESCRIPTION
    Removes a registered remote catalog. Optionally converts the cached remote
    catalog to a local catalog before removing the registration.

.PARAMETER InputObject
    The remote catalog object to remove. Accepts pipeline input from
    Get-RemoteCatalog.

.PARAMETER ConvertToLocal
    Converts the cached remote catalog into a local catalog before removing
    the remote registration.

.PARAMETER Force
    Forces removal or conversion if the target already exists.

.PARAMETER PassThru
    Returns the removed catalog object.

.EXAMPLE
    PS> Get-RemoteCatalog -Catalog 'github' | Remove-RemoteCatalog
    Removes the remote catalog registration for 'github'.

.EXAMPLE
    PS> Get-RemoteCatalog -Catalog 'github' | Remove-RemoteCatalog -ConvertToLocal
    Converts the cached remote catalog to a local catalog and removes the
    remote registration.

.EXAMPLE
    PS> Get-RemoteCatalog | Remove-RemoteCatalog -Force -PassThru
    Removes all remote catalogs and returns the removed objects.

.OUTPUTS
    System.Object
    Returns catalog objects when -PassThru is specified; otherwise returns nothing.

.LINK
    Get-RemoteCatalog
    Import-RemoteCatalog
#>
function Remove-RemoteCatalog {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [RemoteCatalogSource] $InputObject,

        [switch] $ConvertToLocal,

        [switch] $Force,

        [switch] $PassThru
    )

    process {
        $action = if ($ConvertToLocal) {
            "Convert cached remote catalog to local and remove registration"
        }
        else {
            "Remove remote catalog registration"
        }

        if ($PSCmdlet.ShouldProcess($InputObject.Url, $action)) {
            $removed = $script:_noteStore.RemoveRemoteCatalog($InputObject.Url, [bool]$ConvertToLocal, [bool]$Force)
            if ($PassThru) { $removed }
        }
    }
}
