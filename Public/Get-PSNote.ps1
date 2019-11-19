Function Get-PSNote{
    <#
    .SYNOPSIS
        Use to search for or list the different PSNotes

    .DESCRIPTION
        Allows you to search for snippets by name or by tag. 

    .PARAMETER Note
        The note you want to return. Accepts wildcards

    .PARAMETER Tag
        The tag of the note(s) you want to return.

    .PARAMETER Copy
        If specfied the the Snippet will be copied to your clipboard
    
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

    .LINK
        https://github.com/mdowst/PSNotes
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$false)]
        [string]$Note = '*',
        [parameter(Mandatory=$false)]
        [string]$Tag,
        [parameter(Mandatory=$false)]
        [switch]$Copy
    )

    if($Tag){
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

    $returned #| Select-Object -Property Note, Alias, Details, Tags, Snippet | Sort-Object Note
}