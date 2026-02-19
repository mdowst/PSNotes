<#
.SYNOPSIS
Resolves a PSNote by alias and outputs, copies, or executes its content.

.DESCRIPTION
Get-PSNoteAlias locates a PSNote using its alias and performs a quick action against it.

Depending on the note’s Kind and the parameters supplied, the cmdlet can:

- Output the snippet content to the console
- Copy the snippet content to the clipboard
- Execute the snippet directly
- Execute a referenced script path

This command is designed for fast recall of frequently used commands through short,
easy-to-remember aliases.

.FUNCTIONALITY
PSNotes Notes

.ROLE
Public

.COMPONENT
Notes

.PARAMETER Copy
Copies the note content to the clipboard instead of writing it to the console.

.PARAMETER Run
Executes the note content. For snippet notes, the script block is invoked. For script-path
notes, the referenced script is executed.

.OUTPUTS
System.String

.NOTES
- Alias values are intended to be unique within the PSNotes store.
- Behavior differs based on the note Kind (for example, Snippet vs ScriptPath).
- Clipboard functionality depends on platform support.
- See also: Get-PSNote, New-PSNote, Set-PSNote
#>
Function Get-PSNoteAlias{
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$false)]
        [switch]$Copy,
        [parameter(Mandatory=$false)]
        [switch]$Run
    )
    Test-PSNotesInitalize
    # The function is designed to be called via an alias, so we check if the invocation name matches the command name.
    if($MyInvocation.MyCommand.Name -eq $MyInvocation.InvocationName){
        Write-Error "The Get-PSNoteAlias cmdlet is designed to be called using an alias and not directly."
    } else {
        $Alias = $MyInvocation.InvocationName
        $aliasObject = $script:_noteStore.Notes | Where-Object{$_.Alias -eq $Alias}
        if(($Run -or $aliasObject.Run) -and -not $Copy) {
            Invoke-PSNote -Note $aliasObject
        } else {
            if(Get-Command -Name 'Set-Clipboard' -ErrorAction SilentlyContinue){
                $aliasObject | Select-Object -First 1 -ExpandProperty Snippet | Set-Clipboard
            } else {
                Write-Debug "Cmdlet 'Set-Clipboard' not found."
            }
            Return $aliasObject.Snippet
        }
    }
}

