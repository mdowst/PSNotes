Function Import-PSNoteCatalog {
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
    [cmdletbinding()]
    param(    
        [parameter(Mandatory = $true)]
        [NoteCatalog]$ImportedCatalog,
        [parameter(Mandatory = $true)]
        [string]$DestinationCatalog,
        [ValidateSet('Prompt', 'SkipMigratedNotes', 'OverwriteExistingNotes')]
        [parameter(Mandatory = $false)]
        [string]$DefaultBehavior = 'Prompt'
    )
    Test-PSNotesInitalize

    $excludeCollection = [System.Collections.Generic.List[PSNote]]::new()
    do {
        $dup = $script:_noteStore.Notes | Where-Object { $_.Alias -in $ImportedCatalog.Notes.Alias -and $_.Alias -notin $excludeCollection.Alias } | Select-Object -First 1
        if ($dup) {
            $mn = $ImportedCatalog.Notes | Where-Object { $_.Alias -eq $dup.Alias } | Select-Object -First 1
            Write-Warning "Duplicate note alias found during migration: $($mn.Alias)."
            $lines = @(
                "Existing Note"
                "-------------"
                "Catalog : $($dup.Catalog)"
                "Note    : $($dup.Name)"
                "Alias   : $($dup.Alias)"
                "Snippet : $($dup.Snippet.Trim().Split("`n")[0])"
            )
            $buffer = $lines | ForEach-Object { $_.Length } | Sort-Object -Descending | Select-Object -First 1
            $lines[2] = "Catalog : `e[38;2;0;128;255m$($dup.Catalog)`e[0m"
            $lines[0] = $lines[0].PadRight($buffer + 10) + "Migrated Note"
            $lines[1] = $lines[1].PadRight($buffer + 10) + "-------------"
            $lines[2] = $lines[2].PadRight($buffer + 31) + "Catalog : `e[38;2;255;255;0m$($mn.Catalog)`e[0m"
            $lines[3] = $lines[3].PadRight($buffer + 10) + "Note    : $($mn.Name)"
            $lines[4] = $lines[4].PadRight($buffer + 10) + "Alias   : $($mn.Alias)"
            $lines[5] = $lines[5].PadRight($buffer + 10) + "Snippet : $($mn.Snippet.Trim().Split("`n")[0])"

            $lines += "Select an action:"
            $lines += "1. Skip migrating this note."
            $lines += "   (Item in `e[38;2;255;255;0m$($mn.Catalog)`e[0m will be deleted.)"
            $lines += "2. Overwrite existing note with migrated note."
            $lines += "   (Item in `e[38;2;0;128;255m$($dup.Catalog)`e[0m will be deleted.)"
            $lines += "3. Set new alias."
            $lines += "4. View details of each note."
            $lines += "Enter choice (1, 2, 3, or 4) and hit [Enter]"
            $prompt = ($lines -join ("`n"))
            if (-not [string]::IsNullOrEmpty($additionalNote)) {
                $prompt = $additionalNote + "`n" + $prompt
            }
            # Determine choice based on DefaultBehavior
            if ($DefaultBehavior -eq 'SkipMigratedNotes') {
                $choice = '1'
            }
            elseif ($DefaultBehavior -eq 'OverwriteExistingNotes') {
                $choice = '2'
            }
            else {
                $choice = Read-Host $prompt
            }
                
            if ($choice -eq '1') {
                Write-Verbose "Skipping migration of note with alias: $($mn.Alias)"
                $excludeCollection.Add($mn)
                #$ImportedCatalog.RemoveNote($mn.Note, $false)
            }
            elseif ($choice -eq '2') {
                Write-Verbose "Overwriting existing note with alias: $($mn.Alias)"
                $script:_noteStore.RemoveNote($dup.Name, $dup.Catalog, $true )
            }
            elseif ($choice -eq '3') {
                $newAlias = Read-Host "Enter new alias for the migrated note"
                if (-not ($script:_noteStore.Notes | Where-Object { $_.Alias -eq $newAlias })) {
                    $mn.Alias = $newAlias
                }
                else {
                    $additionalNote = "`e[38;2;255;255;0mAlias $newAlias already exists. Please choose another.`e[0m"
                }
            }
            elseif ($choice -eq '4') {
                $additionalNote = "`e[38;2;0;128;255mExisting Note`n$( ($dup | Format-List * -Force | Out-String).Trim() )`e[0m"
                $additionalNote = $additionalNote + "`n-------------------------`n"
                $additionalNote = $additionalNote + "`e[38;2;255;255;0mMigrated Note`n$( ($mn | Format-List * -Force | Out-String).Trim() )`e[0m"
            }
            else {
                $additionalNote = "`e[38;2;255;0;0mInvalid choice. Please enter 1, 2, 3, or 4.`e[0m"
            }
        }
    } while ($dup)

    $currentCatalog = [NoteCatalog]::New($DestinationCatalog)
    $ImportedCatalog.Notes | Where-Object { $_.Alias -notin $excludeCollection.Alias -and $_.Alias -notin $currentCatalog.Notes.Alias } | ForEach-Object { $currentCatalog.Notes.Add($_) }
    $currentCatalog.Save()
    $script:_noteStore.LoadCatalog($DestinationCatalog)

    Write-Verbose "PSNoteStore update complete."
}