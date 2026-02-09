Function Invoke-PSNote {
    <#
    .SYNOPSIS
        Use to display a list of notes in a selectable menu so you can choose which to run

    .DESCRIPTION
        Allows you to search for snippets by name or by tag. You can also search all 
        properties by using the SearchString parameter. Search results are displayed
        in a selectable menu and you are prompted to select which one you want to run.

    .PARAMETER Note
        The note you want to run. Accepts wildcards

    .PARAMETER Tag
        The tag of the note(s) you want to run.

    .PARAMETER SearchString
        Use to search for text in the note's name, details, snippet, alias, and tags

    .EXAMPLE
        Invoke-PSNote

        Returns a menu with all notes

    .EXAMPLE
        Invoke-PSNote -Name 'creds'

        Returns a menu with the note creds
    
    .EXAMPLE
        Invoke-PSNote -Name 'cred*'

        Returns a menu with all notes that start with cred

    .EXAMPLE
        Invoke-PSNote -tag 'AD'

        Returns a menu with all notes with the tag 'AD'

    .EXAMPLE
        Invoke-PSNote -Name '*user*' -tag 'AD'

        Returns a menu with all notes with user in the name and the tag 'AD'

    .EXAMPLE
        Invoke-PSNote -SearchString 'day'

        Returns a menu with all notes with the word day in the name, details, snippet text, alias, or tags
    
        .LINK
        https://github.com/mdowst/PSNotes
    #>
    [cmdletbinding(DefaultParameterSetName = "Note")]
    param(      
        [parameter(Mandatory = $true, ParameterSetName = "Note", Position = 0)]
        [PSNote]$Note
    )
    Test-PSNotesInitalize
    
    switch ($Note.Kind) {
        Script {
            if ([string]::IsNullOrWhiteSpace($Note.Snippet)) {
                throw "Cannot invoke Script note '$($Note.Note)': Path is empty."
            }
            if (-not (Test-Path -LiteralPath $Note.Snippet)) {
                throw "Cannot invoke Script note '$($Note.Note)': Script file not found at path: $($Note.Snippet)"
            }
            & $Note.Snippet
        }
        Snippet {
            if ([string]::IsNullOrWhiteSpace($Note.Snippet)) {
                throw "Cannot invoke Snippet note '$($Note.Note)': Snippet is empty."
            }
            $scriptBlock = [ScriptBlock]::Create($Note.Snippet)
            Invoke-Command -ScriptBlock $scriptBlock
        }
        default {
            throw "Cannot invoke note '$($Note.Note)': Unknown Kind: $($Note.Kind)"
        }
    }
    
}