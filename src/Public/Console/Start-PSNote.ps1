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
        Mode          = [PSNoteMenuItems]::Main      # Main | Catalogs | Tags | Favorites | NoteList | NoteActions
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
    $state.Mode = if ($Store.Config.Main) { $Store.Config.Main } else { [PSNoteMenuItems]::Welcome }
    <#
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
        #>
    $footerItems = @(
        @{ Key = ' ^M'; Label = 'Main' },
        @{ Key = ' ^F'; Label = 'Favorites' },
        @{ Key = ' ^G'; Label = 'Catalogs' },
        @{ Key = ' ^S'; Label = 'Search' },
        @{ Key = ' ^H'; Label = 'Help' },
        @{ Key = ' ^B'; Label = 'Back' },
        @{ Key = ' ^N'; Label = 'New' },
        @{ Key = ' ^A'; Label = 'All' },
        @{ Key = ' ^O'; Label = 'Options' },
        @{ Key = ' ^Q'; Label = 'Quit' }
    )

    $exitUI = $false

    while (-not $exitUI) {
        Clear-Host
        Write-PSNotesHeaderBar -State $state

        switch ($state.Mode) {
            [PSNoteMenuItems]::AllCatalogs {
                $state.Catalog = $null
                $state.Tag = $null
                $state.ScopeNotes = @($Store.Notes)
                $state.LastList = @($state.ScopeNotes | Sort-Object Catalog, Alias)
                Write-PSNotesNoteList -Notes $state.LastList -Title $state.ScopeLabel -Store $Store
                $menu = "[#] Open  [P] Preview  [S] Search  [B] Back"
            }

            [PSNoteMenuItems]::Search {
                Invoke-PSNotesSearch -State $state -Prefill $null
            }

            [PSNoteMenuItems]::Welcome {
                Write-PSNoteWelcome
            }

            [PSNoteMenuItems]::Catalogs {
                Write-PSNotesCatalogList -Store $Store
                $menu = "[#] Open  [S] Search  [B] Back"
            }

            [PSNoteMenuItems]::Help {
                Write-Host "This is a temp holder for the Help screen until we build that out more fully." -ForegroundColor Yellow
                $menu = "[#] Open  [S] Search  [B] Back"
            }

            [PSNoteMenuItems]::Tags {
                Write-PSNotesTagList -Notes @($Store.Notes)
                $menu = "[#] Open  [S] Search  [B] Back"
            }

            [PSNoteMenuItems]::NoteList {
                Write-PSNotesNoteList -Notes $state.LastList -Title $state.ScopeLabel -Store $Store
                $menu = "[#] Open  [P] Preview  [S] Search  [B] Back"
            }

            [PSNoteMenuItems]::NoteActions {
                Write-PSNotePreview -Note $state.Note
                $f = if ($Store.IsFavorite($state.Note)) { '[U] UnFav' } else { '[F] Fav' }
                $menu = "[C] Copy  [X] Execute  $f  [B] Back"
            }

            [PSNoteMenuItems]::Favorites {
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

            [PSNoteMenuItems]::Preview {
                $note = $Notes[$i]
                $f = if ($Store.IsFavorite($note)) { '[U] UnFav' } else { '[U] Fav' }
                Write-PSNotePreview -Note $note
                $menu = "[C] Copy  [X] Execute  $f  [N] Next  [B] Back"
            }

            [PSNoteMenuItems]::Settings {
                $state.Settings = Update-PSNoteSetting -Config $state.Settings
            }

            [PSNoteMenuItems]::Exit { 
                $exitUI = $true
            }
        }

        if (-not $exitUI) {
            if ( $state.Mode -notin [PSNoteMenuItems]::NoteActions -and $state.Note ) {
                # Clear selected note when not in NoteActions
                $state.Note = $null
            }

            Write-PSNotesFooter -Items $footerItems -State $state -Menu $menu

            $sel = Read-PSNotesCommand -Prompt 'PSNotes' -Echo

            # Ctrl combos fire immediately
            if ($sel -like '^*') {
                if (Invoke-PSNotesFooterCombo -State $state -Store $Store -Combo $sel) {
                    continue
                }
            }

            # Optional: ESC behaves like Back
            if ($sel -eq 'ESC') {
                $sel = 'Q'
            }

            # Keep your existing Preview default-next behavior
            if ([string]::IsNullOrWhiteSpace($sel) -and $state.Mode -eq 'Preview') {
                $sel = 'N'
            }

            if ($state.ReturnMode[-1] -ne $state.Mode) {
                $state.ReturnMode += $state.Mode
            }

            switch ($sel.ToUpperInvariant()) {
                'M' { $state.Mode = $state.Settings.Main }
                'A' { $state.Mode = [PSNoteMenuItems]::AllCatalogs }
                'S' { $state.Mode = [PSNoteMenuItems]::Search }
                'G' { $state.Mode = [PSNoteMenuItems]::Catalogs }
                'T' { $state.Mode = [PSNoteMenuItems]::Tags }
                'O' { $state.Mode = [PSNoteMenuItems]::Settings }
                'Q' { $state.Mode = [PSNoteMenuItems]::Exit }
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
                    if ($state.Mode -eq [PSNoteMenuItems]::Preview) {
                        if ($i -ge $Notes.Count - 1 ) {
                            $state.Mode = $state.ReturnMode[-2]
                            $state.ReturnMode = $state.ReturnMode[0..($state.ReturnMode.Count - 2)]
                        }
                        else {
                            $i++
                        }
                    }
                    else {
                        Invoke-PSNotesNewNoteWizard -Store $Store

                        # Keep the UI consistent by refreshing scope notes after creation
                        if (-not $state.Catalog -and -not $state.Tag) {
                            $state.ScopeNotes = @($Store.Notes)
                        }
                        elseif ($state.Catalog) {
                            # If they’re scoped to a catalog, re-scope so the new note appears
                            Set-PSNotesCatalogScope -State $state -Catalog $state.Catalog
                        }
                        elseif ($state.Tag) {
                            # If they’re scoped to a tag, just re-run tag scope
                            Set-PSNotesTagScope -State $state -Tag $state.Tag -AllNotes @($Store.Notes)
                        }
                    }
                }
                'C' {
                    if ($state.Note) {
                        Set-Clipboard -Value $state.Note.Snippet
                        $state.Mode = $state.ReturnMode[-2]
                        $state.ReturnMode = $state.ReturnMode[0..($state.ReturnMode.Count - 2)]
                        if ($state.Settings.ExitOnCopy) {
                            $state.ExecuteOnExit = $null
                            $state.Mode = [PSNoteMenuItems]::Exit
                        }
                    }
                }
                'X' {
                    if ($state.Note) {
                        $state.ExecuteOnExit = $state.Note
                        $state.Mode = [PSNoteMenuItems]::Exit
                    }
                }
                'F' {
                    if ($state.Note) {
                        $Store.ToggleFavorite($state.Note)
                    }
                }
                'U' {
                    if ($state.Note) {
                        $Store.ToggleFavorite($state.Note)
                    }
                }
                'B' { Pop-PSNotesMode -State $state }
                default {
                    if ($sel -match '^\s*O?\s*(\d+)\s*$') {
                        $idx = [int]$Matches[1] - 1
                        switch ($state.Mode) {
                            [PSNoteMenuItems]::Catalogs {
                                $cats = @($Store.Catalogs | Sort-Object Catalog)
                                if ($idx -ge 0 -and $idx -lt $cats.Count) {
                                    Set-PSNotesCatalogScope -State $state -Catalog $cats[$idx]
                                }
                            }
                            [PSNoteMenuItems]::Tags {
                                $tags = Get-PSNotesTag -Notes @($Store.Notes)
                                if ($idx -ge 0 -and $idx -lt $tags.Count) {
                                    Set-PSNotesTagScope -State $state -Tag $tags[$idx] -AllNotes @($Store.Notes)
                                }
                            }
                            [PSNoteMenuItems]::Favorites {
                                $notes = $state.LastList
                                if ($idx -ge 0 -and $idx -lt $max) {
                                    $state.Note = $favorites[$idx]
                                    $state.Mode = [PSNoteMenuItems]::NoteActions
                                }
                            }
                            [PSNoteMenuItems]::NoteList {
                                $notes = $state.LastList
                                if ($idx -ge 0 -and $idx -lt $notes.Count) {
                                    $state.Note = $notes[$idx]
                                    $state.Mode = [PSNoteMenuItems]::NoteActions
                                }
                            }
                            [PSNoteMenuItems]::AllCatalogs {
                                $notes = $state.LastList
                                if ($idx -ge 0 -and $idx -lt $notes.Count) {
                                    $state.Note = $notes[$idx]
                                    $state.Mode = [PSNoteMenuItems]::NoteActions
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