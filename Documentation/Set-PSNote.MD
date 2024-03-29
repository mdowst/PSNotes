# Set-PSNote

<a name="Set-PSNote"></a>
## Set-PSNote
### Synopsis
Use to add or update a PSNote object
### Description
Allows you to add or update a PSNote object. If note already
exists you must supply the Force switch to overwrite it.
Only values supplied with be updated.

### Syntax
```powershell
Set-PSNote -Note <string> [-Details <string>] [-Alias <string>] [-Tags <string[]>] [-WhatIf] [-Confirm] [<CommonParameters>]

Set-PSNote -Note <string> [-Snippet <string>] [-Details <string>] [-Alias <string>] [-Tags <string[]>] [-WhatIf] [-Confirm] [<CommonParameters>]

Set-PSNote -Note <string> [-ScriptBlock <scriptblock>] [-Details <string>] [-Alias <string>] [-Tags <string[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
```
### Parameters
#### Note &lt;String&gt;
    The note you want to add/update.
    
    Required?                    true
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### Snippet &lt;String&gt;
    The text of the snippet to add/update.
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### ScriptBlock &lt;ScriptBlock&gt;
    Specifies the snippet to save. Enclose the commands in braces { } to create a script block
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### Details &lt;String&gt;
    The Details of the snippet to add/update.
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### Alias &lt;String&gt;
    The Alias to create to copy this snippet to your clipboard. If not
    supplied it will use the Note value
    
    Required?                    false
    Position?                    named
    Default value                
    Accept pipeline input?       false
    Accept wildcard characters?  false
#### Tags &lt;String[]&gt;
    A string array of tags to add/update for the Note
    
    Required?                    false
    Position?                    named
    Default value                
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
#### Example 1: Set the tags AD and User for the note ADUser
```powershell
Set-PSNote -Note 'ADUser' -Tags 'AD','Users'
```

#### Example 2: Updates the snippet for the note DayOfWeek
```powershell
$Snippet = '(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__)'
Set-PSNote -Note 'DayOfWeek' -Snippet $Snippet
```

