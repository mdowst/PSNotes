# -----------------------------
# State setters
# -----------------------------

function Set-PSNotesCatalogScope {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param($State, [NoteCatalog]$Catalog)

    $State.Catalog = $Catalog
    $State.ScopeNotes = @($Catalog.Notes)
    $State.LastList = @($State.ScopeNotes | Sort-Object Alias)
    $State.Mode = [PSNoteMenuItems]::NoteList
}

function Set-PSNotesTagScope {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param($State, [string]$Tag, [PSNote[]]$AllNotes)

    $State.Tag = $Tag
    $State.ScopeNotes = @($AllNotes | Where-Object { $_.Tags -contains $Tag })
    $State.LastList = @($State.ScopeNotes | Sort-Object Catalog, Alias)
    $State.Mode = [PSNoteMenuItems]::NoteList
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
    $State.Mode = [PSNoteMenuItems]::NoteList
}

# -----------------------------
# Rendering helpers
# -----------------------------

function Write-PSNotesHeaderBar {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param(
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


    $r = "Catalog: $c | Tag: $t"
    $r = "$($State.Mode.ToString())"
    return $r
}


function Write-PSNotesFooter {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param(
        [Parameter(Mandatory)]
        [hashtable[]] $Items,
        [Parameter(Mandatory)]
        $State,
        [Parameter(Mandatory = $false)]
        $Menu = $null
    )
    [int] $Rows = 2
    $width = $Host.UI.RawUI.WindowSize.Width
    if ( $width -lt 78) { $width = 78 }
    $perRow = [Math]::Ceiling($Items.Count / $Rows)

    $footerTop = (Get-PSNotesViewportRow -FromBottom ($Rows)) - 1 # top row of footer block

    if($Menu) {
        [Console]::SetCursorPosition(0, $footerTop - 2)
        Write-Host $Menu -ForegroundColor Yellow
    }

    # (optional) clear footer area first
    for ($i = 0; $i -lt $Rows-1; $i++) {
        [Console]::SetCursorPosition(0, $footerTop + $i)
        Write-Host (' ' * $width) -NoNewline
    }

    for ($r = 0; $r -lt $Rows; $r++) {
        $rowItems = $Items | Select-Object -Skip ($r * $perRow) -First $perRow
        if (-not $rowItems -or $rowItems.Count -eq 0) { continue }

        $colWidth = [Math]::Floor($width / $rowItems.Count)
        if ($colWidth -lt 12) { $colWidth = 12 }

        [Console]::SetCursorPosition(0, $footerTop + $r)
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
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

function Get-PSNotesTag {
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param([PSNote[]]$Notes)

    $tags = Get-PSNotesTag -Notes $Notes
    Write-Host "Tags" -ForegroundColor Cyan
    Write-Host ""

    for ($i = 0; $i -lt $tags.Count; $i++) {
        "{0,2}) {1}" -f ($i + 1), $tags[$i] | Write-Host
    }
}

function Write-PSNotesNoteList {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param([PSNote]$Note)

    if (-not $Note) { return }
 
    Write-Host "Catalog : " -NoNewline
    Write-Host $Note.Catalog -ForegroundColor Cyan
    Write-Host "Alias   : " -NoNewline
    Write-Host $Note.Alias -ForegroundColor Cyan
    if ($Note.Note) { Write-Host ("Title   : {0}" -f $Note.Note) -ForegroundColor Gray }
    if ($Note.Tags) { Write-Host ("Tags    : {0}" -f ($Note.Tags -join ', ')) -ForegroundColor DarkGray }
    
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '')]
    param([PSNote]$Note)

    if (-not $Note) { return }

    #$invokeCmd = Get-Command -Name Invoke-PSNote -ErrorAction SilentlyContinue
    #if ($invokeCmd) {
    #    Invoke-PSNote -Alias $Note.Alias
    #    return
    #}

    Invoke-Expression -Command $Note.Snippet
}

function Invoke-PSNotesNewNoteWizard {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param(
        [Parameter(Mandatory)]
        $Store
    )

    Clear-Host
    Write-Host "PSNotes - New Note Wizard" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    Write-Host ""

    # --- Catalog selection ---
    $catalogs = @($Store.Catalogs | Sort-Object Catalog)

    Write-Host "Select a catalog:" -ForegroundColor Cyan

    for ($c = 0; $c -lt $catalogs.Count; $c++) {
        Write-Host ("  {0}) {1}" -f ($c + 1), $catalogs[$c].Catalog)
    }

    Write-Host "Enter a number (1..$($catalogs.Count)). To create a new catalog, enter a name instead of a number." -ForegroundColor DarkGray

    $catalogName = $null
    while ([string]::IsNullOrWhiteSpace($catalogName)) {
        $catSel = (Read-Host "Catalog").Trim()

        if ($catSel -match '^\d+$') {
            $idx = [int]$catSel

            if ($idx -ge 1 -and $idx -le $catalogs.Count) {
                $catalogName = $catalogs[$idx - 1].Catalog
            }
            else {
                Write-Host "Invalid catalog selection." -ForegroundColor Red
            }
        }
        elseif (-not [string]::IsNullOrWhiteSpace($catSel)) {
            $newCat = $catSel
            # If it already exists (case-insensitive), just use existing
            $existing = $catalogs | Where-Object { $_.Catalog -ieq $newCat } | Select-Object -First 1
            $catalogName = if ($existing) { $existing.Catalog } else { $newCat }
        }
            
        if ([string]::IsNullOrWhiteSpace($catalogName)) {
            Write-Host "Invalid catalog selection." -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host ("Catalog: {0}" -f $catalogName) -ForegroundColor DarkYellow
    Write-Host ""

    # --- Note name ---
    $noteName = $null
    while ([string]::IsNullOrWhiteSpace($noteName)) {
        $noteName = (Read-Host "Note name").Trim()
        if ([string]::IsNullOrWhiteSpace($noteName)) {
            Write-Host "Note name is required." -ForegroundColor Red
        }
    }

    # --- Kind (Snippet vs Script) ---
    Write-Host ""
    Write-Host "Note type:" -ForegroundColor Cyan
    Write-Host "  1) Snippet (inline code)" -ForegroundColor Gray
    Write-Host "  2) Script  (path to .ps1)" -ForegroundColor Gray

    $kind = $null
    while ($kind -notin 'Snippet', 'Script') {
        $k = (Read-Host "Type #").Trim()
        switch ($k) {
            '1' { $kind = 'Snippet' }
            '2' { $kind = 'Script' }
            default { Write-Host "Choose 1 or 2." -ForegroundColor Red }
        }
    }

    # --- Snippet or ScriptPath ---
    $snippet = $null
    $scriptPath = $null

    if ($kind -eq 'Snippet') {
        Write-Host ""
        Write-Host "Enter snippet text. (Tip: you can paste multi-line text.)" -ForegroundColor Cyan
        $snippet = Read-Host "Snippet"
        if ([string]::IsNullOrWhiteSpace($snippet)) {
            Write-Host "Snippet cannot be empty." -ForegroundColor Red
            Read-Host "Press Enter to cancel"
            return
        }
    }
    else {
        Write-Host ""
        $scriptPath = (Read-Host "Script path (.ps1)").Trim()
        if ([string]::IsNullOrWhiteSpace($scriptPath)) {
            Write-Host "Script path cannot be empty." -ForegroundColor Red
            Read-Host "Press Enter to cancel"
            return
        }

        if (-not (Test-Path -Path $scriptPath)) {
            Write-Host ("Script file not found: {0}" -f $scriptPath) -ForegroundColor Red
            Read-Host "Press Enter to cancel"
            return
        }
    }

    # --- Optional alias ---
    Write-Host ""
    $alias = (Read-Host "Alias (optional; leave blank for none)").Trim()
    if ($alias -and -not $alias -match '^[a-zA-Z0-9_-]+$') {
        Write-Host "Alias can only contain letters, numbers, dashes, and underscores." -ForegroundColor Red
        Read-Host "Press Enter to cancel"
        return
    }

    # --- Optional tags ---
    Write-Host ""
    do {
        $tagInput = (Read-Host "Tags (optional; comma-separated) enter 'L' to list current tags").Trim()
        if ($tagInput -eq 'L') {
            Write-Host "$($Store.Notes | ForEach-Object { $_.Tags } | Where-Object { $_ } | Sort-Object -Unique | Select-Object @{l='Tag';e={$_}} | Format-Wide -AutoSize | Out-String)"  -ForegroundColor DarkGray
        }
    } while ($tagInput -eq 'L')
    $tags = @()
    if (-not [string]::IsNullOrWhiteSpace($tagInput)) {
        $tags = @(
            $tagInput -split ',' |
            ForEach-Object { $_.Trim() } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            Select-Object -Unique
        )
    }

    Write-Host ""
    Write-Host "Confirm note:" -ForegroundColor Green
    Write-Host ("  Catalog : {0}" -f $catalogName)
    Write-Host ("  Note    : {0}" -f $noteName)
    Write-Host ("  Alias   : {0}" -f $alias)
    if ($tags.Count -gt 0) {
        Write-Host ("  Tags    : {0}" -f ($tags -join ', '))
    }
    Write-Host ""
    $confirm = Read-Host "Press Enter to create the note, or 'C' to cancel"
    if ($confirm -eq 'C') {
        Write-Host "Note creation cancelled." -ForegroundColor Yellow
        return
    }
    # --- Create note ---
    try {
        if ($kind -eq 'Snippet') {
            New-PSNote -Note $noteName -Snippet $snippet -Catalog $catalogName -Alias $alias -Tags $tags | Out-Null
        }
        else {
            New-PSNote -Note $noteName -ScriptPath $scriptPath -Catalog $catalogName -Alias $alias -Tags $tags | Out-Null
        }
    }
    catch {
        Write-Host ""
        Write-Host ("Failed to create note: {0}" -f $_.Exception.Message) -ForegroundColor Red
        Write-Host ""
        Read-Host "Press Enter to return to PSNotes"
    }
}

function Get-PSNotesViewportRow {
    param([int]$FromBottom = 0) # 0 = very bottom visible row
    return [Console]::WindowTop + [Console]::WindowHeight - 1 - $FromBottom
}
