Function Set-PSNote{
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
    [cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    param(
        [parameter(Mandatory=$true)]
        [string]$Note,
        [parameter(Mandatory=$false)]
        [string]$Snippet,
        [parameter(Mandatory=$false)]
        [string]$Details,
        [parameter(Mandatory=$false)]
        [string]$Alias,
        [parameter(Mandatory=$false)]
        [string[]]$Tags
    )

    $check = $noteObjects | Where-Object{$_.Note -eq $Note}
    if(-not $check){
        Write-Warning "The note '$Note' does not exists. An attempt will be made to create it."
    } 

    New-PSNote @PSBoundParameters -Force
}