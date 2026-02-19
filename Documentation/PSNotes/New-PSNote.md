---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: https://github.com/mdowst/PSNotes
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: New-PSNote
---

# New-PSNote

## SYNOPSIS

Creates a new PSNote for storing and reusing code snippets or script references.

## SYNTAX

### Note (Default)

```
New-PSNote -Note <string> [-Details <string>] [-Alias <string>] [-Tags <string[]>]
 [-Catalog <string>] [-Run <bool>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Snippet

```
New-PSNote -Note <string> [-Snippet <string>] [-Details <string>] [-Alias <string>]
 [-Tags <string[]>] [-Catalog <string>] [-Run <bool>] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### ScriptBlock

```
New-PSNote -Note <string> [-ScriptBlock <scriptblock>] [-Details <string>] [-Alias <string>]
 [-Tags <string[]>] [-Catalog <string>] [-Run <bool>] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### ScriptPath

```
New-PSNote -Note <string> [-ScriptPath <string>] [-Details <string>] [-Alias <string>]
 [-Tags <string[]>] [-Catalog <string>] [-Run <bool>] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Creates a new PSNote to store code snippets, script blocks, or references to script files.
PSNotes can be stored in different catalogs and tagged for easy retrieval.
Each note
has an alias that can be used to quickly access it.

If a note with the same name already exists in the specified catalog, you must supply 
the Force switch to overwrite its properties.

The note Kind is automatically set based on the parameter used:
- Snippet or ScriptBlock: Creates a note of Kind 'Snippet' (inline code)
- ScriptPath: Creates a note of Kind 'Script' (file reference)

## EXAMPLES

### EXAMPLE 1

New-PSNote -Note 'GetServices' -Snippet 'Get-Service | Where-Object Status -eq Running' -Alias 'running'

Creates a simple note with a one-line snippet.
The snippet can be retrieved or executed using the alias 'running'.

### EXAMPLE 2

New-PSNote -Note 'DayOfWeek' -Alias 'today' -Snippet '(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__)' -Details "Returns the abbreviated name of the current day" -Tags 'date','time'

Creates a note with a snippet, description, and multiple tags for easy searching.

### EXAMPLE 3

New-PSNote -Note 'CpuUsage' -Tags 'perf','monitoring' -Alias 'cpu' -ScriptBlock {
    Get-CimInstance Win32_Processor | 
        Measure-Object -Property LoadPercentage -Average | 
        Select-Object -ExpandProperty Average
}

Creates a note using a script block with multi-line code and a custom alias 'cpu'.

### EXAMPLE 4

$MultiLineSnippet = @'
$sb = [System.Text.StringBuilder]::new()
for ($i = 1; $i -le 10; $i++) {
    [void]$sb.AppendLine("Item $i")
}
$sb.ToString()
'@
New-PSNote -Note 'StringBuilder' -Snippet $MultiLineSnippet -Details "Demonstrates StringBuilder usage" -Tags 'string','performance'

Creates a note with a multi-line snippet stored in a here-string variable.

### EXAMPLE 5

New-PSNote -Note 'GetDateIso' -Snippet 'Get-Date -Format "yyyy-MM-dd"' -Catalog 'Work' -Tags 'date','formatting'

Creates a new note in the 'Work' catalog instead of the default catalog.

### EXAMPLE 6

New-PSNote -Note 'TestConnection' -Alias 'test-conn' -Snippet 'Test-Connection -ComputerName 8.8.8.8 -Count 2 -Quiet' -Run $true -Details "Quick connectivity test"

Creates a note that will automatically execute when retrieved (Run = $true).

### EXAMPLE 7

New-PSNote -Note 'DeploymentScript' -ScriptPath 'C:\Scripts\Deploy-Application.ps1' -Details "Main deployment script for production" -Tags 'deployment','production','automation' -Catalog 'Work'

Creates a note that references an external script file.
The note Kind will be 'Script'.
The script file must exist at the specified path.

### EXAMPLE 8

New-PSNote -Note 'BackupScript' -ScriptPath '\\FileServer\Scripts\Backup.ps1' -Alias 'backup' -Details "Automated backup script" -Tags 'backup','maintenance'

Creates a note referencing a script on a network share with a custom alias.

### EXAMPLE 9

New-PSNote -Note 'GetServices' -Snippet 'Get-Service | Sort-Object Status' -Force

Updates an existing note named 'GetServices' with new snippet content using the -Force switch.
Without -Force, this would throw an error if the note already exists.

### EXAMPLE 10

New-PSNote -Note 'QuickTest' -Snippet 'Write-Host "Test"' -Details "Original"
New-PSNote -Note 'QuickTest' -Snippet 'Write-Host "Updated"' -Details "Modified version" -Force

Demonstrates creating a note and then updating it with the -Force parameter.

## PARAMETERS

### -Alias

The alias to create for this note.
If not supplied, it will use the Note name as the alias.
The alias can only contain letters, numbers, dashes (-), and underscores (_).
The alias is set as a global alias that invokes Get-PSNoteAlias.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
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

### -Catalog

The catalog to add the note to.
Catalogs are used to organize notes into different 
collections (e.g., 'Personal', 'Work', 'Team').
Defaults to 'Default'.

```yaml
Type: System.String
DefaultValue: Default
SupportsWildcards: false
Aliases: []
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
This helps document what the 
note does and when to use it.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
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

### -Force

Forces the creation of the note even if a note with the same name already exists in 
the catalog.
Without this switch, an error will be thrown if the note already exists.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
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

### -Note

The unique name of the note to create within the specified catalog.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Run

Indicates whether the note should be executed automatically when retrieved.

When set to $true, the note will run when accessed.
When set to $false (default), 
the note content will be returned without execution.

```yaml
Type: System.Boolean
DefaultValue: False
SupportsWildcards: false
Aliases: []
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

### -ScriptBlock

A PowerShell script block containing the code to save.
Enclose the commands in braces { } 
to create a script block.
This is useful for multi-line code with proper syntax highlighting.

```yaml
Type: System.Management.Automation.ScriptBlock
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ScriptBlock
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ScriptPath

The file path to a PowerShell script (.ps1) file.
When specified, the note will reference 
this external script file and the note Kind will be set to 'Script'.
The script file must 
exist at the specified path.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ScriptPath
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Snippet

The text of the code snippet to store.
This is typically a single line or small block 
of PowerShell code.
Use this parameter for simple snippets.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Snippet
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Tags

A string array of tags to associate with the note.
Tags help categorize and search for 
notes.
Multiple tags can be specified.

```yaml
Type: System.String[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
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

## OUTPUTS

## NOTES

The note alias is created as a global alias pointing to Get-PSNoteAlias.
This allows you to simply type the alias to retrieve or run the note.


## RELATED LINKS

- [](https://github.com/mdowst/PSNotes)
- [Get-PSNote]()
- [Set-PSNote]()
- [Remove-PSNote]()
