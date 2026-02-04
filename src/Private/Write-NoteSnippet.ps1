Function Write-NoteSnippet {
    <#
    .SYNOPSIS
    Used by the Copy-PSNote and Invoke-PSNote to display a menu and prompt for selection of a note
    
    .PARAMETER NoteSelection
    An array of PSNote objects to create a menu with
    
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
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

    $Prompt = "Enter the number to run (or leave blank to cancel) and hit [Enter]"
    $promptError = $false
    do {
        Write-Host $promptMenu
        if ( $promptError ) {
            Write-Host "The select must a number between 1 and $($NoteSelection.Count)" -ForegroundColor Red
        }
        $Selection = Read-Host -Prompt $Prompt
        if ([string]::IsNullOrEmpty($Selection)) {
            $promptError = $false
        }
        elseif (-not [int]::TryParse($Selection, [ref]$null)) {
            $promptError = $true
        }
        elseif ([int]$Selection -gt $NoteSelection.Count -or [int]$Selection -lt 1) {
            $promptError = $true
        }
        else {
            $promptError = $false
        }
        
    }while ($promptError)
    
    if ([string]::IsNullOrEmpty($Selection)) {
        $null
    }
    else {
        $NoteSelection[$Selection - 1]
    }
}