---
external help file: PSNotes-help.xml
Module Name: PSNotes
online version: 
schema: 2.0.0
---

# Get-PSNoteAlias

## SYNOPSIS

Use display snippet and copy to clipboard using an Alias

## SYNTAX

### __AllParameterSets

```
Get-PSNoteAlias [-Copy] [-ProgressAction <ActionPreference>] [-Run] [<CommonParameters>]
```

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
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
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

{{ Fill Run Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES

This function is designed to be called via an alias created for each note.
The alias name matches the note name by default but can be customized when creating the note.
When invoked, it retrieves the corresponding note and either executes the snippet or copies it to the clipboard based on parameters and note settings.
 - If the note is set to run by default or the -Run switch is used, it executes the snippet.
 - If the -Copy switch is used, it copies the snippet to the clipboard instead of executing it.
Eventhough the function cannot be called directly, it has to be public to be accessible via the aliases.


## RELATED LINKS

[] (https://github.com/mdowst/PSNotes)

