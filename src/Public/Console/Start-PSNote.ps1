function Start-PSNote {
    <#
    .SYNOPSIS
        Launch the PSNotes interactive UI

    .DESCRIPTION
        Starts the interactive PSNotes terminal UI for browsing, searching,
        previewing, copying, and executing notes across catalogs, tags,
        and favorites.

    .EXAMPLE
        Start-PSNote

        Opens the PSNotes interactive UI.

    .EXAMPLE
        Initialize-PSNoteStore
        Start-PSNote

        Initializes the note store and then opens the UI.

    .LINK
        https://github.com/mdowst/PSNotes
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseProcessBlockForPipelineCommand', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param()

    # ---------- Init ----------
    $Store = if ($script:_noteStore -is [NoteStore]) {
        $script:_noteStore
    }
    else {
        [NoteStore]::new()
    }

    # ---------- State ----------
    $state = [NoteConsoleState]::new($Store)
    
    # Default view: Favorites if any exist; otherwise Catalogs
    $favorites = @($Store.GetFavorites())
       

    $exitUI = $false

    while (-not $exitUI) {
        Clear-Host
        Write-PSNotesHeaderBar -State $state
        $menu = ""
        $skipRead = ""
        $skipUI = $false
        switch -Exact ($state.Mode) {
            ([PSNoteMenuItem]::Main) { Write-Host "Main Menu" -ForegroundColor Cyan }
            ([PSNoteMenuItem]::Catalogs) { Write-Host "Catalog Menu" -ForegroundColor Cyan }
            ([PSNoteMenuItem]::Tags) { Write-Host "Tags Menu" -ForegroundColor Cyan }
            ([PSNoteMenuItem]::Favorites) {
                Write-Host "Favorites Menu" -ForegroundColor Cyan 
                $pageIndex = 0
                $state.LastList = Write-PSNotesFavoriteList -Store $Store
            }
            ([PSNoteMenuItem]::Settings) { Write-Host "Settings Menu" -ForegroundColor Cyan }
            ([PSNoteMenuItem]::Search) { Write-Host "Search Menu" -ForegroundColor Cyan }
            ([PSNoteMenuItem]::Help) { Write-Host "Help Menu" -ForegroundColor Cyan }
            ([PSNoteMenuItem]::Back) { 
                Pop-PSNotesMode -State $state
                $skipUI = $true
            }
            ([PSNoteMenuItem]::Quit) { Write-Host "Quit Menu" -ForegroundColor Cyan }
            ([PSNoteMenuItem]::Welcome) { Write-Host "Welcome Menu" -ForegroundColor Cyan }
            ([PSNoteMenuItem]::AllCatalogs) {
                Write-Host "All Catalogs Menu" -ForegroundColor Cyan 
                $pageIndex = 0
                $state.LastList = Write-PSNotesAllCatalogsList -Store $Store
            }
            ([PSNoteMenuItem]::Preview) {
                Write-Host "Preview Menu" -ForegroundColor Cyan 
                $note = $state.LastList[$pageIndex]
                $f = if ($Store.IsFavorite($note)) { '[U] UnFav' } else { '[U] Fav' }
                Write-PSNotePreview -Note $note
                $menu = "[C] Copy  [X] Execute  $f  [N] Next  [P] Previous"
            }
            ([PSNoteMenuItem]::NewNote) { Write-Host "New Note Menu" -ForegroundColor Cyan }
            ([PSNoteMenuItem]::NoteActions) {
                Write-Host "Note Actions Menu" -ForegroundColor Cyan 
                Write-PSNotePreview -Note $state.Note
                $f = if ($Store.IsFavorite($state.Note)) { '[U] UnFav' } else { '[F] Fav' }
                $menu = "[C] Copy  [X] Execute  $f "
            }
            ([PSNoteMenuItem]::Quit) { 
                $exitUI = $true
            }
        }

        if (-not $exitUI -and -not $skipUI) {
            if ( $state.Mode -notin [PSNoteMenuItem]::NoteActions -and $state.Note ) {
                # Clear selected note when not in NoteActions
                $state.Note = $null
            }

            Write-PSNotesFooter -State $state -Menu $menu

            if ([string]::IsNullOrWhiteSpace($skipRead)) {
                $sel = Read-PSNotesCommand -Prompt 'PSNotes' -Echo
            }
            else {
                $sel = $skipRead
            }

            if ($state.ReturnMode[-1] -ne $state.Mode) {
                $state.ReturnMode += $state.Mode
            }

            # Keep your existing Preview default-next behavior
            if ([string]::IsNullOrWhiteSpace($sel) -and $state.Mode -eq [PSNoteMenuItem]::Preview) {
                $sel = 'N'
            }
            if($state.Mode -eq [PSNoteMenuItem]::Preview -and $sel -match '^\s*([Nn])\s*$') {
                $pageIndex++
                continue
            }

            # Ctrl combos fire immediately
            $fromKey = [PSNoteMenuItem]::FromKey($sel)
            if ($fromKey) {
                $state.Mode = $fromKey
                continue
            }
 
            # Optional: ESC behaves like Back
            if ($sel -eq 'ESC') {
                $state.Mode = [PSNoteMenuItem]::Quit
                continue
            }

    

            if ($sel -match '^\s*O?\s*(\d+)\s*$') {
                $idx = [int]$Matches[1] - 1
                switch -Exact ($state.Mode) {
                    ([PSNoteMenuItem]::Catalogs) {
                        $cats = @($Store.Catalogs | Sort-Object Catalog)
                        if ($idx -ge 0 -and $idx -lt $cats.Count) {
                            Set-PSNotesCatalogScope -State $state -Catalog $cats[$idx]
                        }
                    }
                    ([PSNoteMenuItem]::Tags) {
                        $tags = Get-PSNotesTag -Notes @($Store.Notes)
                        if ($idx -ge 0 -and $idx -lt $tags.Count) {
                            Set-PSNotesTagScope -State $state -Tag $tags[$idx] -AllNotes @($Store.Notes)
                        }
                    }
                    ([PSNoteMenuItem]::Favorites) {
                        $pageIndex = 0
                        $notes = $state.LastList
                        if ($idx -ge 0 -and $idx -lt $max) {
                            $state.Note = $favorites[$idx]
                            $state.Mode = [PSNoteMenuItem]::NoteActions
                        }
                    }
                    ([PSNoteMenuItem]::NoteList) {
                        $pageIndex = 0
                        $notes = $state.LastList
                        if ($idx -ge 0 -and $idx -lt $notes.Count) {
                            $state.Note = $notes[$idx]
                            $state.Mode = [PSNoteMenuItem]::NoteActions
                        }
                    }
                    ([PSNoteMenuItem]::AllCatalogs) {
                        $pageIndex = 0
                        $notes = $state.LastList
                        if ($idx -ge 0 -and $idx -lt $notes.Count) {
                            $state.Note = $notes[$idx]
                            $state.Mode = [PSNoteMenuItem]::NoteActions
                        }
                    }
                }
            }
            # Free-text search from main menu
            elseif (-not [string]::IsNullOrWhiteSpace($sel)) {
                Invoke-PSNotesSearch -State $state -Prefill $sel
            }
        }
    }

    # UI is fully exited at this point
    Clear-Host

    if ($state.ExecuteOnExit) {
        Write-Host ""
        Write-Host ("Executing: {0}" -f $state.Note.Alias) -ForegroundColor Yellow
        Start-Sleep -Milliseconds 300
        Invoke-PSNotesExecution -Note $state.ExecuteOnExit
    }
}