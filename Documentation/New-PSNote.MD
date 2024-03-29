# New-PSNote

<a name="New-PSNote"></a>
## New-PSNote
### Synopsis
Use to add or update a PSNote object
### Description
Allows you to add or update a PSNote object. If note already
exists you must supply the Force switch to overwrite it.
Only values supplied with be updated.

### Syntax
```powershell
New-PSNote -Note <string> [-Details <string>] [-Alias <string>] [-Tags <string[]>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

New-PSNote -Note <string> [-Snippet <string>] [-Details <string>] [-Alias <string>] [-Tags <string[]>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

New-PSNote -Note <string> [-ScriptBlock <scriptblock>] [-Details <string>] [-Alias <string>] [-Tags <string[]>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
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
    Specifies the snippet to save. Enclose the commands in braces { } to create a script block.
    
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
#### Force [&lt;SwitchParameter&gt;]
    If Note already exists the Force switch is required to overwrite it
    
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
#### Example 1: Creates a new Note for the Get-ADUser cmdlet
```powershell
New-PSNote -Note 'ADUser' -Snippet 'Get-AdUser -Filter *' -Details "Use to return all AD users" -Tags 'AD','Users'
```

#### Example 2: Creates a new Note using a script block instead of a snippet string
```powershell
New-PSNote -Note 'CpuUsage' -Tags 'perf' -Alias 'cpu' -ScriptBlock {
Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average
}
```

#### Example 3: Creates a new Note for the to get the current day's abbrevation with the custom Alias of today
```powershell
$Snippet = '(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__)'
New-PSNote -Note 'DayOfWeek' -Snippet $Snippet -Details "Use to name of the day of the week" -Tags 'date' -Alias 'today'
```

#### Example 4: Creates a new Note with a new mulitple line snippet using a here-string
```powershell
$Snippet = @'
$stringBuilder = New-Object System.Text.StringBuilder
for ($i = 0; $i -lt 10; $i++){
    $stringBuilder.Append("Line $i`r`n") | Out-Null
}
$stringBuilder.ToString()
'@
New-PSNote -Note 'StringBuilder' -Snippet $Snippet -Details "Use StringBuilder to combine multiple strings" -Tags 'string'
```

