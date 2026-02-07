Function Get-PSNote{
    <#
    .SYNOPSIS
        Search for or list PSNotes

    .DESCRIPTION
        Searches notes by name, tag, or text across all note properties. You can also
        filter by catalog and optionally copy or run the returned snippet.

    .PARAMETER Note
        The note name to return. Accepts wildcards.

    .PARAMETER Tag
        Return notes that contain the specified tag.

    .PARAMETER Catalog
        Filter notes by catalog name. Accepts wildcards and multiple values.

    .PARAMETER Copy
        Copy the selected snippet to the clipboard.

    .PARAMETER Run
        Run the selected snippet via Invoke-PSNote.

    .PARAMETER SearchString
        Search for text in the note's name, details, snippet, alias, or tags.

    .EXAMPLE
        Get-PSNote

        Returns all notes.

    .EXAMPLE
        Get-PSNote -Note 'Creds'

        Returns the note named 'Creds'.

    .EXAMPLE
        Get-PSNote -Note 'Cred*'

        Returns all notes with names that start with 'Cred'.

    .EXAMPLE
        Get-PSNote -Tag 'AD'

        Returns all notes with the tag 'AD'.

    .EXAMPLE
        Get-PSNote -Note '*User*' -Tag 'AD'

        Returns notes with 'User' in the name and the tag 'AD'.

    .EXAMPLE
        Get-PSNote -SearchString 'day'

        Returns notes where 'day' appears in the name, details, snippet, alias, or tags.

    .EXAMPLE
        Get-PSNote -Catalog 'Default'

        Returns all notes in the Default catalog.

    .EXAMPLE
        Get-PSNote -SearchString 'day' -Catalog 'Work*','Personal*'

        Searches only within the matching catalogs.

    .EXAMPLE
        Get-PSNote -Note 'CpuUsage' -Copy

        Copies the snippet for the selected note to the clipboard.

    .EXAMPLE
        Get-PSNote -SearchString 'token' -Run

        Runs the selected note; prompts to choose if multiple notes match.

    .LINK
        https://github.com/mdowst/PSNotes
    #>
    [cmdletbinding(DefaultParameterSetName="Note")]
    param(    
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [string]$Note = '*',
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [string]$Tag,
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [switch]$Copy,
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [switch]$Run,
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [parameter(Mandatory=$false, ParameterSetName="Search")]
        [string[]]$Catalog,
        [parameter(Mandatory=$false, ParameterSetName="Search")]
        [string]$SearchString
    )
    Test-PSNotesInitalize

    $notes = $script:_noteStore.Notes

    if($Catalog){
        $notes = $notes | Where-Object {
            $noteCatalog = $_.Catalog
            foreach($pattern in $Catalog){
                if($noteCatalog -like $pattern){ return $true }
            }
            return $false
        }
    }

    if($SearchString){
        $returned = $notes | Where-Object {
            $_.Note    -like "*$SearchString*" -or
            $_.Alias   -like "*$SearchString*" -or
            $_.Details -like "*$SearchString*" -or
            $_.Snippet -like "*$SearchString*" -or
            ($_.Tags | Where-Object { $_ -like "*$SearchString*" } | Select-Object -First 1)
        }
    } elseif($Tag){
        $returned = $notes | Where-Object{$_.Note -like $note -and $_.Tags -contains $Tag}
    } else {
        $returned = $notes | Where-Object{$_.Note -like $note}
    }
    
    if($copy -or $Run){
        if(@($returned).count -gt 1){
            Write-Warning "More than 1 command returned. Select one to continue."
            $sel = Write-NoteSnippet -NoteSelection $returned
            $returned = $sel
        }

        if(-not $returned){
            Write-Warning "No note found to run."
            return
        }
    }

    if($copy){
        if(Get-Command -Name 'Set-Clipboard' -ErrorAction SilentlyContinue){
            $returned | Select-Object -First 1 -ExpandProperty Snippet | Set-Clipboard
        } else {
            Write-Debug "Cmdlet 'Set-Clipboard' not found."
        }
    }

    if($Run){
        Invoke-PSNote -Note $returned
    } else {
        $returned
    }

}
