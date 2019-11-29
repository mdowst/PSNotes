Function Export-PSNote{
    <#
    .SYNOPSIS
        Use to export your PSNotes to copy to another machine or share with others

    .DESCRIPTION
        Allows you to export your PSNotes to a JSON file, that can then be imported
        to another machine or by other users. 

    .PARAMETER NoteObject
        The PSNote objects you want to export. Use Get-PSNote to build the object and pass it to the parameter
        or use a pipeline to pass it.

    .PARAMETER All
        Export all PSNotes

    .PARAMETER Path
        The path to the PSNotes JSON file to export to.

    .PARAMETER Append
        Use to append the output file. Default is to overwrite.

    .EXAMPLE
        Export-PSNote -All -Path C:\Export\MyPSNotes.json

        Export

    .EXAMPLE
        Get-PSNote -tag 'AD' | Export-PSNote -Path C:\Export\SharedADNotes.json

        Exports all notes with the tag 'AD' to the file SharedADNotes.json
    
    
    
    .LINK
        https://github.com/mdowst/PSNotes
    #>
    [cmdletbinding(DefaultParameterSetName="Note")]
    param(    
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="Note")]
        [PSNote[]]$NoteObject,
        [parameter(Mandatory=$false, ParameterSetName="All")]
        [switch]$All,
        [parameter(Mandatory=$true)]
        [string]$Path,
        [parameter(Mandatory=$false)]
        [switch]$Append
    )
    begin{
        [System.Collections.Generic.List[PSNoteExport]] $ExportObjects = @()
        Write-Verbose "$($noteObject | FT | Out-String)"
    }
    process{
        # If All add all objects otherwise only add those passed
        if($All){
            $noteObjects | ForEach-Object{ $ExportObjects.Add( [PSNoteExport]::New( $_ ) ) }
        } else {
            $noteObject | ForEach-Object{ $ExportObjects.Add( [PSNoteExport]::New( $_ ) ) }
        }
    }
    end{
        Write-Verbose "$($ExportObjects | FT | Out-String)"
        # if append add append objects before exporting
        if($Append){
            if(-not (Test-Path $path)){
                Write-Verbose "File '$path' not found. Will continue with export, but will not append."
            } else {
                # import existing from JSON, but overwrite any matching Notes with the new value
                $(Get-Content $Path -Raw | ConvertFrom-Json) | Select-Object Note, Snippet, Details, Alias, Tags | 
                    Where-Object{ $ExportObjects.Alias -notcontains $_.Alias } | ForEach-Object{ 
                        $ExportObjects.Add([PSNoteExport]::New( $_ )) 
                }
            }
            
        }

        $ExportObjects | ConvertTo-Json | Out-File $Path -Encoding UTF8NoBOM
    }
}