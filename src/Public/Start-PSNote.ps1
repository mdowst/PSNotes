function Start-PSNote {
    [CmdletBinding()]
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
        Write-PSNotesHeaderBar -Store $Store -State $state

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
                                $tags = Get-PSNotesTags -Notes @($Store.Notes)
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

# -----------------------------
# State setters
# -----------------------------

function Set-PSNotesCatalogScope {
    param($State, [NoteCatalog]$Catalog)

    $State.Catalog = $Catalog
    $State.ScopeNotes = @($Catalog.Notes)
    $State.LastList = @($State.ScopeNotes | Sort-Object Alias)
    $State.Mode = 'NoteList'
}

function Set-PSNotesTagScope {
    param($State, [string]$Tag, [PSNote[]]$AllNotes)

    $State.Tag = $Tag
    $State.ScopeNotes = @($AllNotes | Where-Object { $_.Tags -contains $Tag })
    $State.LastList = @($State.ScopeNotes | Sort-Object Catalog, Alias)
    $State.Mode = 'NoteList'
}

function Invoke-PSNotesSearch {
    param($State, [string]$Prefill)

    $term = if ($Prefill) { $Prefill } else { (Read-Host "Search").Trim() }
    if ([string]::IsNullOrWhiteSpace($term)) { return }

    $rx = [regex]::new([regex]::Escape($term), 'IgnoreCase')

    $results = @(
        $State.ScopeNotes | Where-Object {
            $rx.IsMatch($_.Alias) -or
            $rx.IsMatch($_.Note) -or
            $rx.IsMatch($_.Details) -or
            $rx.IsMatch($_.Snippet) -or
            ($_.Tags -and ($_.Tags | Where-Object { $rx.IsMatch($_) }))
        } | Sort-Object Catalog, Alias
    )

    $State.LastList = $results
    $State.Mode = 'NoteList'
}

# -----------------------------
# Rendering helpers
# -----------------------------

function Write-PSNotesHeaderBar {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [NoteStore] $Store,
        [Parameter(Mandatory)]
        $State,

        [string] $Title = 'PSNOTES SNIPPET LIBRARY'
    )
    $scopeText = Get-PSNotesScopeText -State $state
    $width = $Host.UI.RawUI.WindowSize.Width
    if ( $width -lt 78) { $width = 78 }
    $time = (Get-Date).ToString('HH:mm')

    # Line 1: Title + time (right aligned)
    $left = " $Title"
    $right = $time
    $pad = $width - ($left.Length + $right.Length)
    if ($pad -lt 1) { $pad = 1 }
    Write-Host ($left + (' ' * $pad) + $right) -ForegroundColor $state.Settings.ForegroundColor -BackgroundColor $state.Settings.BackgroundColor

    # Line 2: Scope (left), padded
    $pad = [math]::Floor(($width - $ScopeText.Length) / 2)
    if (($width - $ScopeText.Length) % 2 -ne 0) {
        $pad--
    }
    Write-Host (" " * $pad) -NoNewline
    Write-Host $ScopeText -ForegroundColor $state.Settings.ForegroundColor -BackgroundColor $state.Settings.BackgroundColor -NoNewline
    Write-Host (" " * $pad)

    Write-Host ""
    Write-Host ""
    <# Line 3: Stats
    $catalogCount = $Store.Catalogs.Count
    $noteCount = $Store.Notes.Count

    # If you implemented Store.Metadata or similar, this is fastest:
    $favoriteCount =
    if ($Store.PSObject.Properties.Name -contains 'Metadata' -and $Store.Metadata) { $Store.Metadata.Favorites.Count }
    else { 0 }

    $stats = " Catalogs: $catalogCount   Notes: $noteCount   Favorites: $favoriteCount"
    Write-Host ($stats.PadRight($width)) -ForegroundColor $state.Settings.ForegroundColor -BackgroundColor $state.Settings.BackgroundColor
    #>
}

function Get-PSNotesScopeText {
    param($State)

    $c = 'All'
    $t = 'All'
    if ($State.Catalog) {
        $c = $State.Catalog.Catalog
    }
    if ($State.Tag) {
        $t = 'Tag:' + $State.Tag
    }


    return "Catalog: $c | Tag: $t"
}

function Write-PSNotesFooter {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable[]] $Items,
        [Parameter(Mandatory)]
        $State
    )
    [int] $Rows = 2
    $width = $Host.UI.RawUI.WindowSize.Width
    if ( $width -lt 78) { $width = 78 }
    $perRow = [Math]::Ceiling($Items.Count / $Rows)

    for ($r = 0; $r -lt $Rows; $r++) {
        $rowItems = $Items | Select-Object -Skip ($r * $perRow) -First $perRow
        if (-not $rowItems -or $rowItems.Count -eq 0) { continue }

        $colWidth = [Math]::Floor($width / $rowItems.Count)
        if ($colWidth -lt 12) { $colWidth = 12 }

        foreach ($it in $rowItems) {
            $key = [string]$it.Key
            $label = [string]$it.Label

            # Build column, but render in two parts:
            # [ key ] label.... (all on footer bg, except key block)
            $colInnerMax = $colWidth

            # Key chunk (ensure it fits)
            $keyChunk = $key
            if ($keyChunk.Length -gt 4) { $keyChunk = $keyChunk.Substring(0, 4) }
            $keyChunk = $keyChunk.PadRight(4)

            # Remaining space for " label"
            $remaining = $colInnerMax - 4
            if ($remaining -lt 1) { $remaining = 1 }

            $labelChunk = (" " + $label)
            if ($labelChunk.Length -gt $remaining) {
                $labelChunk = $labelChunk.Substring(0, $remaining)
            }
            $labelChunk = $labelChunk.PadRight($remaining)

            # Render
            Write-Host $keyChunk   -NoNewline -ForegroundColor $state.Settings.BackgroundColor -BackgroundColor $state.Settings.ForegroundColor
            Write-Host $labelChunk -NoNewline -ForegroundColor $state.Settings.ForegroundColor -BackgroundColor $state.Settings.BackgroundColor
        }

        # Finish line, and make sure the whole line is footer background
        Write-Host "" -ForegroundColor $state.Settings.ForegroundColor -BackgroundColor $state.Settings.BackgroundColor
    }

    # Reset colors after footer
    Write-Host "" -NoNewline
}

function Write-PSNotesCatalogList {
    param([NoteStore]$Store)

    $cats = @($Store.Catalogs | Sort-Object Catalog)
    Write-Host "Catalogs" -ForegroundColor Cyan
    Write-Host ""

    for ($i = 0; $i -lt $cats.Count; $i++) {
        $c = $cats[$i]
        $count = @($c.Notes).Count
        "{0,2}) {1}  ({2} notes)" -f ($i + 1), $c.Catalog, $count | Write-Host
    }
}

function Get-PSNotesTags {
    param([PSNote[]]$Notes)

    @(
        $Notes |
        Where-Object { $_.Tags } |
        ForEach-Object { $_.Tags } |
        ForEach-Object { $_ } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Sort-Object -Unique
    )
}

function Write-PSNotesTagList {
    param([PSNote[]]$Notes)

    $tags = Get-PSNotesTags -Notes $Notes
    Write-Host "Tags" -ForegroundColor Cyan
    Write-Host ""

    for ($i = 0; $i -lt $tags.Count; $i++) {
        "{0,2}) {1}" -f ($i + 1), $tags[$i] | Write-Host
    }
}

function Write-PSNotesNoteList {
    param(
        [PSNote[]]$Notes,
        [string]$Title,
        [Parameter(Mandatory)][NoteStore] $Store
    )

    Write-Host $Title -ForegroundColor Cyan
    Write-Host ""

    if (-not $Notes -or $Notes.Count -eq 0) {
        Write-Host "No notes found." -ForegroundColor DarkYellow
        return
    }

    # Simple list; easy to add paging later
    $max = [Math]::Min(30, $Notes.Count)
    for ($i = 0; $i -lt $max; $i++) {
        $n = $Notes[$i]
        $star = if ($Store.IsFavorite($n)) { '*' } else { ' ' }
        "{0,2}){1} [{2}] {3}" -f ($i + 1), $star, $n.Note, $n.Alias | Write-Host
    }

    if ($Notes.Count -gt $max) {
        Write-Host ""
        Write-Host ("Showing first {0} of {1}. Refine search to narrow results." -f $max, $Notes.Count) -ForegroundColor DarkGray
    }
}

function Write-PSNotePreview {
    param([PSNote]$Note)

    if (-not $Note) { return }

    Write-Host ("[{0}] {1}" -f $Note.Catalog, $Note.Alias) -ForegroundColor Cyan
    if ($Note.Tags) { Write-Host ("Tags: {0}" -f ($Note.Tags -join ', ')) -ForegroundColor DarkGray }
    if ($Note.Note) { Write-Host ("Title: {0}" -f $Note.Note) -ForegroundColor Gray }
    if ($Note.Details) { Write-Host $Note.Details -ForegroundColor Gray }
    Write-Host ""
    Write-Host "Snippet:" -ForegroundColor Yellow
    Write-Host $Note.Snippet
}

# -----------------------------
# Copy / Execute (prefer existing cmdlets)
# -----------------------------

function Invoke-PSNotesExecution {
    [CmdletBinding()]
    param([PSNote]$Note)

    if (-not $Note) { return }

    #$invokeCmd = Get-Command -Name Invoke-PSNote -ErrorAction SilentlyContinue
    #if ($invokeCmd) {
    #    Invoke-PSNote -Alias $Note.Alias
    #    return
    #}

    Invoke-Expression -Command $Note.Snippet
}

