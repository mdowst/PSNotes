Function Set-PSNote {
    <#
    .SYNOPSIS
        Add or update a PSNote

    .DESCRIPTION
        Adds or updates a PSNote. If the note does not exist, it will be created.
        Only the values you supply are updated.

    .PARAMETER Note
        The name of the note to add or update.

    .PARAMETER Snippet
        The text of the snippet to add or update.

    .PARAMETER ScriptBlock
        Specifies the snippet to save. Enclose the commands in braces { } to create a script block.

    .PARAMETER Details
        The details to add or update for the note.

    .PARAMETER Alias
        The alias to create for this note. If not supplied it will use the Note value.

    .PARAMETER Tags
        A string array of tags to add or update for the note.

    .PARAMETER Catalog
        The catalog to add or update the note in.
    
    .EXAMPLE
        Set-PSNote -Note 'ADUser' -Tags 'AD','Users' 

        Updates the tags for the note 'ADUser' to 'AD' and 'Users'
    
    .EXAMPLE
        $Snippet = '(Get-Culture).DateTimeFormat.GetAbbreviatedDayName((Get-Date).DayOfWeek.value__)'
        Set-PSNote -Note 'DayOfWeek' -Snippet $Snippet

        Updates the snippet for the note 'DayOfWeek'

    .EXAMPLE
        Set-PSNote -Note 'CpuUsage' -ScriptBlock {
            Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average
        }

        Updates the note 'CpuUsage' with a new script block

    .EXAMPLE
        Set-PSNote -Note 'CpuUsage' -Details "Returns CPU usage percentage" -Alias 'cpu'

        Updates the Details and Alias for the note 'CpuUsage'

    .EXAMPLE
        Set-PSNote -Note 'ADUser' -Catalog 'Work' -Tags 'AD','Users','Production'

        Updates the tags for the note 'ADUser' in the 'Work' catalog

    .EXAMPLE
        Set-PSNote -Note 'GetDate' -Snippet 'Get-Date -Format "yyyy-MM-dd"' -Details "Returns current date in ISO format" -Tags 'date','formatting'

        Updates multiple properties of the note 'GetDate' at once

    .EXAMPLE
        Get-PSNote -Note 'ADUser' | Set-PSNote -Tags 'AD','Users','Updated'

        Retrieves the note 'ADUser' and updates its tags via pipeline

    .EXAMPLE
        Get-PSNote -Tag 'deprecated' | Set-PSNote -Tags 'archived','old'

        Updates all notes tagged 'deprecated' to have tags 'archived' and 'old' instead

    .EXAMPLE
        [PSCustomObject]@{
            Note = 'MyNote'
            Snippet = 'Get-Process | Select-Object -First 10'
            Details = 'Top 10 processes'
            Tags = @('process','monitoring')
        } | Set-PSNote

        Creates or updates a note using a custom object via pipeline

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