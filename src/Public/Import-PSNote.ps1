Function Import-PSNote {
    <#
    .SYNOPSIS
        Import a PSNotes JSON file

    .DESCRIPTION
        Imports PSNotes from a JSON catalog file into your local note store. You can import into the default
        catalog or a named catalog, and control how existing notes are handled.

    .PARAMETER Path
        The path to the PSNotes JSON catalog file to import.

    .PARAMETER Catalog
        The destination catalog name to import into. Defaults to 'Default'.

    .PARAMETER DefaultBehavior
        Determines how to handle existing notes when conflicts are detected.
        Valid values: Prompt, SkipMigratedNotes, OverwriteExistingNotes.

    .EXAMPLE
        Import-PSNote -Path C:\Import\MyPSNotes.json

        Imports the contents of MyPSNotes.json into the Default catalog.

    .EXAMPLE
        Import-PSNote -Path C:\Export\MyPSNotes.json -Catalog 'ADNotes'

        Imports the contents of MyPSNotes.json into the ADNotes catalog.

    .EXAMPLE
        Import-PSNote -Path C:\Export\MyPSNotes.json -Catalog 'Work' -DefaultBehavior OverwriteExistingNotes

        Imports into the Work catalog and overwrites existing notes when conflicts occur.
    
    .LINK
        https://github.com/mdowst/PSNotes
    #>
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

    Write-Verbose "PSNoteStore update complete."
}