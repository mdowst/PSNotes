function Invoke-PSNotesFooterCombo {
    <#
      Maps '^X' tokens to your footer actions.
      Returns $true if handled (meaning caller should continue loop), else $false.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] $State,
        [Parameter(Mandatory)] $Store,
        [Parameter(Mandatory)] [string] $Combo
    )

    switch ($Combo) {
        '^M' { $State.Mode = $State.Settings.Main; return $true }
        '^A' { $State.Mode = [PSNoteMenuItems]::AllCatalogs;      return $true }
        '^S' { $State.Mode = [PSNoteMenuItems]::Search;           return $true }
        '^G' { $State.Mode = [PSNoteMenuItems]::Catalogs;         return $true }
        '^T' { $State.Mode = [PSNoteMenuItems]::Tags;             return $true }
        '^H' { $State.Mode = [PSNoteMenuItems]::Help;             return $true }
        '^F' { $State.Mode = [PSNoteMenuItems]::Favorites;        return $true }
        '^O' { $State.Mode = [PSNoteMenuItems]::Settings;         return $true }
        '^Q' { $State.Mode = [PSNoteMenuItems]::Exit;             return $true }
        '^C' { $State.Mode = [PSNoteMenuItems]::Exit;             return $true }
        '^N' {
            Invoke-PSNotesNewNoteWizard -Store $Store

            # refresh scope after create (matches your current behavior)
            if (-not $State.Catalog -and -not $State.Tag) {
                $State.ScopeNotes = @($Store.Notes)
            }
            elseif ($State.Catalog) {
                Set-PSNotesCatalogScope -State $State -Catalog $State.Catalog
            }
            elseif ($State.Tag) {
                Set-PSNotesTagScope -State $State -Tag $State.Tag -AllNotes @($Store.Notes)
            }

            return $true
        }
        default { return $false }
    }
}