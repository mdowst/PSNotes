function Update-PSNoteStore {
    <#
    .SYNOPSIS
        Update PSNotes catalogs to the latest format

    .DESCRIPTION
        Scans the PSNotes home directory for JSON catalogs and migrates any
        catalogs that are not in the current format. Migration results are
        imported back into the store using the specified conflict behavior.

    .PARAMETER DefaultBehavior
        Determines how to handle existing notes when conflicts are detected.
        Valid values: Prompt, SkipMigratedNotes, OverwriteExistingNotes.

    .EXAMPLE
        Update-PSNoteStore

        Migrates any outdated catalogs and prompts when conflicts occur.

    .EXAMPLE
        Update-PSNoteStore -DefaultBehavior SkipMigratedNotes

        Migrates catalogs and skips notes that already exist.

    .EXAMPLE
        Update-PSNoteStore -DefaultBehavior OverwriteExistingNotes

        Migrates catalogs and overwrites existing notes when conflicts occur.

    .LINK
        https://github.com/mdowst/PSNotes
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param(
        [ValidateSet('Prompt', 'SkipMigratedNotes', 'OverwriteExistingNotes')]
        [parameter(Mandatory = $false)]
        [string]$DefaultBehavior = 'Prompt'
    )
    
    Write-Verbose "Updating PSNoteStore to latest format..."

    $toMigrate = Get-ChildItem -Path $env:PSNOTES_HOME -Filter '*.json' | ForEach-Object {
        if (-not [NoteCatalog]::VersionCheck($_.FullName)) {
            Write-Verbose "Migrating $($_.BaseName)..."
            $_
        }
    }

    foreach ($catalogPath in $toMigrate) {
        $migratedStore = [NoteCatalog]::Migrate($catalogPath.FullName, $true)
        Import-PSNoteCatalog -ImportedCatalog $migratedStore -DestinationCatalog $migratedStore.Catalog -DefaultBehavior $DefaultBehavior
    }

    $script:_noteStore.InitializeAliases()
    Write-Verbose "PSNoteStore update complete."
}