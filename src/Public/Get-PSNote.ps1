Function Get-PSNote{
    <#
    .SYNOPSIS
        Use to search for or list the different PSNotes

    .DESCRIPTION
        Allows you to search for snippets by name or by tag. You can also search all 
        properties by using the SearchString parameter

    .PARAMETER Note
        The note you want to return. Accepts wildcards

    .PARAMETER Tag
        The tag of the note(s) you want to return.

    .PARAMETER Catalog
        Filter notes by catalog name. Accepts wildcards and multiple values.

    .PARAMETER Copy
        If specfied the the Snippet will be copied to your clipboard

    .PARAMETER SearchString
        Use to search for text in the note's name, details, snippet, alias, and tags

    .EXAMPLE
        Get-PSNote

        Returns all notes

    .EXAMPLE
        Get-PSNote -Note 'creds'

        Returns the note creds
    
    .EXAMPLE
        Get-PSNote -Note 'cred*'

        Returns all notes that start with cred

    .EXAMPLE
        Get-PSNote -tag 'AD'

        Returns all notes with the tag 'AD'

    .EXAMPLE
        Get-PSNote -Note '*user*' -tag 'AD'

        Returns all notes with user in the name and the tag 'AD'

    .EXAMPLE
        Get-PSNote -SearchString 'day'

        Returns all notes with the word day in the name, details, snippet text, alias, or tags

    .EXAMPLE
        Get-PSNote -Catalog 'PSNotes'

        Returns all notes in the PSNotes catalog

    .EXAMPLE
        Get-PSNote -SearchString 'day' -Catalog 'Work*','Personal*'

        Searches only within the matching catalogs

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
            $_.Target  -like "*$SearchString*" -or
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
            $returned | Select-Object -First 1 -ExpandProperty Target | Set-Clipboard
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
