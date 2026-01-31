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

    $state = [pscustomobject]@{
        Mode       = 'Main'       # Main | Catalogs | Tags | NoteList | NoteActions
        ScopeLabel = 'All Catalogs'
        ScopeNotes = @($Store.Notes)
        LastList   = @()
        Catalog    = $null
        Tag        = $null
        Note       = $null
    }

    while ($true) {
        Clear-Host
        Write-PSNotesBanner
        Write-Host ""
        Write-PSNotesStatus -State $state
        Write-Host ""

        switch ($state.Mode) {

            'Main' {
                $menu = "[A] All  [S] Search  [G] Catalogs  [T] Tags  [R] Random  [Q] Quit"
                Write-Host $menu -ForegroundColor Yellow
                $sel = (Read-Host "PSNotes").Trim()

                switch ($sel.ToUpperInvariant()) {
                    'A' {
                        $state.ScopeLabel = 'All Catalogs'
                        $state.ScopeNotes = @($Store.Notes)
                        $state.LastList = @($state.ScopeNotes | Sort-Object Catalog, Alias)
                        $state.Mode = 'NoteList'
                    }
                    'S' {
                        Invoke-PSNotesSearch -State $state -Prefill $null
                    }
                    'G' { $state.Mode = 'Catalogs' }
                    'T' { $state.Mode = 'Tags' }
                    'R' {
                        $state.Note = @($Store.Notes | Get-Random)
                        $state.Mode = 'NoteActions'
                    }
                    'Q' { return }
                    default {
                        # Free-text search from main menu
                        if (-not [string]::IsNullOrWhiteSpace($sel)) {
                            Invoke-PSNotesSearch -State $state -Prefill $sel
                        }
                    }
                }
            }

            'Catalogs' {
                Write-PSNotesCatalogList -Store $Store
                Write-Host ""
                $menu = "[L] List  [S] Search  [O] Open #  [B] Back"
                Write-Host $menu -ForegroundColor Yellow

                $sel = (Read-Host "Catalogs").Trim()

                switch ($sel.ToUpperInvariant()) {
                    'Q' { return }
                    'B' { $state.Mode = 'Main' }
                    'L' {
                        # already listed; just loop
                    }
                    'S' {
                        $term = (Read-Host "Catalog search").Trim()
                        if ([string]::IsNullOrWhiteSpace($term)) { break }

                        $cats = @($Store.Catalogs | Sort-Object Catalog)
                        $rx = [regex]::new([regex]::Escape($term), 'IgnoreCase')
                        $filtered = @($cats | Where-Object { $rx.IsMatch($_.Catalog) })

                        $picked = Select-PSNotesCatalogFromList -Catalogs $filtered
                        if ($picked) { Set-PSNotesCatalogScope -State $state -Catalog $picked }
                    }
                    default {
                        # "O 3" or just "3"
                        if ($sel -match '^\s*O?\s*(\d+)\s*$') {
                            $idx = [int]$Matches[1] - 1
                            $cats = @($Store.Catalogs | Sort-Object Catalog)
                            if ($idx -ge 0 -and $idx -lt $cats.Count) {
                                Set-PSNotesCatalogScope -State $state -Catalog $cats[$idx]
                            }
                        }
                    }
                }
            }

            'Tags' {
                Write-PSNotesTagList -Notes @($Store.Notes)

                Write-Host ""
                $menu = "[O] Open #  [S] Search  [B] Back"
                Write-Host $menu -ForegroundColor Yellow

                $sel = (Read-Host "Tags").Trim()

                switch ($sel.ToUpperInvariant()) {
                    'Q' { return }
                    'B' { $state.Mode = 'Main' }
                    'S' {
                        $term = (Read-Host "Tag search").Trim()
                        if ([string]::IsNullOrWhiteSpace($term)) { break }

                        $tags = Get-PSNotesTags -Notes @($Store.Notes)
                        $rx = [regex]::new([regex]::Escape($term), 'IgnoreCase')
                        $filtered = @($tags | Where-Object { $rx.IsMatch($_) })

                        $tag = Select-PSNotesStringFromList -Items $filtered -Title "Matching Tags"
                        if ($tag) { Set-PSNotesTagScope -State $state -Tag $tag -AllNotes @($Store.Notes) }
                    }
                    default {
                        if ($sel -match '^\s*O?\s*(\d+)\s*$') {
                            $idx = [int]$Matches[1] - 1
                            $tags = Get-PSNotesTags -Notes @($Store.Notes)
                            if ($idx -ge 0 -and $idx -lt $tags.Count) {
                                Set-PSNotesTagScope -State $state -Tag $tags[$idx] -AllNotes @($Store.Notes)
                            }
                        }
                    }
                }
            }

            'NoteList' {
                Write-PSNotesNoteList -Notes $state.LastList -Title $state.ScopeLabel
                Write-Host ""
                $menu = "[#] Open  [T] Thumb  [S] Search  [B] Back"
                Write-Host $menu -ForegroundColor Yellow

                $sel = (Read-Host "Notes").Trim()

                switch ($sel.ToUpperInvariant()) {
                    'Q' { return }
                    'B' {
                        # Back goes to appropriate parent
                        $state.Mode = 'Main'
                        $state.Note = $null
                    }
                    'S' {
                        $prefill = (Read-Host "Search").Trim()
                        if (-not [string]::IsNullOrWhiteSpace($prefill)) {
                            Invoke-PSNotesSearch -State $state -Prefill $prefill
                        }
                    }
                    'T' {
                        if ($state.LastList -and $state.LastList.Count -gt 0) {
                            Invoke-PSNotesThumbThrough -Notes $state.LastList
                        }
                    }
                    default {
                        if ($sel -match '^\s*(\d+)\s*$') {
                            $idx = [int]$Matches[1] - 1
                            if ($idx -ge 0 -and $idx -lt $state.LastList.Count) {
                                $state.Note = $state.LastList[$idx]
                                $state.Mode = 'NoteActions'
                            }
                        }
                    }
                }
            }

            'NoteActions' {
                Write-PSNotePreview -Note $state.Note
                Write-Host ""
                $menu = "[C] Copy  [X] Execute  [B] Back"
                Write-Host $menu -ForegroundColor Yellow

                $sel = (Read-Host "Note").Trim()

                switch ($sel.ToUpperInvariant()) {
                    'Q' { return }
                    'B' {
                        $state.Note = $null
                        $state.Mode = 'NoteList'
                    }
                    'C' {
                        Copy-PSNotesSnippet -Note $state.Note
                        # Auto-return
                        $state.Note = $null
                        $state.Mode = 'NoteList'
                    }
                    'X' {
                        Invoke-PSNotesExecution -Note $state.Note
                        # Auto-return
                        $state.Note = $null
                        $state.Mode = 'NoteList'
                    }
                }
            }

        }
    }
}

# -----------------------------
# State setters
# -----------------------------

function Set-PSNotesCatalogScope {
    param($State, [NoteCatalog]$Catalog)

    $State.Catalog = $Catalog
    $State.Tag = $null
    $State.ScopeLabel = "Catalog: $($Catalog.Catalog)"
    $State.ScopeNotes = @($Catalog.Notes)
    $State.LastList = @($State.ScopeNotes | Sort-Object Alias)
    $State.Mode = 'NoteList'
}

function Set-PSNotesTagScope {
    param($State, [string]$Tag, [PSNote[]]$AllNotes)

    $State.Catalog = $null
    $State.Tag = $Tag
    $State.ScopeLabel = "Tag: $Tag"
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

function Write-PSNotesBanner {
    $banner = @'
██████╗ ███████╗███╗   ██╗ ██████╗ ████████╗███████╗███████╗
██╔══██╗██╔════╝████╗  ██║██╔═══██╗╚══██╔══╝██╔════╝██╔════╝
██████╔╝███████╗██╔██╗ ██║██║   ██║   ██║   █████╗  ███████╗
██╔═══╝ ╚════██║██║╚██╗██║██║   ██║   ██║   ██╔══╝  ╚════██║
██║     ███████║██║ ╚████║╚██████╔╝   ██║   ███████╗███████║
╚═╝     ╚══════╝╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚══════╝╚══════╝
'@
    Write-Host $banner -ForegroundColor Cyan
}

function Write-PSNotesStatus {
    param($State)

    $scope = $State.ScopeLabel
    if ($State.Mode -eq 'Main') { $scope = 'All Catalogs' }
    Write-Host ("Scope: {0}" -f $scope) -ForegroundColor DarkGray
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
        [string]$Title
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
        "{0,2}) [{1}] {2}" -f ($i + 1), $n.Catalog, $n.Alias | Write-Host
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
# Catalog/tag pickers (simple)
# -----------------------------

function Select-PSNotesCatalogFromList {
    param([NoteCatalog[]]$Catalogs)

    if (-not $Catalogs -or $Catalogs.Count -eq 0) { return $null }

    Clear-Host
    Write-PSNotesBanner
    Write-Host "Matching Catalogs" -ForegroundColor Cyan
    Write-Host ""

    for ($i = 0; $i -lt $Catalogs.Count; $i++) {
        "{0,2}) {1}" -f ($i + 1), $Catalogs[$i].Catalog | Write-Host
    }

    Write-Host ""
    Write-Host "[#] Open  [B] Back" -ForegroundColor Yellow
    $sel = (Read-Host "Select").Trim()
    if ($sel.ToUpperInvariant() -eq 'B') { return $null }

    if ($sel -match '^\s*(\d+)\s*$') {
        $idx = [int]$Matches[1] - 1
        if ($idx -ge 0 -and $idx -lt $Catalogs.Count) { return $Catalogs[$idx] }
    }

    return $null
}

function Select-PSNotesStringFromList {
    param([string[]]$Items, [string]$Title = "Select")

    if (-not $Items -or $Items.Count -eq 0) { return $null }

    Clear-Host
    Write-PSNotesBanner
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ""

    for ($i = 0; $i -lt $Items.Count; $i++) {
        "{0,2}) {1}" -f ($i + 1), $Items[$i] | Write-Host
    }

    Write-Host ""
    Write-Host "[#] Open  [B] Back" -ForegroundColor Yellow
    $sel = (Read-Host "Select").Trim()
    if ($sel.ToUpperInvariant() -eq 'B') { return $null }

    if ($sel -match '^\s*(\d+)\s*$') {
        $idx = [int]$Matches[1] - 1
        if ($idx -ge 0 -and $idx -lt $Items.Count) { return $Items[$idx] }
    }

    return $null
}

# -----------------------------
# Copy / Execute (prefer existing cmdlets)
# -----------------------------

function Copy-PSNotesSnippet {
    [CmdletBinding()]
    param([PSNote]$Note)

    if (-not $Note) { return }

    $copyCmd = Get-Command -Name Copy-PSNote -ErrorAction SilentlyContinue
    if ($copyCmd) {
        try { Copy-PSNote -Alias $Note.Alias; return } catch { }
    }

    if (Get-Command -Name Set-Clipboard -ErrorAction SilentlyContinue) {
        Set-Clipboard -Value $Note.Snippet
    }
    else {
        $Note.Snippet | clip.exe
    }
}

function Invoke-PSNotesExecution {
    [CmdletBinding()]
    param([PSNote]$Note)

    if (-not $Note) { return }

    $invokeCmd = Get-Command -Name Invoke-PSNote -ErrorAction SilentlyContinue
    if ($invokeCmd) {
        Invoke-PSNote -Alias $Note.Alias
        return
    }

    Invoke-Expression -Command $Note.Snippet
}

function Invoke-PSNotesThumbThrough {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSNote[]] $Notes
    )

    if (-not $Notes -or $Notes.Count -eq 0) { return }

    $i = 0

    while ($true) {
        if ($i -lt 0) { $i = 0 }

        # If we walk past the end, return to the list display
        if ($i -ge $Notes.Count) { return }

        $note = $Notes[$i]

        Clear-Host
        Write-PSNotesBanner
        Write-Host ""
        Write-Host ("Thumb: {0}/{1}" -f ($i + 1), $Notes.Count) -ForegroundColor DarkGray
        Write-Host ""

        Write-PSNotePreview -Note $note

        Write-Host ""
        $menu = "[C] Copy  [X] Execute  [N] Next  [P] Prev  [B] Back"
        Write-Host $menu -ForegroundColor Yellow

        $sel = (Read-Host "Note").Trim().ToUpperInvariant()

        switch ($sel) {
            'B' { return }

            'N' {
                $i++
                continue
            }

            'P' {
                $i--
                continue
            }

            'C' {
                Copy-PSNotesSnippet -Note $note
                # Auto-return to list display (per your request)
                return
            }

            'X' {
                Invoke-PSNotesExecution -Note $note
                # Auto-return to list display (per your request)
                return
            }

            default {
                # Enter / anything else -> Next for speed
                $i++
                continue
            }
        }
    }
}

