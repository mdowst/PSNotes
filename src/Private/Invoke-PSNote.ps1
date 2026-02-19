<#
.SYNOPSIS
    Invokes a PSNote by executing its script or snippet.

.DESCRIPTION
    Internal function that executes a PSNote based on its Kind property.
    For Script notes, it runs the referenced script file.
    For Snippet notes, it executes the snippet as a script block.

.PARAMETER Note
    The PSNote object to invoke. Must be of Kind 'Script' or 'Snippet'.

.EXAMPLE
    PS> Invoke-PSNote -Note $note
    Executes the provided note.

.NOTES
    This is an internal function. Validates that the note store is initialized
    before execution.

.OUTPUTS
    System.Object
    Returns any output from the executed script or snippet.
#>
Function Invoke-PSNote {

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