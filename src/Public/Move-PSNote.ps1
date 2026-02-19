<#
.SYNOPSIS
Moves one or more PSNotes to a different catalog.

.DESCRIPTION
Move-PSNote changes the catalog assignment of existing PSNotes. This allows you to reorganize
your note library as it grows without recreating notes.

You can specify notes directly by name, alias, or other supported parameters, or pipe PSNote
objects from Get-PSNote.

This cmdlet updates the note metadata and persists the changes to the PSNotes store.
Supports ShouldProcess, enabling the use of -WhatIf and -Confirm.

.FUNCTIONALITY
PSNotes Notes

.ROLE
Public

.COMPONENT
Notes

.PARAMETER InputObject
One or more PSNote objects to move. Accepts pipeline input from Get-PSNote.

.PARAMETER DestinationCatalog
The destination catalog to move the note(s) into.

.PARAMETER Force
Suppresses confirmation prompts when moving notes.

.PARAMETER PassThru
Returns the moved PSNote objects.


.EXAMPLE
PS> Get-PSNote -Catalog 'General' | Move-PSNote -DestinationCatalog 'Archive'

Moves all notes from the General catalog to the Archive catalog.

.EXAMPLE
PS> Get-PSNote -Tag 'Legacy' | Move-PSNote -DestinationCatalog 'Archive' -Force -PassThru

Moves all notes tagged 'Legacy' into the Archive catalog without prompting and returns the updated notes.

.OUTPUTS
PSNote

.NOTES
- Supports -WhatIf and -Confirm through ShouldProcess.
- Use Get-PSNote to identify notes before moving them.
- See also: Get-PSNote, Set-PSNote, Remove-PSNote
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
        $label = if ($InputObject.Alias) { $InputObject.Alias } else { $InputObject.Name }

        if ($PSCmdlet.ShouldProcess("[$($InputObject.Catalog)] $label", "Move to '$DestinationCatalog'")) {
            $moved = $script:_noteStore.MoveNote($InputObject, $DestinationCatalog, [bool]$Force)
            if ($PassThru) { $moved }
        }
    }
}
