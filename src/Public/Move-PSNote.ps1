<#
.SYNOPSIS
    Moves a note to a different catalog.

.DESCRIPTION
    Moves a note from its current catalog to another catalog. Supports
    confirmation prompts via ShouldProcess.

.PARAMETER InputObject
    The note to move. Accepts pipeline input from Get-PSNote.

.PARAMETER DestinationCatalog
    The target catalog name to move the note to.

.PARAMETER Force
    Overwrites the destination note if it already exists.

.PARAMETER PassThru
    Returns the moved note object.

.EXAMPLE
    PS> Get-PSNote -Note 'Install-Module' | Move-PSNote -DestinationCatalog 'Work'
    Moves the note named 'Install-Module' to the 'Work' catalog.

.EXAMPLE
    PS> Get-PSNote -Catalog 'Personal' | Move-PSNote -DestinationCatalog 'Archive' -Force
    Moves all notes from 'Personal' to 'Archive', overwriting duplicates.

.EXAMPLE
    PS> Get-PSNote -Note 'Install-Module' | Move-PSNote -DestinationCatalog 'Work' -PassThru
    Moves the note and returns the moved note object.

.OUTPUTS
    PSNote
    Returns note objects when -PassThru is specified; otherwise returns nothing.

.LINK
    Get-PSNote
    Set-PSNote
    Remove-PSNote
#>
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
