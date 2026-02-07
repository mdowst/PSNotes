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
    $state = [pscustomobject]@{
        Mode          = 'Main'       # Main | Catalogs | Tags | Favorites | NoteList | NoteActions
        ReturnMode    = @()
        ScopeLabel    = 'All'
        ScopeNotes    = @($Store.Notes)
        LastList      = @()
        Catalog       = $null
        Tag           = $null
        Note          = $null
        ExecuteOnExit = $null  # [PSNote] or $null
        Settings      = $Store.Config
    }
    
    # Default view: Favorites if any exist; otherwise Catalogs
    $favorites = @($Store.GetFavorites())
    $state.Mode = if ($favorites.Count -gt 0) { 'Favorites' } else { 'Catalogs' }

    $footerItems = @(
        @{ Key = '[M]'; Label = 'Main' },
        @{ Key = '[F]'; Label = 'Favorites' },
        @{ Key = '[G]'; Label = 'Catalogs' },
        @{ Key = '[S]'; Label = 'Search' },
        @{ Key = '[H]'; Label = 'Help' },
        @{ Key = '[B]'; Label = 'Back' },
        @{ Key = '[A]'; Label = 'All' },
        @{ Key = '[T]'; Label = 'Tags' },
        @{ Key = '[O]'; Label = 'Options' },
        @{ Key = '[Q]'; Label = 'Quit' }
    )

    $exitUI = $false

    while (-not $exitUI) {
        Clear-Host
        Write-PSNotesHeaderBar -State $state

        switch ($state.Mode) {
            'AllCatalogs' {
                $state.Catalog = $null
                $state.Tag = $null
                $state.ScopeNotes = @($Store.Notes)
                $state.LastList = @($state.ScopeNotes | Sort-Object Catalog, Alias)
                Write-PSNotesNoteList -Notes $state.LastList -Title $state.ScopeLabel -Store $Store
                $menu = "[#] Open  [P] Preview  [S] Search  [B] Back"
            }

            'Search' {
                Invoke-PSNotesSearch -State $state -Prefill $null
            }

            'Catalogs' {
                Write-PSNotesCatalogList -Store $Store
                $menu = "[#] Open  [S] Search  [B] Back"
            }

            'Tags' {
                Write-PSNotesTagList -Notes @($Store.Notes)
                $menu = "[#] Open  [S] Search  [B] Back"
            }

            'NoteList' {
                Write-PSNotesNoteList -Notes $state.LastList -Title $state.ScopeLabel -Store $Store
                $menu = "[#] Open  [P] Preview  [S] Search  [B] Back"
            }

            'NoteActions' {
                Write-PSNotePreview -Note $state.Note
                $f = if ($Store.IsFavorite($state.Note)) { '[U] UnFav' } else { '[U] Fav' }
                $menu = "[C] Copy  [X] Execute  $f  [B] Back"
            }

            'Favorites' {
                $favorites = @($Store.GetFavorites() | Sort-Object Catalog, Alias)

                if (-not $favorites -or $favorites.Count -eq 0) {
                    Write-Host "No favorites yet." -ForegroundColor DarkYellow
                    Write-Host ""
                }
                else {
                    # show list
                    $max = [Math]::Min(30, $favorites.Count)
                    for ($i = 0; $i -lt $max; $i++) {
                        $n = $favorites[$i]
                        $label = "[$($n.Note)] $($n.Alias)"
                        "{0,2}) {1}" -f ($i + 1), $label | Write-Host
                    }

                    if ($favorites.Count -gt $max) {
                        Write-Host ""
                        Write-Host ("Showing first {0} of {1}. (Favorites)" -f $max, $favorites.Count) -ForegroundColor DarkGray
                    }
                }
                $menu = "[#] Open  [P] Preview  [B] Back"
            }

            'Preview' {
                $note = $Notes[$i]
                $f = if ($Store.IsFavorite($note)) { '[U] UnFav' } else { '[U] Fav' }
                Write-PSNotePreview -Note $note
                $menu = "[C] Copy  [X] Execute  $f  [N] Next  [B] Back"
            }

            'Exit' { 
                $exitUI = $true
            }
        }

        if (-not $exitUI) {
            if ( $state.Mode -notin 'NoteActions' -and $state.Note ) {
                # Clear selected note when not in NoteActions
                $state.Note = $null
            }

            Write-Host "`n$menu`n" -ForegroundColor Yellow
            Write-PSNotesFooter -Items $footerItems -State $state
            $sel = (Read-Host "PSNotes").Trim()

            if ($state.ReturnMode[-1] -ne $state.Mode) {
                $state.ReturnMode += $state.Mode
            }
            if ([string]::IsNullOrWhiteSpace($sel) -and $state.Mode -eq 'Preview') {
                $sel = 'N'
            }
            switch ($sel.ToUpperInvariant()) {
                'M' { $state.Mode = $state.Settings.Main }
                'A' { $state.Mode = 'AllCatalogs' }
                'S' { $state.Mode = 'Search' }
                'G' { $state.Mode = 'Catalogs' }
                'T' { $state.Mode = 'Tags' }
                'F' { $state.Mode = 'Favorites' }
                'O' { $state.Mode = 'Settings' }
                'Q' { $state.Mode = 'Exit' }
                'P' { 
                    $i = 0
                    if ($state.LastList -and $state.LastList.Count -gt 0) {
                        $Notes = $state.LastList
                        $state.Mode = 'Preview'
                    }
                    elseif ($favorites -and $favorites.Count -gt 0) {
                        $Notes = $favorites
                        $state.Mode = 'Preview'
                    }
                    else {
                        $Notes = @()
                    }
                }
                'N' {
                    if ($i -ge $Notes.Count - 1 ) { 
                        $state.Mode = $state.ReturnMode[-2]
                        $state.ReturnMode = $state.ReturnMode[0..($state.ReturnMode.Count - 2)] 
                    }
                    else {
                        $i++
                    }
                }
                'C' {
                    if ($state.Note) {
                        Set-Clipboard -Value $state.Note.Snippet
                        $state.Mode = $state.ReturnMode[-2]
                        $state.ReturnMode = $state.ReturnMode[0..($state.ReturnMode.Count - 2)]
                        if ($state.Settings.ExitOnCopy) {
                            $state.ExecuteOnExit = $null
                            $state.Mode = 'Exit'
                        }
                    }
                }
                'X' {
                    if ($state.Note) {
                        $state.ExecuteOnExit = $state.Note
                        $state.Mode = 'Exit'
                    }
                }
                'U' {
                    if ($state.Note) {
                        $Store.ToggleFavorite($state.Note)
                    }
                }
                'B' {
                    $state.Mode = $state.ReturnMode[-2]
                    $state.ReturnMode = $state.ReturnMode[0..($state.ReturnMode.Count - 2)]
                }
                default {
                    if ($sel -match '^\s*O?\s*(\d+)\s*$') {
                        $idx = [int]$Matches[1] - 1
                        switch ($state.Mode) {
                            'Catalogs' {
                                $cats = @($Store.Catalogs | Sort-Object Catalog)
                                if ($idx -ge 0 -and $idx -lt $cats.Count) {
                                    Set-PSNotesCatalogScope -State $state -Catalog $cats[$idx]
                                }
                            }
                            'Tags' {
                                $tags = Get-PSNotesTag -Notes @($Store.Notes)
                                if ($idx -ge 0 -and $idx -lt $tags.Count) {
                                    Set-PSNotesTagScope -State $state -Tag $tags[$idx] -AllNotes @($Store.Notes)
                                }
                            }
                            'Favorites' {
                                $notes = $state.LastList
                                if ($idx -ge 0 -and $idx -lt $max) {
                                    $state.Note = $favorites[$idx]
                                    $state.Mode = 'NoteActions'
                                }
                            }
                            'NoteList' {
                                $notes = $state.LastList
                                if ($idx -ge 0 -and $idx -lt $notes.Count) {
                                    $state.Note = $notes[$idx]
                                    $state.Mode = 'NoteActions'
                                }
                            }
                            'AllCatalogs' {
                                $notes = $state.LastList
                                if ($idx -ge 0 -and $idx -lt $notes.Count) {
                                    $state.Note = $notes[$idx]
                                    $state.Mode = 'NoteActions'
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

