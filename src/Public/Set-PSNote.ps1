Function Set-PSNote {
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
        Specifies the snippet to save. Enclose the commands in braces { } to create a script block

    .PARAMETER Details
        The Details of the snippet to add/update.

    .PARAMETER Tag
        The tag of the note(s) you want to return.

    .PARAMETER Alias
        The Alias to create to copy this snippet to your clipboard. If not
        supplied it will use the Note value

    .PARAMETER Tags
        A string array of tags to add/update for the Note
    
    .EXAMPLE
        Set-PSNote -Note 'ADUser' -Tags 'AD','Users' 

        Set the tags AD and User for the note ADUser
    
    .EXAMPLE
        $Snippet = '(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__)'
        Set-PSNote -Note 'DayOfWeek' -Snippet $Snippet

        Updates the snippet for the note DayOfWeek

    .LINK
        https://github.com/mdowst/PSNotes
    
    
    #>
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low', DefaultParameterSetName = "Snippet")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    param(
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$True)]
        [string]$Note,
        [parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$True)]
        [string]$Catalog,
        [parameter(Mandatory = $false, ParameterSetName = "Snippet",ValueFromPipelineByPropertyName=$True)]
        [string]$Snippet,
        [parameter(Mandatory = $false, ParameterSetName = "ScriptBlock",ValueFromPipelineByPropertyName=$True)]
        [ScriptBlock]$ScriptBlock,
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName=$True)]
        [string]$Details,
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName=$True)]
        [string]$Alias,
        [parameter(Mandatory = $false,ValueFromPipelineByPropertyName=$True)]
        [string[]]$Tags
    )
    
    begin {
        Test-PSNotesInitalize
    }
    
    process {
        $check = $script:_noteStore.Notes | Where-Object { $_.Note -eq $Note -and $_.Catalog -eq $Catalog }
        if (-not $check) {
            Write-Warning "The note '$Note' does not exist in catalog '$Catalog'. An attempt will be made to create it."
        } 

        New-PSNote @PSBoundParameters -Force
    }
}