---
external help file: PSNotes-help.xml
Module Name: PSNotes
online version: 
schema: 2.0.0
---

# Import-RemoteCatalog

## SYNOPSIS

Registers or imports a remote catalog.

## SYNTAX

### __AllParameterSets

```
Import-RemoteCatalog [-Name] <String> [-Url] <String> [-AsLocal] [-Force] [-PassThru] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Registers a remote catalog URL in the note store, or downloads it immediately
as a local catalog when -AsLocal is specified.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Import-RemoteCatalog -Name 'github' -Url 'https://example.com/psnotes.json'
Registers the remote catalog URL for later use.
```







### Example 2: EXAMPLE 2

```
Import-RemoteCatalog -Name 'github' -Url 'https://example.com/psnotes.json' -AsLocal
Downloads the remote catalog and creates a local catalog.
```







### Example 3: EXAMPLE 3

```
Import-RemoteCatalog -Name 'github' -Url 'https://example.com/psnotes.json' -AsLocal -Force -PassThru
Overwrites the local catalog and returns the created catalog object.
```








## PARAMETERS

### -AsLocal

Downloads the remote catalog immediately and creates a LOCAL catalog.
When specified, the URL is not registered.

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

### -Force

Only applies to -AsLocal.
Overwrites the local catalog if it already exists.

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

### -Name

The name to register for the remote catalog.

```yaml
Type: String
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

### -PassThru

Returns the created or registered catalog object.

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

### -Url

The URL of the remote catalog JSON.

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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## OUTPUTS

### System.Object
Returns catalog objects when -PassThru is specified; otherwise returns nothing.


## NOTES



## RELATED LINKS

[Get-RemoteCatalog
Remove-RemoteCatalog] ()

