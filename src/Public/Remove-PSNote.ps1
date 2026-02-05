Function Remove-PSNote {
    <#
    .SYNOPSIS
        Remove one or more PSNotes from the note store.

    .DESCRIPTION
        You can remove notes by piping results from Get-PSNote, or by using the same
        discovery parameters (Note/Tag/Catalog/SearchString) to select notes to remove.

    .PARAMETER InputObject
        Pipeline input (typically from Get-PSNote).

    .PARAMETER Note
        Note name pattern (wildcards supported). Defaults to '*'.

    .PARAMETER Tag
        Filter by tag (exact match, consistent with Get-PSNote).

    .PARAMETER Catalog
        Filter by catalog name (wildcards supported; accepts multiple values).

    .PARAMETER SearchString
        Free-text search across Note/Alias/Details/Snippet/Tags.

    .PARAMETER Force
        Suppress confirmation prompts (still honors -WhatIf).

    .EXAMPLE
        Get-PSNote -SearchString 'cred' -Catalog 'Work*' | Remove-PSNote

    .EXAMPLE
        Remove-PSNote -Note 'cred*' -Catalog 'Default'

    .EXAMPLE
        Remove-PSNote -SearchString 'token' -Catalog 'Work*','Personal*' -Force

    .LINK
        https://github.com/mdowst/PSNotes
    #>
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