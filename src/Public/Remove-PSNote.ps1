<#
.SYNOPSIS
Removes one or more PSNotes from the note store.

.DESCRIPTION
Remove-PSNote deletes notes from the PSNotes store. You can target notes by name, alias,
catalog, tag, or by piping PSNote objects from Get-PSNote.

This cmdlet updates the store immediately and permanently removes the selected notes.
Supports ShouldProcess, enabling the use of -WhatIf and -Confirm for safer operations.

Use -Force to suppress confirmation prompts where applicable.

.FUNCTIONALITY
PSNotes Notes

.ROLE
Public

.COMPONENT
Notes

.PARAMETER Name
The name of the note to remove. Wildcards may be supported depending on implementation.

.PARAMETER Alias
The alias of the note to remove.

.PARAMETER Catalog
Removes notes from the specified catalog.

.PARAMETER Tag
Removes notes that contain one or more specified tags.

.PARAMETER InputObject
One or more PSNote objects to remove. Accepts pipeline input from Get-PSNote.

.PARAMETER Force
Suppresses confirmation prompts.

.PARAMETER PassThru
Returns the removed PSNote objects.

.EXAMPLE
PS> Remove-PSNote -Name 'OldNote'

Removes the note named 'OldNote'.

.EXAMPLE
PS> Get-PSNote -Catalog 'Archive' | Remove-PSNote

Removes all notes in the Archive catalog.

.EXAMPLE
PS> Remove-PSNote -Alias 'azvm' -WhatIf

Shows what would happen if the note with alias 'azvm' were removed.

.EXAMPLE
PS> Get-PSNote -Tag 'Legacy' | Remove-PSNote -Force -PassThru

Removes all notes tagged 'Legacy' without prompting and returns the removed note objects.

.OUTPUTS
PSNote

.NOTES
- Supports -WhatIf and -Confirm through ShouldProcess.
- Deletions are permanent once committed.
- Use Get-PSNote to preview notes before removing them.
- See also: Get-PSNote, New-PSNote, Set-PSNote, Move-PSNote
#>
Function Remove-PSNote {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', DefaultParameterSetName = 'Note')]
    param(
        # Pipeline input from Get-PSNote
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'ByObject')]
        [object]$InputObject,

        # Discovery params (match Get-PSNote)
        [Parameter(Mandatory = $false, ParameterSetName = 'Note')]
        [string]$Note = '*',

        [Parameter(Mandatory = $false, ParameterSetName = 'Note')]
        [string]$Tag,

        [Parameter(Mandatory = $false, ParameterSetName = 'Note')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Search')]
        [string[]]$Catalog,

        [Parameter(Mandatory = $true, ParameterSetName = 'Search')]
        [string]$SearchString,

        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    begin {
        Test-PSNotesInitalize

        if ($Force -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }

        $candidates = New-Object System.Collections.Generic.List[object]
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ByObject') {
            if ($null -ne $InputObject -and
                $null -ne $InputObject.PSObject.Properties['Note'] -and
                $null -ne $InputObject.PSObject.Properties['Catalog']) {
                $candidates.Add($InputObject) | Out-Null
            }
            return
        }

        # Use Get-PSNote for discovery so Remove stays consistent with Get behavior.
        $gpParams = @{}
        if ($PSCmdlet.ParameterSetName -eq 'Search') {
            $gpParams['SearchString'] = $SearchString
        } else {
            $gpParams['Note'] = $Note
            if ($Tag) { $gpParams['Tag'] = $Tag }
        }

        if ($Catalog) { $gpParams['Catalog'] = $Catalog }

        foreach ($n in @(Get-PSNote @gpParams)) {
            $candidates.Add($n) | Out-Null
        }
    }

    end {
        # De-dupe by Catalog+Note (Get-PSNote can return duplicates if the store contains them)
        $unique = @{}
        foreach ($n in $candidates) {
            if ($null -eq $n) { continue }
            $key = "{0}::{1}" -f $n.Catalog, $n.Note
            if (-not $unique.ContainsKey($key)) { $unique[$key] = $n }
        }

        if ($unique.Count -eq 0) {
            Write-Verbose "No matching notes found. No action taken."
            return
        }

        $removed = New-Object System.Collections.Generic.List[object]

        foreach ($n in $unique.Values) {
            $desc = "Removing note '{0}' from catalog '{1}'" -f $n.Note, $n.Catalog
            if ($PSCmdlet.ShouldProcess($desc)) {
                $script:_noteStore.RemoveNote($n.Note, $n.Catalog)
                $removed.Add($n) | Out-Null
            }
        }

        $removed
    }
}