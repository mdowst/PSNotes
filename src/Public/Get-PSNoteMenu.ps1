<#
.SYNOPSIS
Displays an interactive, paged console menu for browsing and selecting PSNotes.

.DESCRIPTION
Get-PSNoteMenu presents PSNotes in an interactive terminal-based menu with paging support.
Users can navigate through notes, select one by number, and then choose an action such as:

- Output the note content
- Copy the note to the clipboard
- Execute the snippet
- Execute a referenced script path

The menu is designed to provide a streamlined console experience for browsing catalogs,
favorites, or filtered note sets. When multiple pages are present, page indicators
(for example, "Page 1/3") are shown.

This cmdlet is intended for interactive use within the current console session.

.FUNCTIONALITY
PSNotes Interactive UI

.ROLE
Interactive

.COMPONENT
UI

.PARAMETER InputObject
A collection of PSNote objects to display. Accepts pipeline input from Get-PSNote.

If not provided, all notes are displayed by default.

.EXAMPLE
PS> Get-PSNoteMenu

Displays all notes in an interactive menu.

.OUTPUTS
PSNote

.NOTES
- Designed for interactive terminal use.
- Supports paging when the number of notes exceeds the configured page size.
- After selecting a note, a secondary action menu is displayed (output, copy, run).
- See also: Get-PSNote, Get-PSNoteAlias, Start-PSNote
#>
function Get-PSNoteMenu {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param(
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    begin { $notes = @() }

    process {
        if ($PSBoundParameters.ContainsKey('InputObject') -and $null -ne $InputObject) {
            $notes += , $InputObject
        }
    }

    end {
        if (-not $notes -or $notes.Count -eq 0) { $notes = @(Get-PSNote) }
        if (-not $notes -or $notes.Count -eq 0) { Write-Host "No notes found."; return }

        # --- Screen sizing (Terminal-friendly) ---
        $winWidth = 120
        $winHeight = 30
        try {
            $raw = $Host.UI.RawUI
            $w = [int]$raw.WindowSize.Width
            $h = [int]$raw.WindowSize.Height
            if ($w -le 0) { $w = [int]$raw.BufferSize.Width }
            if ($h -le 0) { $h = [int]$raw.BufferSize.Height }
            if ($w -gt 0) { $winWidth = $w }
            if ($h -gt 0) { $winHeight = $h }
        }
        catch { 
            $winWidth = 120
            $winHeight = 30
        }

        $winWidth = [Math]::Max(20, [int]$winWidth)
        $winHeight = [Math]::Max(10, [int]$winHeight)

        # Reserve lines for header/pager + prompt
        $reservedLines = 4
        $rowsPerPage = [Math]::Max(1, $winHeight - $reservedLines)

        $count = $notes.Count
        $numWidth = ($count.ToString()).Length
        $gap = 2

        # Build display items
        $display = for ($i = 0; $i -lt $count; $i++) {
            $n = $notes[$i]

            $catalog = if ($n.PSObject.Properties.Match('Catalog').Count -gt 0) { $n.Catalog } else { $null }
            if ([string]::IsNullOrWhiteSpace($catalog)) { $catalog = 'Default' }

            $label = if ($n.PSObject.Properties.Match('Alias').Count -gt 0) { $n.Alias } else { $null }
            if ([string]::IsNullOrWhiteSpace($label)) {
                $label = if ($n.PSObject.Properties.Match('Note').Count -gt 0) { $n.Note } else { $null }
            }
            if ([string]::IsNullOrWhiteSpace($label)) { $label = '<unnamed>' }

            [pscustomobject]@{
                Index = ($i + 1)
                Text  = ("{0," + $numWidth + "}) [{1}] {2}") -f ($i + 1), $catalog, $label
            }
        }

        # Max *length* (not max *string*)
        $maxTextLen = ($display | ForEach-Object { $_.Text.Length } | Measure-Object -Maximum).Maximum
        if (-not $maxTextLen -or $maxTextLen -lt 1) { $maxTextLen = 10 }

        $colWidth = [int][Math]::Min([Math]::Max(10, $maxTextLen + $gap), $winWidth)
        $cols = [int][Math]::Floor($winWidth / [double]$colWidth)
        if ($cols -lt 1) { $cols = 1 }

        $itemsPerPage = [Math]::Max(1, $rowsPerPage * $cols)

        $totalPages = [int][Math]::Ceiling($count / [double]$itemsPerPage)
        if ($totalPages -lt 1) { $totalPages = 1 }

        $pageIndex = 0  # 0-based

        while ($true) {
            Clear-Host

            $pageStart = $pageIndex * $itemsPerPage
            $pageEnd = [Math]::Min($pageStart + $itemsPerPage - 1, $count - 1)

            $pageItems = $display[$pageStart..$pageEnd]
            $pageCount = $pageItems.Count
            $pageRows = [int][Math]::Ceiling($pageCount / [double]$cols)

            # Page header ONLY if more than one page
            if ($totalPages -gt 1) {
                Write-Host ("Page {0}/{1}" -f ($pageIndex + 1), $totalPages)
                Write-Host ""
            }

            for ($r = 0; $r -lt $pageRows; $r++) {
                $lineParts = for ($c = 0; $c -lt $cols; $c++) {
                    $idx = ($r * $cols) + $c
                    if ($idx -ge $pageCount) { continue }

                    $cell = $pageItems[$idx].Text
                    if ($c -lt ($cols - 1)) { $cell = $cell.PadRight($colWidth) }
                    $cell
                }
                Write-Host ($lineParts -join '')
            }

            $isLastPage = ($pageIndex -ge ($totalPages - 1))

            if ($totalPages -eq 1 -or $isLastPage) {
                $prompt = "Enter # to select, or 'q' to quit"
            }
            else {
                $prompt = "Enter # to select, Enter for next page, or 'q' to quit"
            }

            $resp = Read-Host $prompt

            if ([string]::IsNullOrWhiteSpace($resp)) {
                if (-not $isLastPage) { $pageIndex++ }
                continue
            }

            if ($resp -match '^(q|quit|exit)$') { return }

            $chosen = 0
            if (-not [int]::TryParse($resp, [ref]$chosen)) {
                Write-Host "Please enter a number, Enter, or 'q'." -ForegroundColor Yellow
                Start-Sleep -Milliseconds 700
                continue
            }

            if ($chosen -lt 1 -or $chosen -gt $count) {
                Write-Host "Invalid selection: $chosen" -ForegroundColor Yellow
                Start-Sleep -Milliseconds 700
                continue
            }

            $selected = $notes[$chosen - 1]

            # --- SECOND MENU: Copy / Run / Output ---
            Clear-Host

            $selCatalog = if ($selected.PSObject.Properties.Match('Catalog').Count -gt 0) { $selected.Catalog } else { 'Default' }
            if ([string]::IsNullOrWhiteSpace($selCatalog)) { $selCatalog = 'Default' }

            $selLabel = if ($selected.PSObject.Properties.Match('Alias').Count -gt 0) { $selected.Alias } else { $null }
            if ([string]::IsNullOrWhiteSpace($selLabel)) {
                $selLabel = if ($selected.PSObject.Properties.Match('Note').Count -gt 0) { $selected.Note } else { '<unnamed>' }
            }

            Write-Host "$(($selected | Out-String).TrimEnd())"
            Write-Host "`n----------------------------------------"
            Write-Host "[C] Copy to clipboard"
            Write-Host "[R] Run"
            Write-Host "[ENTER] Exit"
            Write-Host ""

            $action = (Read-Host "Choose action").Trim()

            switch -Regex ($action) {
                '^(c|copy)$' {
                    # Prefer Snippet, else fall back to Note (or empty)
                    $text = $null
                    if ($selected.PSObject.Properties.Match('Snippet').Count -gt 0) { $text = $selected.Snippet }
                    if ([string]::IsNullOrWhiteSpace($text) -and $selected.PSObject.Properties.Match('Note').Count -gt 0) {
                        $text = $selected.Note
                    }
                    if ($null -eq $text) { $text = '' }

                    if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
                        $text | Set-Clipboard
                        Write-Host "Copied to clipboard." -ForegroundColor Green
                    } else {
                        Write-Host "Set-Clipboard not available in this session." -ForegroundColor Yellow
                    }

                    Start-Sleep -Milliseconds 700
                    return
                }

                '^(r|run)$' {
                    try {
                        # Execute in the current scope (like the rest of PSNotes patterns)
                        Invoke-PSNote -Note $selected -ErrorAction Stop
                    }
                    catch {
                        Write-Host ("Failed to run snippet: {0}" -f $_.Exception.Message) -ForegroundColor Red
                    }

                    return
                }

                default {
                    return $selected
                }
            }
        }
    }
}