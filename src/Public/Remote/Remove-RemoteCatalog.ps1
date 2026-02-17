function Remove-RemoteCatalog {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [RemoteCatalogSource] $InputObject,

        # Return the removed config entry
        [switch] $PassThru
    )

    process {
        if ($PSCmdlet.ShouldProcess($InputObject.Url, "Remove remote catalog registration and delete cache")) {
            $removed = $script:_noteStore.RemoveRemoteCatalog($InputObject.Url, [bool]$true)
            if ($PassThru) { $removed }
        }
    }
}
