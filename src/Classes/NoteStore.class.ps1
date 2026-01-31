# Create the PSNote class
class PSNote {
    [string]$Note
    [string]$Snippet
    [string]$Details
    [string]$Alias
    [string[]]$Tags
    [string]$Catalog
    [bool]$Run = $false

    PSNote(
        [string]$Note,
        [string]$Snippet,
        [string]$Details,
        [string]$Alias,
        [string[]]$Tags
    ) {
        $this.Note = $Note
        $this.Snippet = $Snippet
        $this.Details = $Details
        $this.Alias = $Alias
        $this.Tags = $Tags
        $this.Catalog = 'PSNotes'
        
        if ([string]::IsNullOrEmpty($Alias)) {
            $this.Alias = $Note
        }
    }

    PSNote(
        [string]$Note,
        [string]$Snippet,
        [string]$Details,
        [string]$Alias,
        [string[]]$Tags,
        [string]$Catalog,
        [bool]$Run
    ) {
        $this.Note = $Note
        $this.Snippet = $Snippet
        $this.Details = $Details
        $this.Alias = $Alias
        $this.Tags = $Tags
        $this.Catalog = $Catalog
        $this.Run = $Run
        if ([string]::IsNullOrEmpty($Alias)) {
            $this.Alias = $Note
        }
    }

    PSNote(
        [object]$object
    ) {
        $this.Note = $object.Note
        $this.Snippet = $object.Snippet
        $this.Details = $object.Details
        $this.Alias = $object.Alias
        $this.Tags = $object.Tags
        $this.Catalog = $object.Catalog
        
        $tryRun = $false
        if([bool]::TryParse($object.Run, [ref]$tryRun)) {
            $this.Run = $tryRun
        }
        else {
            $this.Run = $false
        }

        if ([string]::IsNullOrEmpty($this.Alias)) {
            $this.Alias = $object.Note
        }

    }
}

class NoteCatalog {
    static [int] $CurrentStoreVersion = 1

    [string] $Path
    [string] $Catalog
    [int]    $StoreVersion
    [System.Collections.Generic.List[PSNote]] $Notes

    NoteCatalog() {
        [NoteCatalog]::InitializeEnvironment()
        $this.Path = [NoteCatalog]::ResolvePath('PSNotes', $env:PSNOTES_HOME)
        $this.Catalog = 'PSNotes'
        $this.StoreVersion = [NoteCatalog]::CurrentStoreVersion
        $this.Notes = [System.Collections.Generic.List[PSNote]]::new()
        $this.Open()
    }

    NoteCatalog([string] $Catalog) {
        [NoteCatalog]::InitializeEnvironment()
        $this.Path = [NoteCatalog]::ResolvePath($Catalog, $env:PSNOTES_HOME)
        $this.Catalog = $Catalog
        $this.StoreVersion = [NoteCatalog]::CurrentStoreVersion
        $this.Notes = [System.Collections.Generic.List[PSNote]]::new()
        $this.Open()
    }

    NoteCatalog([bool] $blank) {
        $this.Path = [NoteCatalog]::ResolvePath('PSNotes', $env:PSNOTES_HOME)
        $this.StoreVersion = [NoteCatalog]::CurrentStoreVersion
        $this.Notes = [System.Collections.Generic.List[PSNote]]::new()
    }

    static [void] InitializeEnvironment() {
        if ([string]::IsNullOrEmpty($env:PSNOTES_HOME)) {
            if (Get-Variable -Name IsLinux -Scope Global -ValueOnly -ErrorAction SilentlyContinue) {
                $env:PSNOTES_HOME = '/home/'
            } 
            else {
                $env:PSNOTES_HOME = Join-Path $env:APPDATA 'PSNotes'
            } 
        }
    }

    static [string] ResolvePath() {
        return [NoteCatalog]::ResolvePath('PSNotes', $env:PSNOTES_HOME)
    }

    static [string] ResolvePath([string] $catalog) {
        return [NoteCatalog]::ResolvePath($catalog, $env:PSNOTES_HOME)
    }

    static [string] ResolvePath([string] $catalog = 'PSNotes', [string] $rootPath = $env:PSNOTES_HOME) {
        if ([string]::IsNullOrWhiteSpace($rootPath)) {
            $rootPath = Join-Path $env:APPDATA 'PSNotes'
        }
        if (-not (Test-Path $rootPath)) {
            $null = New-Item -Path $rootPath -ItemType Directory -Force
        }

        $fileName = if ($catalog -match '\.json$') { $catalog } else { "$catalog.json" }
        return (Join-Path $rootPath $fileName)
    }

    static [System.IO.FileStream] AcquireLock([string] $path, [int] $timeoutMs = 5000, [int] $retryDelayMs = 50) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $last = $null

        while ($sw.ElapsedMilliseconds -lt $timeoutMs) {
            try {
                # Lock the store file itself; write-through this stream in Save()
                return [System.IO.File]::Open(
                    $path,
                    [System.IO.FileMode]::OpenOrCreate,
                    [System.IO.FileAccess]::ReadWrite,
                    [System.IO.FileShare]::None
                )
            }
            catch {
                $last = $_
                Start-Sleep -Milliseconds $retryDelayMs
            }
        }

        throw "Timed out acquiring lock for note store file: $path. Last error: $($last.Exception.Message)"
    }

    static [string] ReadUtf8NoBom([string] $path) {
        if (-not (Test-Path $path)) { return $null }

        $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
        $fs = [System.IO.File]::Open($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        try {
            $sr = [System.IO.StreamReader]::new($fs, $utf8NoBom, $true)
            try { return $sr.ReadToEnd() } finally { $sr.Dispose() }
        }
        finally { $fs.Dispose() }
    }

    static [void] WriteUtf8NoBomToLockedStream([System.IO.FileStream] $stream, [string] $content) {
        $utf8NoBom = [System.Text.UTF8Encoding]::new($false)

        $stream.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null
        $stream.SetLength(0)

        $sw = [System.IO.StreamWriter]::new($stream, $utf8NoBom, 4096, $true) # leaveOpen
        try {
            $sw.Write($content)
            $sw.Flush()
            $stream.Flush($true)
        }
        finally { $sw.Dispose() }
    }

    [void] Open() {
        $json = [NoteCatalog]::ReadUtf8NoBom($this.Path)

        if (-not [string]::IsNullOrWhiteSpace($Json)) {
            $data = $Json | ConvertFrom-Json -ErrorAction Stop

            # Migration / backward-compat:
            # If older store was just an array of notes, wrap it.
            $jsonData = if ($data.StoreVersion -eq $this.StoreVersion) {
                $data.Notes
            }
            else {
                $data
            }
            $jsonData | ForEach-Object {
                $note = [PSNote]::New($_)
                if ([string]::IsNullOrWhiteSpace($note.Catalog)) {
                    $note.Catalog = $this.Catalog
                }
                $this.Notes.Add($note)
            }
        }

        if ($null -eq $this.Catalog) {
            $this.Catalog = [System.IO.Path]::GetFileNameWithoutExtension($this.Path)
        }
        # Future: if ($store.StoreVersion -lt CurrentStoreVersion) { $store.Migrate() }
    }

    static [NoteCatalog] Open([string] $catalogPath) {
        $store = [NoteCatalog]::new($true)
        $store.Path = $catalogPath
        $store.Open()
        
        return $store
    }

    [string] ToJson() {
        $obj = [pscustomobject]@{
            StoreVersion = $this.StoreVersion
            Notes        = @($this.Notes)
        }
        return ($obj | ConvertTo-Json -Depth 10)
    }

    [void] Save() {
        $this.Save(5000)
    }

    [void] Save([int] $timeoutMs) {
        # Always write current version
        $this.StoreVersion = [NoteCatalog]::CurrentStoreVersion

        $lockStream = [NoteCatalog]::AcquireLock($this.Path, $timeoutMs, 50)
        try {
            $json = $this.ToJson()
            [NoteCatalog]::WriteUtf8NoBomToLockedStream($lockStream, $json)
        }
        finally {
            $lockStream.Dispose()
        }
    }
}

class NoteStore {
    static [int] $CurrentStoreVersion = 1

    [System.Collections.Generic.List[NoteCatalog]] $Catalogs
    [System.Collections.Generic.List[PSNote]] $Notes

    NoteStore() {
        $this.Notes = [System.Collections.Generic.List[PSNote]]::new()
        $this.Catalogs = [System.Collections.Generic.List[NoteCatalog]]::new()
        $defaultStore = [NoteCatalog]::new()
        $this.LoadCatalog($defaultStore)
        $this.InitializeAliases()
    }

    [void] LoadCatalog([string] $catalogName) {
        $catalog = [NoteCatalog]::new($catalogName)
        $this.LoadCatalog($catalog)
    }

    [void] LoadCatalog([NoteCatalog] $catalog) {
        $catalog.Notes | ForEach-Object { 
            $newNote = $_
            $dup = $this.Notes | Where-Object { $_.Alias -eq $newNote.Alias }
            if ($dup -and $dup.Catalog -ne $newNote.Catalog) {
                Write-Warning "Duplicate Alias found: $($newNote.Alias). Skipping note: $($newNote.Note)"
            }
            elseif (-not $dup) {
                $this.Notes.Add($newNote) 
            }
        }
        if(-not ($this.Catalogs | Where-Object { $_.Catalog -eq $catalog.Catalog })) {
            $this.Catalogs.Add($catalog)
        }
    }

    [void] InitializeAliases() {
        $this.Notes | ForEach-Object {
            Write-Debug "Alias : $($_.Alias)"
            Set-Alias -Name $_.Alias -Value Get-PSNoteAlias -Scope Global -Force
        }
    }

    [void] Save() {
        $this.Catalogs | ForEach-Object {
            $_.Save()
        }
    }

    [void] AddNote([PSNote] $note) {
        $this.Notes.Add($note) | Out-Null
        $catalogUpdates = $this.Catalogs | Where-Object { $_.Catalog -eq $note.Catalog } | ForEach-Object {
            $_.Notes.Add($note) | Out-Null
            $_
        }
        $catalogUpdates | ForEach-Object {
            $_.Save()
            $this.LoadCatalog($_)
        }
    }

    [void] RemoveNote([string] $note, [string] $catalog) {
        $remove = $this.Notes | Where-Object { $_.Note -eq $note -and $_.Catalog -eq $catalog }
        if ($remove) {
            $this.Notes.Remove($remove) | Out-Null
            $catalogUpdates = $this.Catalogs | Where-Object { $_.Catalog -eq $remove.Catalog } | ForEach-Object {
                $_.Notes.Remove($remove) | Out-Null
                $_
            }
            $catalogUpdates | ForEach-Object {
                $_.Save()
                $this.LoadCatalog($_)
            }
        }
        else {
            Write-Warning "Note '$note' not found in catalog '$catalog'. No action taken."
        }
    }

    [void] UpdateNote([PSNote] $note) {
        $update = $this.Notes | Where-Object { $_.Note -eq $note.Note }
        if ($update.Catalog -eq $note.Catalog) {
            $this.RemoveNote($note.Note, $note.Catalog)
            $this.AddNote($note)
        }
        elseif ($update){
            Write-Warning "Note '$($note.Note)' exists in catalog '$($update.Catalog)'. Cannot update note in different catalog at this time '$($note.Catalog)'. No action taken."
        }
        else {
            Write-Warning "Note '$($note.Note)' not found in catalog '$($note.Catalog)'. No action taken."
        }
    }
}