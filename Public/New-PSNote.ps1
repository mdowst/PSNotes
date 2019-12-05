Function New-PSNote{
    <#
    .SYNOPSIS
        Use to add or update a PSNote object

    .DESCRIPTION
        Allows you to add or update a PSNote object. If note already
        exists you must supply the Force switch to overwrite it.
        Only values supplied with be updated.

    .PARAMETER Note
        The note you want to add/update.

    .PARAMETER Snippet
        The text of the snippet to add/update.

    .PARAMETER ScriptBlock
        Specifies the snippet to save. Enclose the commands in braces { } to create a script block.

    .PARAMETER Details
        The Details of the snippet to add/update.

    .PARAMETER Tag
        The tag of the note(s) you want to return.

    .PARAMETER Alias
        The Alias to create to copy this snippet to your clipboard. If not
        supplied it will use the Note value

    .PARAMETER Tags
        A string array of tags to add/update for the Note

    .PARAMETER Force
        If Note already exists the Force switch is required to overwrite it
    
    .EXAMPLE
        New-PSNote -Note 'ADUser' -Snippet 'Get-AdUser -Filter *' -Details "Use to return all AD users" -Tags 'AD','Users' 

        Creates a new Note for the Get-ADUser cmdlet

    .EXAMPLE
        New-PSNote -Note 'CpuUsage' -Tags 'perf' -Alias 'cpu' -ScriptBlock {
            Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average
        }

        Creates a new Note using a script block instead of a snippet string
    
    .EXAMPLE
        $Snippet = '(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__)'
        New-PSNote -Note 'DayOfWeek' -Snippet $Snippet -Details "Use to name of the day of the week" -Tags 'date' -Alias 'today'

        Creates a new Note for the to get the current day's abbrevation with the custom Alias of today

    .EXAMPLE
        $Snippet = @'
        $stringBuilder = New-Object System.Text.StringBuilder
        for ($i = 0; $i -lt 10; $i++){
            $stringBuilder.Append("Line $i`r`n") | Out-Null
        }
        $stringBuilder.ToString()
        '@
        New-PSNote -Note 'StringBuilder' -Snippet $Snippet -Details "Use StringBuilder to combine multiple strings" -Tags 'string'

        Creates a new Note with a new mulitple line snippet using a here-string

    .LINK
        https://github.com/mdowst/PSNotes
    
    
    #>
    [cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='Low',DefaultParameterSetName="Note")]
    param(
        [parameter(Mandatory=$true)]
        [string]$Note,
        [parameter(Mandatory=$false, ParameterSetName="Snippet")]
        [string]$Snippet,
        [parameter(Mandatory=$false, ParameterSetName="ScriptBlock")]
        [ScriptBlock]$ScriptBlock,
        [parameter(Mandatory=$false)]
        [string]$Details,
        [parameter(Mandatory=$false)]
        [string]$Alias,
        [parameter(Mandatory=$false)]
        [string[]]$Tags,
        [parameter(Mandatory=$false)]
        [switch]$Force
    )
    Function Test-NoteAlias{
        param($Alias)
        
        $AliasCheck = [regex]::Matches($Alias,"[^0-9a-zA-Z\-_]")
        if($AliasCheck.Success){
            throw "'$Alias' is not a valid alias. Alias's can only contain letters, numbers, dashes(-), and underscores (_)."
        } 
    }

    if(-not [string]::IsNullOrEmpty($ScriptBlock)){
        $Snippet = $ScriptBlock.ToString()
    }

    $newNote = $noteObjects | Where-Object{$_.Note -eq $Note}
    if($newNote -and -not $force){
        Write-Error "The note '$Note' already exists. Use -force to overwrite existing properties"
        break
    } elseif($newNote -and $force){
        $noteObjects | Where-Object{$_.Note -eq $Note} | ForEach-Object{
            if(-not [string]::IsNullOrEmpty($Snippet)){
                $_.Snippet = $Snippet
            }
            if(-not [string]::IsNullOrEmpty($Details)){
                $_.Details = $Details
            }
            if(-not [string]::IsNullOrEmpty($Alias)){
                Test-NoteAlias $Alias
                $_.Alias = $Alias
            }
            if(-not [string]::IsNullOrEmpty($Tags)){
                $_.Tags = $Tags
            }
            $_.File = $UserPSNotesJsonFile
        }
    } else {
        if([string]::IsNullOrEmpty($Alias)){
            $Alias = $Note
        }

        Test-NoteAlias $Alias
        
        $newNote = [PSNote]::New($Note, $Snippet, $Details, $Alias, $Tags)
        $noteObjects.Add($newNote)
    }
    
    Set-Alias -Name $newNote.Alias -Value Get-PSNoteAlias -Scope Global

    Update-PSNotesJsonFile
}