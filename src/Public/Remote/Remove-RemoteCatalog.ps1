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
