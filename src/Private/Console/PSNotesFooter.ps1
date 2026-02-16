function Write-PSNotesFooter {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param(
        [Parameter(Mandatory)]
        $State,
        [Parameter(Mandatory = $false)]
        $Menu = $null
    )

    $Items = [PSNoteMenuItem]::GetMain()

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
            $keyChunk = " $key"
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

function Invoke-PSNotesFooterCombo {
    <#
      Maps '^X' tokens to your footer actions.
      Returns $true if handled (meaning caller should continue loop), else $false.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $State,
        [Parameter(Mandatory)] [string] $Combo
    )

    switch ($Combo) {
        '^M' { $State.Mode = $State.Settings.Main; return $true }
        '^A' { $State.Mode = [PSNoteMenuItem]::AllCatalogs;      return $true }
        '^S' { $State.Mode = [PSNoteMenuItem]::Search;           return $true }
        '^G' { $State.Mode = [PSNoteMenuItem]::Catalogs;         return $true }
        '^T' { $State.Mode = [PSNoteMenuItem]::Tags;             return $true }
        '^H' { $State.Mode = [PSNoteMenuItem]::Help;             return $true }
        '^F' { $State.Mode = [PSNoteMenuItem]::Favorites;        return $true }
        '^O' { $State.Mode = [PSNoteMenuItem]::Settings;         return $true }
        '^Q' { $State.Mode = [PSNoteMenuItem]::Quit;             return $true }
        '^C' { $State.Mode = [PSNoteMenuItem]::Quit;             return $true }
        '^N' { $State.Mode = [PSNoteMenuItem]::NewNote;          return $true }
        default { return $false }
    }
}