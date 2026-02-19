<#
.SYNOPSIS
Imports PSNotes from a JSON export file into the local note store.

.DESCRIPTION
Import-PSNote reads a PSNotes JSON export file and imports the contained notes into the local
PSNotes store.

Import behavior may merge with existing notes or create new notes depending on the options
provided and the contents of the import file. Use -Force (if supported) to overwrite existing
notes when conflicts occur.

This cmdlet is commonly used to restore backups created by Export-PSNote, migrate notes between
machines, or share curated note libraries.

.FUNCTIONALITY
PSNotes Data Exchange

.ROLE
Public

.COMPONENT
Serialization

.PARAMETER Path
The path to the PSNotes JSON file to import.

.PARAMETER Catalog
Imports notes into the specified catalog (or maps imported notes into that catalog depending on implementation).

.PARAMETER DefaultBehavior
Determines how to handle existing notes when conflicts are detected during import.
Valid values:
- Prompt: prompts when conflicts occur
- SkipMigratedNotes: keeps existing notes and skips conflicting imported notes
- OverwriteExistingNotes: overwrites existing notes with imported versions

.EXAMPLE
PS> Import-PSNote -Path .\backup.json

Imports all notes from backup.json into the local store.

.EXAMPLE
PS> Import-PSNote -Path .\azure-notes.json -Catalog 'Azure'

Imports notes from azure-notes.json and places them into the Azure catalog (if supported).

.EXAMPLE
PS> Import-PSNote -Path .\backup.json -DefaultBehavior OverwriteExistingNotes

Imports notes, overwriting conflicts, and returns the imported note objects.

.OUTPUTS
System.Object

.NOTES
- This cmdlet is designed to round-trip with Export-PSNote.
- If you encounter format/version differences after upgrading PSNotes, run Update-PSNoteStore.
- See also: Export-PSNote, Get-PSNote, Update-PSNoteStore
#>
Function Import-PSNote {
    [cmdletbinding(DefaultParameterSetName = "Note")]
    param(    
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $false)]
        [string]$Catalog = 'Default',
        [ValidateSet('Prompt', 'SkipMigratedNotes', 'OverwriteExistingNotes')]
        [parameter(Mandatory = $false)]
        [string]$DefaultBehavior = 'Prompt'
    )
    Test-PSNotesInitalize
    

    $validation = [NoteCatalog]::ValidateNotes($Path)

    if(-not $validation.IsValid) {
        Write-Error "The provided PSNotes JSON file is not in the correct format. Please ensure the file is a valid PSNotes catalog. Validation Errors: $($validation.Errors -join '; ')"
        return
    }
    elseif($validation.StoreVersion -eq 'Current') {
        $importedCatalog = [NoteCatalog]::Open($Path)
    }
    else {
        $importedCatalog = [NoteCatalog]::Migrate($Path, $false)
    }

    Import-PSNoteCatalog -ImportedCatalog $importedCatalog -DestinationCatalog $Catalog -DefaultBehavior $DefaultBehavior

    $script:_noteStore.InitializeAliases()
    Write-Verbose "PSNoteStore update complete."
}