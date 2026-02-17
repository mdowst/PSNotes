function Move-PSNote {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSNote] $InputObject,

        [Parameter(Mandatory)]
        [string] $DestinationCatalog,

        [switch] $Force,

        [switch] $PassThru
    )

    process {
        $label = if ($InputObject.Alias) { $InputObject.Alias } else { $InputObject.Note }

        if ($PSCmdlet.ShouldProcess("[$($InputObject.Catalog)] $label", "Move to '$DestinationCatalog'")) {
            $moved = $script:_noteStore.MoveNote($InputObject, $DestinationCatalog, [bool]$Force)
            if ($PassThru) { $moved }
        }
    }
}
