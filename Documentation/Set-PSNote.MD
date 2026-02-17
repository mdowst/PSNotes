---
external help file: PSNotes-help.xml
Module Name: PSNotes
online version: 
schema: 2.0.0
---

# Set-PSNote

## SYNOPSIS

Updates an existing PSNote or creates a new one if it doesn't exist.

## SYNTAX

### __AllParameterSets

```
Set-PSNote [-Note] <String> [[-Catalog <String>]] [[-Snippet <String>]] [[-ScriptBlock <ScriptBlock>]] [[-ScriptPath <String>]] [[-Details <String>]] [[-Alias <String>]] [[-Tags <String[]>]] [[-Run <Boolean>]] [-Confirm] [-ProgressAction <ActionPreference>] [-WhatIf] [<CommonParameters>]
```

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

### Example 1: EXAMPLE 1

```
Set-PSNote -Note 'ADUser' -Tags 'AD','Users','Updated'
```

Updates the tags for the note 'ADUser' in the Default catalog, replacing any existing tags.





### Example 2: EXAMPLE 2

```
$NewSnippet = '(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__)'
Set-PSNote -Note 'DayOfWeek' -Snippet $NewSnippet
```

Updates the snippet content for the note 'DayOfWeek' while preserving other properties.





### Example 3: EXAMPLE 3

```
Set-PSNote -Note 'CpuUsage' -ScriptBlock {
    Get-CimInstance Win32_Processor | 
        Measure-Object -Property LoadPercentage -Average |
        Select-Object -ExpandProperty Average
}
```

Updates the note 'CpuUsage' with a new multi-line script block using modern cmdlets.





### Example 4: EXAMPLE 4

```
Set-PSNote -Note 'CpuUsage' -Details "Returns average CPU usage percentage" -Alias 'cpu'
```

Updates only the Details and Alias properties for the note 'CpuUsage', leaving the snippet unchanged.





### Example 5: EXAMPLE 5

```
Set-PSNote -Note 'ADUser' -Catalog 'Work' -Tags 'AD','Users','Production'
```

Updates the tags for the note 'ADUser' that exists in the 'Work' catalog.





### Example 6: EXAMPLE 6

```
Set-PSNote -Note 'GetDate' -Snippet 'Get-Date -Format "yyyy-MM-dd"' -Details "Returns current date in ISO format" -Tags 'date','formatting'
```

Updates multiple properties (snippet, details, and tags) of the note 'GetDate' in a single command.





### Example 7: EXAMPLE 7

```
Set-PSNote -Note 'TestConnection' -Run $true -Details "Auto-run connectivity test"
```

Enables auto-execution for the note 'TestConnection'.
When retrieved, it will run automatically.





### Example 8: EXAMPLE 8

```
Set-PSNote -Note 'BackupScript' -ScriptPath 'D:\Scripts\Backup-Database.ps1' -Details "Updated backup script location"
```

Updates an existing note to reference a different script file, changing its Kind to 'Script'.





### Example 9: EXAMPLE 9

```
Set-PSNote -Note 'NewFeature' -Snippet 'Get-Service -Name "MyService"' -Details "Check service status"
```

Creates a new note named 'NewFeature' because it doesn't exist yet.
A warning will be displayed.





### Example 10: EXAMPLE 10

```
Get-PSNote -Note 'ADUser' | Set-PSNote -Tags 'AD','Users','Updated'
```

Retrieves the note 'ADUser' and updates its tags via pipeline by property name.





### Example 11: EXAMPLE 11

```
Get-PSNote -Tag 'deprecated' | Set-PSNote -Tags 'archived','old'
```

Updates all notes tagged 'deprecated' to have tags 'archived' and 'old' instead.
Uses pipeline to process multiple notes at once.





### Example 12: EXAMPLE 12

```
Get-PSNote -Catalog 'Work' | Where-Object { $_.Tags -contains 'legacy' } | 
    Set-PSNote -Tags 'archived','legacy','review'
```

Finds all notes in the Work catalog with the 'legacy' tag and updates their tags.
Demonstrates filtering and bulk updating via pipeline.





### Example 13: EXAMPLE 13

```
[PSCustomObject]@{
    Note = 'MyNote'
    Snippet = 'Get-Process | Select-Object -First 10'
    Details = 'Top 10 processes'
    Tags = @('process','monitoring')
} | Set-PSNote
```

Creates or updates a note using a custom object via pipeline by property name.





### Example 14: EXAMPLE 14

```
Import-Csv .\notes.csv | Set-PSNote
```

Bulk creates or updates notes from a CSV file with columns matching parameter names
(Note, Snippet, Details, Tags, Catalog, etc.).
Processes each row via pipeline.





### Example 15: EXAMPLE 15

```
Get-PSNote | Where-Object { $_.Catalog -eq 'Default' } | 
    Set-PSNote -Catalog 'Personal'
```

Moves all notes from the Default catalog to the Personal catalog via pipeline.






## PARAMETERS

### -Alias

The new alias for this note.
The alias can only contain letters, numbers, dashes (-), 
and underscores (_).
The alias is set as a global alias that invokes Get-PSNoteAlias.
Accepts input from pipeline by property name.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 6
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -Catalog

The catalog where the note is located.
Defaults to 'Default'.
If the note doesn't exist
in the specified catalog, it will be created there.
Accepts input from pipeline by property name.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: Default
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -Confirm

{{ Fill Confirm Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Details

New description or additional information about the note.
Replaces the existing details.
Accepts input from pipeline by property name.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 5
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -Note

The name of the note to update.
Must match an existing note name in the specified catalog.
Accepts input from pipeline by property name.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 0
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -ProgressAction

{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Run

Updates whether the note should be executed automatically when retrieved.
Set to $true to enable auto-execution, $false to disable it.
Accepts input from pipeline by property name.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 8
Default value: False
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -ScriptBlock

A PowerShell script block containing the new code to save.
Enclose commands in braces { }.
This is useful for multi-line code with proper syntax highlighting.
Accepts input from pipeline by property name.

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 3
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -ScriptPath

The file path to a PowerShell script (.ps1) file.
When specified, the note will be 
updated to reference this external script file and the note Kind will be set to 'Script'.
The script file must exist at the specified path.
Accepts input from pipeline by property name.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 4
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -Snippet

The new snippet text to store in the note.
This replaces the existing snippet content.
Use this for simple one-line or small code snippets.
Accepts input from pipeline by property name.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 2
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -Tags

A new string array of tags to associate with the note.
This replaces all existing tags.
Accepts input from pipeline by property name.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 7
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -WhatIf

{{ Fill WhatIf Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

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

[] (https://github.com/mdowst/PSNotes)

[New-PSNote] ()

[Get-PSNote] ()

[Remove-PSNote] ()

