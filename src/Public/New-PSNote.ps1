Function New-PSNote {
    <#
    .SYNOPSIS
        Creates a new PSNote for storing and reusing code snippets or script references.

    .DESCRIPTION
        Creates a new PSNote to store code snippets, script blocks, or references to script files.
        PSNotes can be stored in different catalogs and tagged for easy retrieval. Each note
        has an alias that can be used to quickly access it.

        If a note with the same name already exists in the specified catalog, you must supply 
        the Force switch to overwrite its properties.

        The note Kind is automatically set based on the parameter used:
        - Snippet or ScriptBlock: Creates a note of Kind 'Snippet' (inline code)
        - ScriptPath: Creates a note of Kind 'Script' (file reference)

    .PARAMETER Note
        The unique name of the note to create within the specified catalog.

    .PARAMETER Snippet
        The text of the code snippet to store. This is typically a single line or small block 
        of PowerShell code. Use this parameter for simple snippets.

    .PARAMETER ScriptBlock
        A PowerShell script block containing the code to save. Enclose the commands in braces { } 
        to create a script block. This is useful for multi-line code with proper syntax highlighting.

    .PARAMETER ScriptPath
        The file path to a PowerShell script (.ps1) file. When specified, the note will reference 
        this external script file and the note Kind will be set to 'Script'. The script file must 
        exist at the specified path.

    .PARAMETER Details
        A description or additional information about the note. This helps document what the 
        note does and when to use it.

    .PARAMETER Alias
        The alias to create for this note. If not supplied, it will use the Note name as the alias.
        The alias can only contain letters, numbers, dashes (-), and underscores (_).
        The alias is set as a global alias that invokes Get-PSNoteAlias.

    .PARAMETER Tags
        A string array of tags to associate with the note. Tags help categorize and search for 
        notes. Multiple tags can be specified.

    .PARAMETER Catalog
        The catalog to add the note to. Catalogs are used to organize notes into different 
        collections (e.g., 'Personal', 'Work', 'Team'). Defaults to 'Default'.

    .PARAMETER Run
        Indicates whether the note should be executed automatically when retrieved. 
        When set to $true, the note will run when accessed. When set to $false (default), 
        the note content will be returned without execution.

    .PARAMETER Force
        Forces the creation of the note even if a note with the same name already exists in 
        the catalog. Without this switch, an error will be thrown if the note already exists.
    
    .EXAMPLE
        New-PSNote -Note 'GetServices' -Snippet 'Get-Service | Where-Object Status -eq Running' -Alias 'running'

        Creates a simple note with a one-line snippet. The snippet can be retrieved or executed using the alias 'running'.

    .EXAMPLE
        New-PSNote -Note 'DayOfWeek' -Alias 'today' -Snippet '(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__)' -Details "Returns the abbreviated name of the current day" -Tags 'date','time'

        Creates a note with a snippet, description, and multiple tags for easy searching.

    .EXAMPLE
        New-PSNote -Note 'CpuUsage' -Tags 'perf','monitoring' -Alias 'cpu' -ScriptBlock {
            Get-CimInstance Win32_Processor | 
                Measure-Object -Property LoadPercentage -Average | 
                Select-Object -ExpandProperty Average
        }

        Creates a note using a script block with multi-line code and a custom alias 'cpu'.

    .EXAMPLE
        $MultiLineSnippet = @'
        $sb = [System.Text.StringBuilder]::new()
        for ($i = 1; $i -le 10; $i++) {
            [void]$sb.AppendLine("Item $i")
        }
        $sb.ToString()
        '@
        New-PSNote -Note 'StringBuilder' -Snippet $MultiLineSnippet -Details "Demonstrates StringBuilder usage" -Tags 'string','performance'

        Creates a note with a multi-line snippet stored in a here-string variable.

    .EXAMPLE
        New-PSNote -Note 'GetDateIso' -Snippet 'Get-Date -Format "yyyy-MM-dd"' -Catalog 'Work' -Tags 'date','formatting'

        Creates a new note in the 'Work' catalog instead of the default catalog.

    .EXAMPLE
        New-PSNote -Note 'TestConnection' -Alias 'test-conn' -Snippet 'Test-Connection -ComputerName 8.8.8.8 -Count 2 -Quiet' -Run $true -Details "Quick connectivity test"

        Creates a note that will automatically execute when retrieved (Run = $true).

    .EXAMPLE
        New-PSNote -Note 'DeploymentScript' -ScriptPath 'C:\Scripts\Deploy-Application.ps1' -Details "Main deployment script for production" -Tags 'deployment','production','automation' -Catalog 'Work'

        Creates a note that references an external script file. The note Kind will be 'Script'.
        The script file must exist at the specified path.

    .EXAMPLE
        New-PSNote -Note 'BackupScript' -ScriptPath '\\FileServer\Scripts\Backup.ps1' -Alias 'backup' -Details "Automated backup script" -Tags 'backup','maintenance'

        Creates a note referencing a script on a network share with a custom alias.

    .EXAMPLE
        New-PSNote -Note 'GetServices' -Snippet 'Get-Service | Sort-Object Status' -Force

        Updates an existing note named 'GetServices' with new snippet content using the -Force switch.
        Without -Force, this would throw an error if the note already exists.

    .EXAMPLE
        New-PSNote -Note 'QuickTest' -Snippet 'Write-Host "Test"' -Details "Original"
        New-PSNote -Note 'QuickTest' -Snippet 'Write-Host "Updated"' -Details "Modified version" -Force

        Demonstrates creating a note and then updating it with the -Force parameter.

    .NOTES
        The note alias is created as a global alias pointing to Get-PSNoteAlias.
        This allows you to simply type the alias to retrieve or run the note.

    .LINK
        https://github.com/mdowst/PSNotes

    .LINK
        Get-PSNote

    .LINK
        Set-PSNote

    .LINK
        Remove-PSNote
    #>
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