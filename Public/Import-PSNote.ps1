Function Import-PSNote{
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
    [cmdletbinding(DefaultParameterSetName="Note")]
    param(    
        [parameter(Mandatory=$true)]
        [string]$Path,
        [parameter(Mandatory=$false)]
        [string]$Catalog
    )

    # If Catalog check name and set path
    if($Catalog){
        # confirm the Catalog string is a valid file name
        if($Catalog.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -ne -1){
            throw "The catalog name '$Catalog' is an invalid file name. Invalid characater found in place $($Catalog.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()))"
        }
        # Set path the path for the catalog item 
        $CatalogPath = Join-Path $UserPSNotesJsonPath "$Catalog.json"
    } else {
        $CatalogPath = $UserPSNotesJsonFile
    }

    [System.Collections.Generic.List[PSNote]] $ImportObjects = @()
    $(Get-Content $Path -Raw | ConvertFrom-Json) | Select-Object Note, Snippet, Details, Alias, Tags, @{l='file';e={$CatalogPath}}| 
        ForEach-Object{ $ImportObjects.Add([PSNote]::New($_)) }
    
    # Append the new notes to the appropriate file
    Export-PSNote -NoteObject $ImportObjects -Path $CatalogPath -Append 

    # Reinitialize the Json files to reload everything
    Initialize-PSNotesJsonFile
}