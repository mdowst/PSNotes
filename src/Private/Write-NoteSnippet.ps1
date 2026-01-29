Function Write-NoteSnippet {
    <#
    .SYNOPSIS
    Used by the Copy-PSNote and Invoke-PSNote to display a menu and prompt for selection of a note
    
    .PARAMETER NoteSelection
    An array of PSNote objects to create a menu with
    
    #>
    [cmdletbinding()]
    param(
        [PSNote[]]$NoteSelection
    )
    $i = 0
    $noteMenu = $NoteSelection | ForEach-Object {
        $i++
        $_ | Select-Object @{l = 'Nbr'; e = { $i } }, *
    } 
    $promptMenu = $noteMenu | Format-Table Nbr, Note, Alias, Details, Tags -AutoSize | Out-String

    $Prompt = "$($promptMenu)Enter the number to run (or leave blank to cancel) and hit [Enter]"
    $Selection = Read-Host -Prompt $Prompt
    if ([string]::IsNullOrEmpty($Selection)) {
        $null
    }
    elseif (-not [int]::TryParse($Selection, [ref]$null)) {
        Write-Error "The select must a number between 1 and $($NoteSelection.Count)"
    }
    elseif ([int]$Selection -gt $NoteSelection.Count -or [int]$Selection -lt 1) {
        Write-Error "The select must be between 1 and $($NoteSelection.Count)"
    }
    else {
        $NoteSelection[$Selection - 1].Snippet
    }
}