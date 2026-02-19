<#
.SYNOPSIS
Creates a new PSNote for storing reusable snippets or script references.

.DESCRIPTION
New-PSNote creates a note in the PSNotes store that can represent either:

- A reusable PowerShell snippet (inline code)
- A script reference (a path to a script file to execute)

Notes can include metadata such as catalog, alias, and tags to make them easier to organize and
retrieve later. Once created, notes can be recalled using Get-PSNote, invoked quickly by alias
with Get-PSNoteAlias, or selected interactively using Get-PSNoteMenu.

This cmdlet supports ShouldProcess, enabling -WhatIf and -Confirm.

.FUNCTIONALITY
PSNotes Notes

.ROLE
Public

.COMPONENT
Notes

.PARAMETER Note
The name of the note.

.PARAMETER Catalog
The catalog to create the note in.

.PARAMETER Alias
An optional short alias used for quick recall (for example, with Get-PSNoteAlias).

.PARAMETER Tags
One or more tags to associate with the note.

.PARAMETER Snippet
The PowerShell snippet content to store in the note.

.PARAMETER ScriptPath
A script path to store in the note for later execution.

.PARAMETER ScriptBlock
A PowerShell script block containing the code to store in the note.

.PARAMETER Details
Additional details or description about the note.

.PARAMETER Force
Overwrites an existing note with the same name (or alias conflict) where supported.

.PARAMETER Run
When specified, executes the snippet content of the note immediately after creation.

.EXAMPLE
PS> New-PSNote -Name 'List-AzVMs' -Catalog 'Azure' -Alias 'azvms' -Tag 'VM','Azure' -Snippet 'Get-AzVM'

Creates a snippet note named List-AzVMs in the Azure catalog with an alias and tags.

.EXAMPLE
PS> New-PSNote -Name 'Build' -Catalog 'Dev' -Alias 'build' -ScriptPath 'C:\Scripts\Build.ps1'

Creates a script-path note that references a script to run later.

.EXAMPLE
PS> New-PSNote -Name 'TestNote' -Catalog 'General' -Snippet 'Get-Date' -WhatIf

Shows what would happen if the note were created without making changes.

.EXAMPLE
PS> New-PSNote -Name 'List-AzVMs' -Catalog 'Azure' -Snippet 'Get-AzVM' -Force -PassThru

Overwrites an existing note (if present) and returns the created note object.

.OUTPUTS
PSNote

.NOTES
- Supports -WhatIf and -Confirm through ShouldProcess.
- Notes may be uniquely identified by name and/or alias depending on store rules.
- Use Set-PSNote to update an existing note.
- See also: Get-PSNote, Set-PSNote, Get-PSNoteAlias, Get-PSNoteMenu
#>
Function New-PSNote {
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low', DefaultParameterSetName = "Note")]
    param(
        [parameter(Mandatory = $true)]
        [string]$Note,
        [parameter(Mandatory = $false, ParameterSetName = "Snippet")]
        [string]$Snippet,
        [parameter(Mandatory = $false, ParameterSetName = "ScriptBlock")]
        [ScriptBlock]$ScriptBlock,
        [parameter(Mandatory = $false, ParameterSetName = "ScriptPath")]
        [string]$ScriptPath,
        [parameter(Mandatory = $false)]
        [string]$Details,
        [parameter(Mandatory = $false)]
        [string]$Alias,
        [parameter(Mandatory = $false)]
        [string[]]$Tags,
        [parameter(Mandatory = $false)]
        [string]$Catalog = 'Default',
        [parameter(Mandatory = $false)]
        [bool]$Run = $false,
        [parameter(Mandatory = $false)]
        [switch]$Force
    )
    Test-PSNotesInitalize
        
    Function Test-NoteAlias {
        param($Alias)
        
        $AliasCheck = [regex]::Matches($Alias, "[^0-9a-zA-Z\-_]")
        if ($AliasCheck.Success) {
            throw "'$Alias' is not a valid alias. Alias's can only contain letters, numbers, dashes(-), and underscores (_)."
        } 
    }

    # Determine the Kind based on parameter set
    $Kind = [PSNoteKind]::Snippet
    
    if (-not [string]::IsNullOrEmpty($ScriptPath)) {
        if (-not (Test-Path -Path $ScriptPath)) {
            Write-Error "Script file not found: $ScriptPath"
            return
        }
        $Snippet = $ScriptPath
        $Kind = [PSNoteKind]::Script
        # Default $Run to $true for ScriptPath if not explicitly passed
        if (-not $PSBoundParameters.ContainsKey('Run')) {
            $Run = $true
        }
    }
    elseif (-not [string]::IsNullOrEmpty($ScriptBlock)) {
        $Snippet = $ScriptBlock.ToString()
    }

    $newNote = $script:_noteStore.Notes | Where-Object { $_.Note -eq $Note -and $_.Catalog -eq $Catalog }
    if ($newNote -and -not $force) {
        Write-Error "The note '$Note' already exists. Use -force to overwrite existing properties"
        break
    }
    elseif ($newNote -and $force) {
        $toUpdate = $script:_noteStore.Notes | Where-Object { $_.Note -eq $Note -and $_.Catalog -eq $Catalog } | ForEach-Object {
            $tu = [PSNote]::new($_)
            $PSBoundParameters.GetEnumerator() | ForEach-Object {
                if ($_.Key -eq 'ScriptBlock') {
                    $tu.Snippet = $_.Value.ToString()
                }
                elseif ($_.Key -eq 'ScriptPath') {
                    $tu.Snippet = $Snippet
                    $tu.Kind = [PSNoteKind]::Script
                }
                elseif ($_.Key -eq 'Alias') {
                    Test-NoteAlias $_.Value
                    $tu.Alias = $_.Value
                }
                elseif ($_.Key -ne 'Force' -and $_.Key -ne 'Note') {
                    # Skip Force and Note as we don't want to update those
                    $tu.$($_.Key) = $_.Value
                }
            }
            $tu
        }
        $toUpdate | ForEach-Object {
            Write-Verbose "Updating Note: $($_.Note)"
            $script:_noteStore.UpdateNote($_)
            if (-not [string]::IsNullOrEmpty($_.Alias)) {
                Set-Alias -Name $_.Alias -Value Get-PSNoteAlias -Scope Global -Force
            }
        }
    }
    else {
        if ([string]::IsNullOrEmpty($Alias)) {
            $Alias = ''
        }
        else {
            Test-NoteAlias $Alias
        }
        
        $newNote = [PSNote]::New($Note, $Kind, $Snippet, $Details, $Alias, $Tags, $Catalog, $Run)
        $script:_noteStore.AddNote($newNote)
    }
    
    if (-not [string]::IsNullOrEmpty($newNote.Alias)) {
        Set-Alias -Name $newNote.Alias -Value Get-PSNoteAlias -Scope Global -Force
    }
}