# -----------------------------
# State setters
# -----------------------------

function Set-PSNotesCatalogScope {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param($State, [NoteCatalog]$Catalog)

    $State.Catalog = $Catalog
    $State.ScopeNotes = @($Catalog.Notes)
    $State.LastList = @($State.ScopeNotes | Sort-Object Alias)
    $State.Mode = 'NoteList'
}

function Set-PSNotesTagScope {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
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


    return "Catalog: $c | Tag: $t"
}

function Write-PSNotesFooter {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
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

    Write-Host ("[{0}] {1}" -f $Note.Catalog, $Note.Alias) -ForegroundColor Cyan
    if ($Note.Tags) { Write-Host ("Tags: {0}" -f ($Note.Tags -join ', ')) -ForegroundColor DarkGray }
    if ($Note.Note) { Write-Host ("Title: {0}" -f $Note.Note) -ForegroundColor Gray }
    if ($Note.Details) { Write-Host $Note.Details -ForegroundColor Gray }
    Write-Host ""
    Write-Host "Snippet:" -ForegroundColor Yellow
    Write-Host $Note.Snippet
}

function Write-PSNotePreview {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param($Note)

    Write-Host ""
    Write-Host "Alias: $($Note.Alias)" -ForegroundColor Cyan
    Write-Host "Tags : $($Note.Tags -join ', ')" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host $Note.Snippet -ForegroundColor White
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

