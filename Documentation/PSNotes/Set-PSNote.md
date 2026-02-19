---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: https://github.com/mdowst/PSNotes
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Set-PSNote
---

# Set-PSNote

## SYNOPSIS

Updates an existing PSNote or creates a new one if it doesn't exist.

## SYNTAX

### __AllParameterSets

```
Set-PSNote [-Note] <string> [[-Catalog] <string>] [[-Snippet] <string>]
 [[-ScriptBlock] <scriptblock>] [[-ScriptPath] <string>] [[-Details] <string>] [[-Alias] <string>]
 [[-Tags] <string[]>] [[-Run] <bool>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Modifies the properties of an existing PSNote.
If the note does not exist in the 
specified catalog, a warning is displayed and the note will be created.

This function updates only the properties you specify, leaving other properties unchanged.
It internally calls New-PSNote with the -Force parameter to update the note.

The note Kind is automatically set based on the parameter used:
- Snippet or ScriptBlock: Updates to Kind 'Snippet' (inline code)
- ScriptPath: Updates to Kind 'Script' (file reference)

Supports pipeline input by property name, allowing you to pipe objects with Note, Catalog, 
Snippet, Details, Alias, Tags, or Run properties.

## EXAMPLES

### EXAMPLE 1

Set-PSNote -Note 'ADUser' -Tags 'AD','Users','Updated'

Updates the tags for the note 'ADUser' in the Default catalog, replacing any existing tags.

### EXAMPLE 2

$NewSnippet = '(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__)'
Set-PSNote -Note 'DayOfWeek' -Snippet $NewSnippet

Updates the snippet content for the note 'DayOfWeek' while preserving other properties.

### EXAMPLE 3

Set-PSNote -Note 'CpuUsage' -ScriptBlock {
    Get-CimInstance Win32_Processor | 
        Measure-Object -Property LoadPercentage -Average |
        Select-Object -ExpandProperty Average
}

Updates the note 'CpuUsage' with a new multi-line script block using modern cmdlets.

### EXAMPLE 4

Set-PSNote -Note 'CpuUsage' -Details "Returns average CPU usage percentage" -Alias 'cpu'

Updates only the Details and Alias properties for the note 'CpuUsage', leaving the snippet unchanged.

### EXAMPLE 5

Set-PSNote -Note 'ADUser' -Catalog 'Work' -Tags 'AD','Users','Production'

Updates the tags for the note 'ADUser' that exists in the 'Work' catalog.

### EXAMPLE 6

Set-PSNote -Note 'GetDate' -Snippet 'Get-Date -Format "yyyy-MM-dd"' -Details "Returns current date in ISO format" -Tags 'date','formatting'

Updates multiple properties (snippet, details, and tags) of the note 'GetDate' in a single command.

### EXAMPLE 7

Set-PSNote -Note 'TestConnection' -Run $true -Details "Auto-run connectivity test"

Enables auto-execution for the note 'TestConnection'.
When retrieved, it will run automatically.

### EXAMPLE 8

Set-PSNote -Note 'BackupScript' -ScriptPath 'D:\Scripts\Backup-Database.ps1' -Details "Updated backup script location"

Updates an existing note to reference a different script file, changing its Kind to 'Script'.

### EXAMPLE 9

Set-PSNote -Note 'NewFeature' -Snippet 'Get-Service -Name "MyService"' -Details "Check service status"

Creates a new note named 'NewFeature' because it doesn't exist yet.
A warning will be displayed.

### EXAMPLE 10

Get-PSNote -Note 'ADUser' | Set-PSNote -Tags 'AD','Users','Updated'

Retrieves the note 'ADUser' and updates its tags via pipeline by property name.

### EXAMPLE 11

Get-PSNote -Tag 'deprecated' | Set-PSNote -Tags 'archived','old'

Updates all notes tagged 'deprecated' to have tags 'archived' and 'old' instead.
Uses pipeline to process multiple notes at once.

### EXAMPLE 12

Get-PSNote -Catalog 'Work' | Where-Object { $_.Tags -contains 'legacy' } | 
    Set-PSNote -Tags 'archived','legacy','review'

Finds all notes in the Work catalog with the 'legacy' tag and updates their tags.
Demonstrates filtering and bulk updating via pipeline.

### EXAMPLE 13

[PSCustomObject]@{
    Note = 'MyNote'
    Snippet = 'Get-Process | Select-Object -First 10'
    Details = 'Top 10 processes'
    Tags = @('process','monitoring')
} | Set-PSNote

Creates or updates a note using a custom object via pipeline by property name.

### EXAMPLE 14

Import-Csv .\notes.csv | Set-PSNote

Bulk creates or updates notes from a CSV file with columns matching parameter names
(Note, Snippet, Details, Tags, Catalog, etc.).
Processes each row via pipeline.

### EXAMPLE 15

Get-PSNote | Where-Object { $_.Catalog -eq 'Default' } | 
    Set-PSNote -Catalog 'Personal'

Moves all notes from the Default catalog to the Personal catalog via pipeline.

## PARAMETERS

### -Alias

The new alias for this note.
The alias can only contain letters, numbers, dashes (-), 
and underscores (_).
The alias is set as a global alias that invokes Get-PSNoteAlias.
Accepts input from pipeline by property name.

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

The catalog where the note is located.
Defaults to 'Default'.
If the note doesn't exist
in the specified catalog, it will be created there.
Accepts input from pipeline by property name.

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

New description or additional information about the note.
Replaces the existing details.
Accepts input from pipeline by property name.

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

The name of the note to update.
Must match an existing note name in the specified catalog.
Accepts input from pipeline by property name.

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

Updates whether the note should be executed automatically when retrieved.
Set to $true to enable auto-execution, $false to disable it.
Accepts input from pipeline by property name.

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

A PowerShell script block containing the new code to save.
Enclose commands in braces { }.
This is useful for multi-line code with proper syntax highlighting.
Accepts input from pipeline by property name.

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

The file path to a PowerShell script (.ps1) file.
When specified, the note will be 
updated to reference this external script file and the note Kind will be set to 'Script'.
The script file must exist at the specified path.
Accepts input from pipeline by property name.

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

The new snippet text to store in the note.
This replaces the existing snippet content.
Use this for simple one-line or small code snippets.
Accepts input from pipeline by property name.

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

A new string array of tags to associate with the note.
This replaces all existing tags.
Accepts input from pipeline by property name.

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

{{ Fill in the Description }}

### System.Management.Automation.ScriptBlock

{{ Fill in the Description }}

### System.String[]

{{ Fill in the Description }}

### System.Boolean

{{ Fill in the Description }}

## OUTPUTS

## NOTES

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


## RELATED LINKS

- [](https://github.com/mdowst/PSNotes)
- [New-PSNote]()
- [Get-PSNote]()
- [Remove-PSNote]()
