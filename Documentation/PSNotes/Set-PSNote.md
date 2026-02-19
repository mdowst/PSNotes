---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Set-PSNote
---

# Set-PSNote

## SYNOPSIS

Updates an existing PSNote or creates it if it does not already exist.

## SYNTAX

### __AllParameterSets

```
Set-PSNote [-Note] <string> [[-Catalog] <string>] [[-Snippet] <string>]
 [[-ScriptBlock] <scriptblock>] [[-ScriptPath] <string>] [[-Details] <string>] [[-Alias] <string>]
 [[-Tags] <string[]>] [[-Run] <bool>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Set-PSNote modifies one or more properties of an existing note in the PSNotes store.
If the
target note does not exist in the specified catalog, a warning is written and the note is
created.

Only the properties you provide are updated.
Properties you do not specify remain unchanged.
Internally, this cmdlet delegates to New-PSNote with -Force to perform an “upsert”.

The note Kind is inferred from the content parameter you use:
- Snippet or ScriptBlock sets Kind to 'Snippet' (inline code)
- ScriptPath sets Kind to 'Script' (file reference)

Set-PSNote supports pipeline input by property name, which makes it easy to bulk update notes
from Get-PSNote output or structured data sources such as CSV.

## EXAMPLES

### EXAMPLE 1

```powershell
Set-PSNote -Note 'ADUser' -Tags 'AD','Users','Updated'
```

Updates the Tags for the note 'ADUser' in the Default catalog, replacing any existing tags.

### EXAMPLE 2

```powershell
$NewSnippet = '(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__))'
PS> Set-PSNote -Note 'DayOfWeek' -Snippet $NewSnippet
```

Updates only the snippet content for the note 'DayOfWeek' while leaving other properties unchanged.

### EXAMPLE 3

```powershell
Set-PSNote -Note 'CpuUsage' -ScriptBlock {
    Get-CimInstance Win32_Processor |
        Measure-Object -Property LoadPercentage -Average |
        Select-Object -ExpandProperty Average
}
```

Updates the note 'CpuUsage' with a new multi-line script block.

### EXAMPLE 4

```powershell
Set-PSNote -Note 'CpuUsage' -Details "Returns average CPU usage percentage" -Alias 'cpu'
```

Updates only the Details and Alias properties for the note 'CpuUsage'.

### EXAMPLE 5

```powershell
Set-PSNote -Note 'BackupScript' -ScriptPath 'D:\Scripts\Backup-Database.ps1' -Details "Updated backup script location"
```

Updates an existing note to reference a different script file, changing Kind to 'Script'.

### EXAMPLE 6

```powershell
Get-PSNote -Tag 'deprecated' | Set-PSNote -Tags 'archived','old'
```

Bulk-updates notes by piping objects from Get-PSNote and replacing their Tags.

### EXAMPLE 7

```powershell
[PSCustomObject]@{
    Note    = 'MyNote'
    Snippet = 'Get-Process | Select-Object -First 10'
    Details = 'Top 10 processes'
    Tags    = @('process','monitoring')
} | Set-PSNote
```

Creates or updates a note using pipeline input by property name.

## PARAMETERS

### -Alias

A new alias for the note.

Aliases may contain letters, numbers, dashes (-), and underscores (_).
The alias is registered
as a global alias that invokes Get-PSNoteAlias.

Accepts pipeline input by property name.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 6
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Catalog

The catalog where the note is stored.
Defaults to 'Default'.

If the note does not exist in the specified catalog, it will be created there.
Accepts pipeline input by property name.

```yaml
Type: System.String
DefaultValue: Default
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- cf
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Details

A description or additional information about the note.
Replaces the existing details.

Accepts pipeline input by property name.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 5
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Note

The name of the note to update or create.

Accepts pipeline input by property name.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Run

Controls whether the note should be executed automatically when retrieved (if supported by your
workflow).
Set to $true to enable, or $false to disable.

Accepts pipeline input by property name.

```yaml
Type: System.Boolean
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 8
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ScriptBlock

A PowerShell script block containing the code to store in the note.

Accepts pipeline input by property name.

```yaml
Type: System.Management.Automation.ScriptBlock
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 3
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ScriptPath

A file path to a PowerShell script (.ps1).
When specified, the note references this script and
Kind is set to 'Script'.
The file must exist.

Accepts pipeline input by property name.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 4
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Snippet

The snippet text to store in the note.
Replaces the existing snippet content.

Accepts pipeline input by property name.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 2
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Tags

A list of tags to associate with the note.
This replaces all existing tags.

Accepts pipeline input by property name.

```yaml
Type: System.String[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 7
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- wi
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String


### System.Management.Automation.ScriptBlock


### System.String[]


### System.Boolean


## OUTPUTS

### PSNote


## NOTES

- Supports -WhatIf and -Confirm through ShouldProcess.
- This cmdlet is a convenience wrapper around New-PSNote -Force (an “upsert” operation).
- Updates replace existing values rather than merging (for example, Tags are replaced, not appended).
  To append tags, retrieve the note first and then set the combined list.
- See also: New-PSNote, Get-PSNote, Remove-PSNote, Get-PSNoteAlias


## RELATED LINKS


