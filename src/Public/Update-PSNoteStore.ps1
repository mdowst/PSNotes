<#
.SYNOPSIS
Updates PSNotes catalogs to the latest format.

.DESCRIPTION
Update-PSNoteStore scans the PSNotes home directory for JSON catalogs and migrates any catalogs
that are not in the current format. Migrated content is then imported back into the PSNotes
store using the specified conflict behavior.

Use -DefaultBehavior to control how note conflicts are handled during import:
- Prompt: prompts when conflicts occur
- SkipMigratedNotes: keeps existing notes and skips conflicting migrated notes
- OverwriteExistingNotes: overwrites existing notes with migrated versions

.FUNCTIONALITY
PSNotes Store Maintenance

.ROLE
Maintenance

.COMPONENT
Store

.PARAMETER DefaultBehavior
Determines how to handle existing notes when conflicts are detected during import.

Valid values:
- Prompt
- SkipMigratedNotes
- OverwriteExistingNotes

The default is 'Prompt'.

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

.NOTES
- This cmdlet migrates catalogs discovered under $env:PSNOTES_HOME.
- Conflict behavior applies when importing migrated notes back into the store.
- See also: Initialize-PSNoteStore, Import-PSNote, Export-PSNote
#>
function Update-PSNoteStore {
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