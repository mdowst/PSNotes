Function Set-PSNote {
    <#
    .SYNOPSIS
        Updates an existing PSNote or creates a new one if it doesn't exist.

    .DESCRIPTION
        Modifies the properties of an existing PSNote. If the note does not exist in the 
        specified catalog, a warning is displayed and the note will be created.

        This function updates only the properties you specify, leaving other properties unchanged.
        It internally calls New-PSNote with the -Force parameter to update the note.

        The note Kind is automatically set based on the parameter used:
        - Snippet or ScriptBlock: Updates to Kind 'Snippet' (inline code)
        - ScriptPath: Updates to Kind 'Script' (file reference)

        Supports pipeline input by property name, allowing you to pipe objects with Note, Catalog, 
        Snippet, Details, Alias, Tags, or Run properties.

    .PARAMETER Note
        The name of the note to update. Must match an existing note name in the specified catalog.
        Accepts input from pipeline by property name.

    .PARAMETER Catalog
        The catalog where the note is located. Defaults to 'Default'. If the note doesn't exist
        in the specified catalog, it will be created there.
        Accepts input from pipeline by property name.

    .PARAMETER Snippet
        The new snippet text to store in the note. This replaces the existing snippet content.
        Use this for simple one-line or small code snippets.
        Accepts input from pipeline by property name.

    .PARAMETER ScriptBlock
        A PowerShell script block containing the new code to save. Enclose commands in braces { }.
        This is useful for multi-line code with proper syntax highlighting.
        Accepts input from pipeline by property name.

    .PARAMETER ScriptPath
        The file path to a PowerShell script (.ps1) file. When specified, the note will be 
        updated to reference this external script file and the note Kind will be set to 'Script'.
        The script file must exist at the specified path.
        Accepts input from pipeline by property name.

    .PARAMETER Details
        New description or additional information about the note. Replaces the existing details.
        Accepts input from pipeline by property name.

    .PARAMETER Alias
        The new alias for this note. The alias can only contain letters, numbers, dashes (-), 
        and underscores (_). The alias is set as a global alias that invokes Get-PSNoteAlias.
        Accepts input from pipeline by property name.

    .PARAMETER Tags
        A new string array of tags to associate with the note. This replaces all existing tags.
        Accepts input from pipeline by property name.

    .PARAMETER Run
        Updates whether the note should be executed automatically when retrieved.
        Set to $true to enable auto-execution, $false to disable it.
        Accepts input from pipeline by property name.
    
    .EXAMPLE
        Set-PSNote -Note 'ADUser' -Tags 'AD','Users','Updated'

        Updates the tags for the note 'ADUser' in the Default catalog, replacing any existing tags.
    
    .EXAMPLE
        $NewSnippet = '(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__)'
        Set-PSNote -Note 'DayOfWeek' -Snippet $NewSnippet

        Updates the snippet content for the note 'DayOfWeek' while preserving other properties.

    .EXAMPLE
        Set-PSNote -Note 'CpuUsage' -ScriptBlock {
            Get-CimInstance Win32_Processor | 
                Measure-Object -Property LoadPercentage -Average |
                Select-Object -ExpandProperty Average
        }

        Updates the note 'CpuUsage' with a new multi-line script block using modern cmdlets.

    .EXAMPLE
        Set-PSNote -Note 'CpuUsage' -Details "Returns average CPU usage percentage" -Alias 'cpu'

        Updates only the Details and Alias properties for the note 'CpuUsage', leaving the snippet unchanged.

    .EXAMPLE
        Set-PSNote -Note 'ADUser' -Catalog 'Work' -Tags 'AD','Users','Production'

        Updates the tags for the note 'ADUser' that exists in the 'Work' catalog.

    .EXAMPLE
        Set-PSNote -Note 'GetDate' -Snippet 'Get-Date -Format "yyyy-MM-dd"' -Details "Returns current date in ISO format" -Tags 'date','formatting'

        Updates multiple properties (snippet, details, and tags) of the note 'GetDate' in a single command.

    .EXAMPLE
        Set-PSNote -Note 'TestConnection' -Run $true -Details "Auto-run connectivity test"

        Enables auto-execution for the note 'TestConnection'. When retrieved, it will run automatically.

    .EXAMPLE
        Set-PSNote -Note 'BackupScript' -ScriptPath 'D:\Scripts\Backup-Database.ps1' -Details "Updated backup script location"

        Updates an existing note to reference a different script file, changing its Kind to 'Script'.

    .EXAMPLE
        Set-PSNote -Note 'NewFeature' -Snippet 'Get-Service -Name "MyService"' -Details "Check service status"

        Creates a new note named 'NewFeature' because it doesn't exist yet. A warning will be displayed.

    .EXAMPLE
        Get-PSNote -Note 'ADUser' | Set-PSNote -Tags 'AD','Users','Updated'

        Retrieves the note 'ADUser' and updates its tags via pipeline by property name.

    .EXAMPLE
        Get-PSNote -Tag 'deprecated' | Set-PSNote -Tags 'archived','old'

        Updates all notes tagged 'deprecated' to have tags 'archived' and 'old' instead.
        Uses pipeline to process multiple notes at once.

    .EXAMPLE
        Get-PSNote -Catalog 'Work' | Where-Object { $_.Tags -contains 'legacy' } | 
            Set-PSNote -Tags 'archived','legacy','review'

        Finds all notes in the Work catalog with the 'legacy' tag and updates their tags.
        Demonstrates filtering and bulk updating via pipeline.

    .EXAMPLE
        [PSCustomObject]@{
            Note = 'MyNote'
            Snippet = 'Get-Process | Select-Object -First 10'
            Details = 'Top 10 processes'
            Tags = @('process','monitoring')
        } | Set-PSNote

        Creates or updates a note using a custom object via pipeline by property name.

    .EXAMPLE
        Import-Csv .\notes.csv | Set-PSNote

        Bulk creates or updates notes from a CSV file with columns matching parameter names
        (Note, Snippet, Details, Tags, Catalog, etc.). Processes each row via pipeline.

    .EXAMPLE
        Get-PSNote | Where-Object { $_.Catalog -eq 'Default' } | 
            Set-PSNote -Catalog 'Personal'

        Moves all notes from the Default catalog to the Personal catalog via pipeline.

    .NOTES
        This function is a convenience wrapper around New-PSNote with the -Force parameter.
        All property updates replace the existing values rather than merging with them.
        
        The function supports pipeline input by property name, making it easy to:
        - Update multiple notes from Get-PSNote results
        - Bulk import/update notes from CSV or other structured data
        - Chain with Where-Object for conditional updates
        
        If you need to append tags rather than replace them, retrieve the note first:
        $note = Get-PSNote -Note 'MyNote'
        $newTags = $note.Tags + 'NewTag'
        Set-PSNote -Note 'MyNote' -Tags $newTags

    .LINK
        https://github.com/mdowst/PSNotes

    .LINK
        New-PSNote

    .LINK
        Get-PSNote

    .LINK
        Remove-PSNote
    #>
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    param(
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$True)]
        [string]$Note,
        [parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$True)]
        [string]$Catalog,
        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName=$True)]
        [string]$Snippet,
        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName=$True)]
        [ScriptBlock]$ScriptBlock,
        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName=$True)]
        [string]$ScriptPath,
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName=$True)]
        [string]$Details,
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName=$True)]
        [string]$Alias,
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName=$True)]
        [string[]]$Tags,
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName=$True)]
        [bool]$Run = $false
    )

    begin {
        Test-PSNotesInitalize
    }
    
    process {
        $check = $script:_noteStore.Notes | Where-Object { $_.Note -eq $Note -and $_.Catalog -eq $Catalog }
        if (-not $check) {
            Write-Warning "The note '$Note' does not exist in catalog '$Catalog'. An attempt will be made to create it."
        } 

        New-PSNote @PSBoundParameters -Force
    }
}