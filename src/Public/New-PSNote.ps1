Function New-PSNote {
    <#
    .SYNOPSIS
        Create a new PSNote

    .DESCRIPTION
        Creates a new PSNote. If a note with the same name already exists,
        you must supply the Force switch to overwrite its properties.

    .PARAMETER Note
        The name of the note to create.

    .PARAMETER Snippet
        The text of the snippet to store.

    .PARAMETER ScriptBlock
        Specifies the snippet to save. Enclose the commands in braces { } to create a script block.

    .PARAMETER Details
        Additional details about the note.

    .PARAMETER Alias
        The alias to create for this note. If not supplied it will use the Note value.

    .PARAMETER Tags
        A string array of tags to associate with the note.

    .PARAMETER Catalog
        The catalog to add the note to. Defaults to 'Default'.

    .PARAMETER Run
        Indicates whether the note should be set to run by default.

    .PARAMETER Force
        If the note already exists, the Force switch is required to overwrite it.
    
    .EXAMPLE
        New-PSNote -Note 'ADUser' -Snippet 'Get-ADUser -Filter *' -Details "Return all AD users" -Tags 'AD','Users'

        Creates a new note using a snippet string.

    .EXAMPLE
        New-PSNote -Note 'CpuUsage' -Tags 'perf' -Alias 'cpu' -ScriptBlock {
            Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -Average
        }

        Creates a new note using a script block instead of a snippet string.

    .EXAMPLE
        New-PSNote -Note 'DayOfWeek' -Snippet '(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__)' -Details "Name of the day of week" -Tags 'date' -Alias 'today'

        Creates a new note with a custom alias.

    .EXAMPLE
        $Snippet = @'
        $stringBuilder = New-Object System.Text.StringBuilder
        for ($i = 0; $i -lt 10; $i++){
            $stringBuilder.Append("Line $i`r`n") | Out-Null
        }
        $stringBuilder.ToString()
        '@
        New-PSNote -Note 'StringBuilder' -Snippet $Snippet -Details "Combine multiple strings" -Tags 'string'

        Creates a new note with a multi-line snippet using a here-string.

    .EXAMPLE
        New-PSNote -Note 'GetDateIso' -Snippet 'Get-Date -Format "yyyy-MM-dd"' -Catalog 'Work' -Tags 'date'

        Creates a new note in the Work catalog.

    .EXAMPLE
        New-PSNote -Note 'PingGoogle' -Snippet 'Test-Connection -ComputerName 8.8.8.8 -Count 2' -Run $true

        Creates a new note that is configured to run by default.

    .LINK
        https://github.com/mdowst/PSNotes
    
    
    #>
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low', DefaultParameterSetName = "Note")]
    param(
        [parameter(Mandatory = $true)]
        [string]$Note,
        [parameter(Mandatory = $false, ParameterSetName = "Snippet")]
        [string]$Snippet,
        [parameter(Mandatory = $false, ParameterSetName = "ScriptBlock")]
        [ScriptBlock]$ScriptBlock,
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

    if (-not [string]::IsNullOrEmpty($ScriptBlock)) {
        $Snippet = $ScriptBlock.ToString()
    }

    $newNote = $script:_noteStore.Notes | Where-Object { $_.Note -eq $Note }
    if ($newNote -and -not $force) {
        Write-Error "The note '$Note' already exists. Use -force to overwrite existing properties"
        break
    }
    elseif ($newNote -and $force) {
        $toUpdate = $script:_noteStore.Notes | Where-Object { $_.Note -eq $Note } | ForEach-Object {
            $tu = [PSNote]::new($_)
            $PSBoundParameters.GetEnumerator() | ForEach-Object {
                if ($_.Key -eq 'ScriptBlock') {
                    $tu.Snippet = $_.Value.ToString()
                }
                elseif ($_.Key -eq 'Alias') {
                    Test-NoteAlias $_.Value
                    $tu.Alias = $_.Value
                }
                elseif($_.Key -ne 'Force' -and $_.Key -ne 'Note') {
                    # Skip Force and Note as we don't want to update those
                    $tu.$($_.Key) = $_.Value
                }
            }
            $tu
        }
        $toUpdate | ForEach-Object {
            Write-Verbose "Updating Note: $($_.Note)"
            $script:_noteStore.UpdateNote($_)
        }
    }
    else {
        if ([string]::IsNullOrEmpty($Alias)) {
            $Alias = $Note
        }

        Test-NoteAlias $Alias
        
        $newNote = [PSNote]::New($Note, $Snippet, $Details, $Alias, $Tags, $Catalog, $Run)
        $script:_noteStore.AddNote($newNote)
    }
    
    Set-Alias -Name $newNote.Alias -Value Get-PSNoteAlias -Scope Global
}