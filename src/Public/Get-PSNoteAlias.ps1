Function Get-PSNoteAlias{
    <#
    .SYNOPSIS
        Use display snippet and copy to clipboard using an Alias

    .DESCRIPTION
        When the PSNotes module loads, it creates Aliases for all snippets.
        Those aliases are mapped to this command and it will return the snippet
        and copy it to your clipboard. You cannot call this function directly
        as it will not return anything.

    .LINK
        https://github.com/mdowst/PSNotes
    
    
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$false)]
        [switch]$Copy,
        [parameter(Mandatory=$false)]
        [switch]$Run
    )
    Test-PSNotesInitalize
    if($MyInvocation.MyCommand.Name -eq $MyInvocation.InvocationName){
        Write-Error "The Get-PSNoteAlias cmdlet is designed to be called using an alias and not directly."
    } else {
        $Alias = $MyInvocation.InvocationName
        $aliasObject = $script:_noteStore.Notes | Where-Object{$_.Alias -eq $Alias}
        if(($Run -or $aliasObject.Run) -and -not $Copy) {
            Invoke-PSNote -Note $aliasObject
        } else {
            if(Get-Command -Name 'Set-Clipboard' -ErrorAction SilentlyContinue){
                $returned | Select-Object -First 1 -ExpandProperty Snippet | Set-Clipboard
            } else {
                Write-Debug "Cmdlet 'Set-Clipboard' not found."
            }
            Return $aliasObject.Snippet
        }
    }
}

