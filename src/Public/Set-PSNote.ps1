<#
.SYNOPSIS
Updates an existing PSNote or creates it if it does not already exist.

.DESCRIPTION
Set-PSNote modifies one or more properties of an existing note in the PSNotes store. If the
target note does not exist in the specified catalog, a warning is written and the note is
created.

Only the properties you provide are updated. Properties you do not specify remain unchanged.
Internally, this cmdlet delegates to New-PSNote with -Force to perform an “upsert”.

The note Kind is inferred from the content parameter you use:
- Snippet or ScriptBlock sets Kind to 'Snippet' (inline code)
- ScriptPath sets Kind to 'Script' (file reference)

Set-PSNote supports pipeline input by property name, which makes it easy to bulk update notes
from Get-PSNote output or structured data sources such as CSV.

.FUNCTIONALITY
PSNotes Notes

.ROLE
Public

.COMPONENT
Notes

.PARAMETER Name
The name of the note to update or create.

Accepts pipeline input by property name.

.PARAMETER Catalog
The catalog where the note is stored. Defaults to 'Default'.

If the note does not exist in the specified catalog, it will be created there.
Accepts pipeline input by property name.

.PARAMETER Snippet
The snippet text to store in the note. Replaces the existing snippet content.

Accepts pipeline input by property name.

.PARAMETER ScriptBlock
A PowerShell script block containing the code to store in the note.

Accepts pipeline input by property name.

.PARAMETER ScriptPath
A file path to a PowerShell script (.ps1). When specified, the note references this script and
Kind is set to 'Script'. The file must exist.

Accepts pipeline input by property name.

.PARAMETER Details
A description or additional information about the note. Replaces the existing details.

Accepts pipeline input by property name.

.PARAMETER Alias
A new alias for the note.

Aliases may contain letters, numbers, dashes (-), and underscores (_). The alias is registered
as a global alias that invokes Get-PSNoteAlias.

Accepts pipeline input by property name.

.PARAMETER Tags
A list of tags to associate with the note. This replaces all existing tags.

Accepts pipeline input by property name.

.PARAMETER Run
Controls whether the note should be executed automatically when retrieved (if supported by your
workflow). Set to $true to enable, or $false to disable.

Accepts pipeline input by property name.

.EXAMPLE
PS> Set-PSNote -Name 'ADUser' -Tags 'AD','Users','Updated'

Updates the Tags for the note 'ADUser' in the Default catalog, replacing any existing tags.

.EXAMPLE
PS> $NewSnippet = '(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__))'
PS> Set-PSNote -Name 'DayOfWeek' -Snippet $NewSnippet

Updates only the snippet content for the note 'DayOfWeek' while leaving other properties unchanged.

.EXAMPLE
PS> Set-PSNote -Name 'CpuUsage' -ScriptBlock {
    Get-CimInstance Win32_Processor |
        Measure-Object -Property LoadPercentage -Average |
        Select-Object -ExpandProperty Average
}

Updates the note 'CpuUsage' with a new multi-line script block.

.EXAMPLE
PS> Set-PSNote -Name 'CpuUsage' -Details "Returns average CPU usage percentage" -Alias 'cpu'

Updates only the Details and Alias properties for the note 'CpuUsage'.

.EXAMPLE
PS> Set-PSNote -Name 'BackupScript' -ScriptPath 'D:\Scripts\Backup-Database.ps1' -Details "Updated backup script location"

Updates an existing note to reference a different script file, changing Kind to 'Script'.

.EXAMPLE
PS> Get-PSNote -Tag 'deprecated' | Set-PSNote -Tags 'archived','old'

Bulk-updates notes by piping objects from Get-PSNote and replacing their Tags.

.EXAMPLE
PS> [PSCustomObject]@{
    Note    = 'MyNote'
    Snippet = 'Get-Process | Select-Object -First 10'
    Details = 'Top 10 processes'
    Tags    = @('process','monitoring')
} | Set-PSNote

Creates or updates a note using pipeline input by property name.

.OUTPUTS
PSNote

.NOTES
- Supports -WhatIf and -Confirm through ShouldProcess.
- This cmdlet is a convenience wrapper around New-PSNote -Force (an “upsert” operation).
- Updates replace existing values rather than merging (for example, Tags are replaced, not appended).
  To append tags, retrieve the note first and then set the combined list.
- See also: New-PSNote, Get-PSNote, Remove-PSNote, Get-PSNoteAlias
#>
Function Set-PSNote {
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    param(
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$True)]
        [string]$Name,
        [parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$True)]
        [string]$Catalog = 'Default',
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
        $check = $script:_noteStore.Notes | Where-Object { $_.Name -eq $Name -and $_.Catalog -eq $Catalog }
        if (-not $check) {
            Write-Warning "The note '$Name' does not exist in catalog '$Catalog'. An attempt will be made to create it."
        } 

        New-PSNote @PSBoundParameters -Force
    }
}