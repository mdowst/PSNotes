---
document type: cmdlet
external help file: PSNotes-Help.xml
HelpUri: https://github.com/mdowst/PSNotes
Locale: en-US
Module Name: PSNotes
ms.date: 02/19/2026
PlatyPS schema version: 2024-05-01
title: Get-PSNoteAlias
---

# Get-PSNoteAlias

## SYNOPSIS

Use display snippet and copy to clipboard using an Alias

## SYNTAX

### __AllParameterSets

```
Get-PSNoteAlias [-Copy] [-Run] [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

When the PSNotes module loads, it creates Aliases for all snippets.
Those aliases are mapped to this command and it will return the snippet
and copy it to your clipboard.
You cannot call this function directly
as it will not return anything.

## EXAMPLES

## PARAMETERS

### -Copy

{{ Fill Copy Description }}

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

### -Run

{{ Fill Run Description }}

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

This function is designed to be called via an alias created for each note.
The alias name matches the note name by default but can be customized when creating the note.
When invoked, it retrieves the corresponding note and either executes the snippet or copies it to the clipboard based on parameters and note settings.
 - If the note is set to run by default or the -Run switch is used, it executes the snippet.
 - If the -Copy switch is used, it copies the snippet to the clipboard instead of executing it.
Eventhough the function cannot be called directly, it has to be public to be accessible via the aliases.


## RELATED LINKS

- [](https://github.com/mdowst/PSNotes)
