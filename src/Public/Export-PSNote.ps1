Function Export-PSNote {
    <#
    .SYNOPSIS
        Export PSNotes to a JSON file

    .DESCRIPTION
        Exports PSNotes to a JSON file for sharing or importing on another machine.
        You can export notes by catalog or by piping PSNote objects into this command.

    .PARAMETER NoteObject
        The PSNote objects you want to export. Use Get-PSNote to build the object and pass it to the parameter
        or use the pipeline to pass them in.

    .PARAMETER Catalog
        The catalog name to export. When specified, all notes from that catalog are exported.

    .PARAMETER Path
        The path to the PSNotes JSON file to export to.

    .PARAMETER Force
        Overwrite the output file if it already exists.

    .EXAMPLE
        Export-PSNote -Catalog 'Default' -Path C:\Export\MyPSNotes.json

        Exports all notes from the 'Default' catalog to a JSON file.

    .EXAMPLE
        Get-PSNote -Tag 'AD' | Export-PSNote -Path C:\Export\SharedADNotes.json

        Exports all notes with the tag 'AD' to the file SharedADNotes.json.

    .EXAMPLE
        Get-PSNote -Note 'Cred*' -Catalog 'Work' | Export-PSNote -Path C:\Export\WorkCreds.json

        Exports notes that match the name pattern from the 'Work' catalog.

    .EXAMPLE
        Get-PSNote -SearchString 'token' | Export-PSNote -Path C:\Export\TokenNotes.json

        Exports notes that match a search string.

    .EXAMPLE
        Export-PSNote -Catalog 'Personal' -Path C:\Export\PersonalNotes.json -Force

        Exports the 'Personal' catalog and overwrites the file if it exists.
    
    
    
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

        Write-Debug "$($noteObject | Format-Table | Out-String)"
        # If Catalog is specified, add all objects from that catalog, otherwise only add those passed
        if ($PSCmdlet.ParameterSetName -eq 'Catalog') {
            $ExportObjects = [NoteCatalog]::new($Catalog)
        }
        else {
            $ExportObjects = [NoteCatalog]::new($false)
            $ExportObjects.Catalog = 'Export'
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