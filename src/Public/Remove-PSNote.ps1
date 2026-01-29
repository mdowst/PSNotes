Function Remove-PSNote{
        <#
    .SYNOPSIS
        Use to remove a Note from you personal store

    .DESCRIPTION
        Allows you to remove a snippets by name. 

    .PARAMETER Note
        The note you want to remove. Has to match exactly

   
    .EXAMPLE
        Remove-PSNote -Note 'creds'

        Removes the Note creds

    .EXAMPLE
        Get-PSNote -Name 'creds' | Remove-PSNote

        Removes the Note creds using pipeline
    
    .EXAMPLE
        Remove-PSNote -Note 'creds' -confirm:$false

        Removes the Note creds without prompting

    .LINK
        https://github.com/mdowst/PSNotes
    #>
    [cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    param(
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$True)]
        [string]$Note,
        [parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$True)]
        [string]$Catalog,
        [parameter(Mandatory=$false)]
        [switch]$Force
    )
    Test-PSNotesInitalize

    $remove = $script:_noteStore.Notes | Where-Object{$_.Note -eq $note -and $_.Catalog -eq $catalog}
    Write-Verbose "Note   : $($note | Out-String)"
    Write-Verbose "remove : $($remove | Out-String)"
    
    
    if($remove){
        if($PSCmdlet.ShouldProcess(
            ("Removing note '{0}'" -f $remove.Note),
            ("Would you like to remove {0}?" -f $remove.Note),
            "Confirm removal"
        )){
            $script:_noteStore.RemoveNote($remove.Note, $remove.Catalog)
        }
    }
    else {
        Write-Warning "Note '$note' not found in catalog '$catalog'. No action taken."
    }

    $remove
}