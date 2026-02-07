Function Export-PSNote {
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

        Exportall notes to a JSON file.

    .EXAMPLE
        Get-PSNote -tag 'AD' | Export-PSNote -Path C:\Export\SharedADNotes.json

        Exports all notes with the tag 'AD' to the file SharedADNotes.json
    
    
    
    .LINK
        https://github.com/mdowst/PSNotes
    #>
    [cmdletbinding(DefaultParameterSetName = "Note")]
    param(    
        [parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "Note")]
        [PSNote[]]$NoteObject,
        [parameter(Mandatory = $true, ParameterSetName = "Catalog")]
        [string]$Catalog,
        [parameter(Mandatory = $true)]
        [string]$Path,
        [parameter(Mandatory = $false)]
        [switch]$Force
    )
    begin {
        Test-PSNotesInitalize
        #[System.Collections.Generic.List[NoteCatalog]] $ExportObjects = @()
        Write-Debug "$($noteObject | Format-Table | Out-String)"
        # If Catalog is specified, add all objects from that catalog, otherwise only add those passed
        if ($PSCmdlet.ParameterSetName -eq 'Catalog') {
            $ExportObjects = [NoteCatalog]::new($Catalog)
        }
        else {
            $ExportObjects = [NoteCatalog]::new($false)
            $ExportObjects.Catalog = 'Export'
            #$noteObject | ForEach-Object { $ExportObjects.Notes.Add( $_ ) }
        }
    }
    process {
        # If Catalog is specified, add all objects from that catalog, otherwise only add those passed
        $noteObject | ForEach-Object { $ExportObjects.Notes.Add( $_ ) }
    }
    end {
        Write-Debug "$($ExportObjects | Format-Table | Out-String)"

        if ((Test-Path $Path) -and -not $Force) {
            Write-Error "File already exists at '$Path'. Use -Force to overwrite."
        }
        else {
            $ExportObjects | Select-Object -Property * -ExcludeProperty Path | ConvertTo-Json -Depth 5 | Out-File $Path -Encoding UTF8NoBOM
        }        
    }
}