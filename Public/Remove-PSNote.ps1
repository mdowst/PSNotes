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
        [parameter(Mandatory=$false)]
        [switch]$Force
    )

    $remove = $noteObjects | Where-Object{$_.Note -eq $note}
    Write-Verbose "Note   : $($note | Out-String)"
    Write-Verbose "remove : $($remove | Out-String)"
    
    
    if($remove){
        if($PSCmdlet.ShouldProcess(
            ("Removing note '{0}'" -f $remove.Note),
            ("Would you like to remove {0}?" -f $remove.Note),
            "Confirm removal"
        )){
            if($noteObjects.Remove($remove)){
                Update-PSNotesJsonFile
            }
        }
    }
    
    
    
    $remove

}