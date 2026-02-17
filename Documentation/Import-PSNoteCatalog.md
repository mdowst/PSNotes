---
external help file: PSNotes-help.xml
Module Name: PSNotes
online version: 
schema: 2.0.0
---

# Import-PSNoteCatalog

## SYNOPSIS

Use to import a PSNotes JSON fiile

## SYNTAX

### __AllParameterSets

```
Import-PSNoteCatalog [-ImportedCatalog] <NoteCatalog> [-DestinationCatalog] <String> [[-DefaultBehavior <String>]] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Allows you to import shared PSNotes JSON files to your local notes.
They can be imported to your personal
store, or they can be imported to a seperate file.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Import-PSNote -Path C:\Import\MyPSNotes.json
```

Imports the contents of the file MyPSNotes.json and saves it to your personal PSNotes.json file





### Example 2: EXAMPLE 2

```
Import-PSNote -Path C:\Export\MyPSNotes.json -Catalog 'ADNotes'
```

Imports the contents of the file MyPSNotes.json and saves it to the file ADNotes.json in the folder %APPDATA%\PSNotes






## PARAMETERS

### -DefaultBehavior

{{ Fill DefaultBehavior Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 2
Default value: Prompt
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -DestinationCatalog

{{ Fill DestinationCatalog Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 1
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ImportedCatalog

{{ Fill ImportedCatalog Description }}

```yaml
Type: NoteCatalog
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 0
Default value: 
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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

[] (https://github.com/mdowst/PSNotes)

