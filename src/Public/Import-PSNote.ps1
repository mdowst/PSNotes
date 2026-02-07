Function Import-PSNote {
    <#
    .SYNOPSIS
        Use to import a PSNotes JSON fiile

    .DESCRIPTION
        Allows you to import shared PSNotes JSON files to your local notes. They can be imported to your personal
        store, or they can be imported to a seperate file. 

    .PARAMETER NoteObject
        The PSNote objects you want to export. Use Get-PSNote to build the object and pass it to the parameter
        or use a pipeline to pass it.

    .PARAMETER Path
        The path to the PSNotes JSON file to export to.

    .PARAMETER Catalog
        Use to output snippets to a seperate file stored in the folder %APPDATA%\PSNotes.
        Useful for when you want to share different snippet types.

    .EXAMPLE
        Import-PSNote -Path C:\Import\MyPSNotes.json

        Imports the contents of the file MyPSNotes.json and saves it to your personal PSNotes.json file

    .EXAMPLE
        Import-PSNote -Path C:\Export\MyPSNotes.json -Catalog 'ADNotes'

        Imports the contents of the file MyPSNotes.json and saves it to the file ADNotes.json in the folder %APPDATA%\PSNotes
    
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