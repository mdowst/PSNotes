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

    .PARAMETER Copy
        If specfied the the Snippet will be copied to your clipboard

    .PARAMETER SearchString
        Use to search for text in the note's name, details, snippet, alias, and tags

    .EXAMPLE
        Get-PSNote

        Returns all notes

    .EXAMPLE
        Get-PSNote -Name 'creds'

        Returns the note creds
    
    .EXAMPLE
        Get-PSNote -Name 'cred*'

        Returns all notes that start with cred

    .EXAMPLE
        Get-PSNote -tag 'AD'

        Returns all notes with the tag 'AD'

    .EXAMPLE
        Get-PSNote -Name '*user*' -tag 'AD'

        Returns all notes with user in the name and the tag 'AD'

    .EXAMPLE
        Get-PSNote -SearchString 'day'

        Returns all notes with the word day in the name, details, snippet text, alias, or tags
    
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
        [parameter(Mandatory=$false, ParameterSetName="Search")]
        [string]$SearchString
    )


    if($SearchString){
        [System.Collections.Generic.List[PSNoteSearch]] $SearchResults = @()
        $noteObjects | Where-Object{ $_.Note -like "*$SearchString*" -or $_.Alias -like "*$SearchString*" -or 
            $_.Details -like "*$SearchString*" -or $_.Snippet -like "*$SearchString*" } | ForEach-Object { $SearchResults.Add($_) }
        $noteObjects | Where-Object{ $SearchResults.Note -notcontains $_.Note } | ForEach-Object { 
            $tagMatch = $false
            $_.tag | ForEach-Object {
                if($_ -like "*$SearchString*"){
                    $tagMatch = $true
                }
            }
            if($tagMatch){
                $SearchResults.Add($_) 
            }
        }
        $returned = $SearchResults
    } elseif($Tag){
        $returned = $noteObjects | Where-Object{$_.Note -like $note -and $_.Tags -contains $Tag}
    } else {
        $returned = $noteObjects | Where-Object{$_.Note -like $note}
    }
    
    if($copy){
        if(@($returned).count -gt 1){
            Write-Warning "More than 1 command returned. Only the first one will be written to the clipboard"
        }
        if(Get-Command -Name 'Set-Clipboard' -ErrorAction SilentlyContinue){
            $returned | Select-Object -First 1 -ExpandProperty Snippet | Set-Clipboard
        } else {
            Write-Debug "Cmdlet 'Set-Clipboard' not found."
        }
    }

    if($Run){
        if(@($returned).count -gt 1){
            Write-Warning "More than 1 command returned. Only the first one will be run"
        }

        $Snippet = $returned | Select-Object -First 1 -ExpandProperty Snippet
        $ScriptBlock = $executioncontext.invokecommand.NewScriptBlock($Snippet)
        Invoke-Command -ScriptBlock $ScriptBlock
    } else {
        $returned
    }

}