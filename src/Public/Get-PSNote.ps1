<#
.SYNOPSIS
Retrieves PSNotes from the note store by listing or searching.

.DESCRIPTION
Get-PSNote returns notes stored in the PSNotes store. By default, all notes are returned.
You can filter results by name, alias, tag, catalog, or search text depending on the
parameter set in use.

This cmdlet returns PSNote objects that can be piped into other PSNotes commands such as
Remove-PSNote, Move-PSNote, Export-PSNote, or Set-PSNote.

Wildcard matching is supported where applicable.

.FUNCTIONALITY
PSNotes Notes

.ROLE
Public

.COMPONENT
Notes

.PARAMETER Name
Returns notes that match the specified name. Wildcards are supported.

.PARAMETER Tag
Returns notes that contain one or more specified tags.

.PARAMETER Catalog
Returns notes from the specified catalog.

.PARAMETER Search
Performs a broader search across note properties such as name, alias, and tags.

.PARAMETER Copy
When specified, copies the snippet content of the first matching note to the clipboard. If multiple notes match, you will be prompted to select one.

.PARAMETER Run
When specified, executes the snippet content of the first matching note. If multiple notes match, you will be prompted to select one.

.EXAMPLE
PS> Get-PSNote

Returns all notes in the store.

.EXAMPLE
PS> Get-PSNote -Catalog 'Azure'

Returns all notes in the Azure catalog.

.EXAMPLE
PS> Get-PSNote -Note 'Get-*'

Returns notes with names that match the pattern.

.EXAMPLE
PS> Get-PSNote -Tag 'VM'

Returns notes tagged with 'VM'.

.EXAMPLE
PS> Get-PSNote -Search 'backup'

Searches across note properties for the term 'backup'.

.EXAMPLE
PS> Get-PSNote -Catalog 'Azure' | Remove-PSNote

Finds notes in the Azure catalog and removes them.

.OUTPUTS
PSNote

.NOTES
- Returns PSNote objects.
- Wildcards are supported for Name and Alias parameters.
- See also: New-PSNote, Set-PSNote, Remove-PSNote, Move-PSNote, Export-PSNote
#>
Function Get-PSNote{
    [cmdletbinding(DefaultParameterSetName="Note")]
    param(    
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [string]$Note = '*',
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [string]$Tag,
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [switch]$Copy,
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [parameter(Mandatory=$false, ParameterSetName="Search")]
        [switch]$Run,
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [parameter(Mandatory=$false, ParameterSetName="Search")]
        [string[]]$Catalog,
        [parameter(Mandatory=$false, ParameterSetName="Search")]
        [Alias("SearchString")]
        [string]$Search
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

    if($Search){
        $returned = $notes | Where-Object {
            $_.Note    -like "*$Search*" -or
            $_.Alias   -like "*$Search*" -or
            $_.Details -like "*$Search*" -or
            $_.Snippet -like "*$Search*" -or
            ($_.Tags | Where-Object { $_ -like "*$Search*" } | Select-Object -First 1)
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
