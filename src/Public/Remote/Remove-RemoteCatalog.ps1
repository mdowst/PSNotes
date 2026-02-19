<#
.SYNOPSIS
Removes a remote catalog registration from PSNotes.

.DESCRIPTION
Remove-RemoteCatalog unregisters one or more remote catalog sources from the PSNotes configuration.

By default, this cmdlet removes only the remote registration and leaves any previously imported
local catalog content unchanged.

If -ConvertToLocal is specified, the cached remote catalog is converted into a local catalog
before removing the remote registration. This allows you to keep the notes while removing the
remote dependency.

This cmdlet supports pipeline input from Get-RemoteCatalog and implements ShouldProcess,
allowing the use of -WhatIf and -Confirm.

.FUNCTIONALITY
PSNotes Remote Catalogs

.ROLE
Public

.COMPONENT
RemoteCatalogs

.PARAMETER InputObject
A remote catalog object to remove. Accepts pipeline input from Get-RemoteCatalog.

.PARAMETER ConvertToLocal
Converts the cached remote catalog into a local catalog before removing the remote registration.

.PARAMETER Force
Suppresses confirmation prompts when removing a remote catalog registration.

.PARAMETER PassThru
Returns the removed (or converted) catalog object.

.EXAMPLE
PS> Get-RemoteCatalog

Lists all registered remote catalogs.

.EXAMPLE
PS> Get-RemoteCatalog -Catalog 'github' | Remove-RemoteCatalog

Removes the 'github' remote catalog registration.

.EXAMPLE
PS> Get-RemoteCatalog -Catalog 'github' | Remove-RemoteCatalog -ConvertToLocal

Converts the cached remote catalog into a local catalog and removes the remote registration.

.EXAMPLE
PS> Get-RemoteCatalog | Remove-RemoteCatalog -Force

Removes all remote catalog registrations without prompting.

.OUTPUTS
System.Object

.NOTES
- Supports -WhatIf and -Confirm through ShouldProcess.
- Removing a remote catalog does not delete local catalogs unless explicitly converted or managed separately.
- See also: Get-RemoteCatalog, Import-RemoteCatalog

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
