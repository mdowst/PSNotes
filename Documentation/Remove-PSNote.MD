# Remove-PSNote

<a name="Remove-PSNote"></a>
## Remove-PSNote
### Synopsis
Use to remove a Note from you personal store
### Description
Allows you to remove a snippets by name.

### Syntax
```powershell
Remove-PSNote [-Note] <string> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```
### Parameters
#### Note &lt;String&gt;
    The note you want to remove. Has to match exactly
    
    Required?                    true
    Position?                    1
    Default value                
    Accept pipeline input?       true (ByPropertyName)
    Accept wildcard characters?  false
#### Force [&lt;SwitchParameter&gt;]
    
    Required?                    false
    Position?                    named
    Default value                False
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### WhatIf [&lt;SwitchParameter&gt;]
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### Confirm [&lt;SwitchParameter&gt;]
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
### Examples
#### Example 1: Removes the Note creds
```powershell
Remove-PSNote -Note 'creds'
```

#### Example 2: Removes the Note creds using pipeline
```powershell
Get-PSNote -Name 'creds' | Remove-PSNote
```

#### Example 3: Removes the Note creds without prompting
```powershell
Remove-PSNote -Note 'creds' -confirm:$false
```

