enum PSNoteKind {
    Snippet
    Script
}
# Create the PSNote class
class PSNote {
    [string]$Note
    [string]$Snippet
    [string]$Details
    [string]$Alias
    [string[]]$Tags
    [string]$Catalog
    [bool]$Run = $false
    [PSNoteKind]$Kind = [PSNoteKind]::Snippet

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

        if ([string]::IsNullOrEmpty($Alias)) { $this.Alias = $Note }

        $this.Kind = [PSNoteKind]::Snippet
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

        if ([string]::IsNullOrEmpty($Alias)) { $this.Alias = $Note }

        $this.Kind = [PSNoteKind]::Snippet
    }

    PSNote(
        [string]$Note,
        [PSNoteKind]$Kind,
        [string]$Snippet,
        [string]$Details,
        [string]$Alias,
        [string[]]$Tags,
        [string]$Catalog,
        [bool]$Run
    ) {
        $this.Note = $Note
        $this.Kind = $Kind
        $this.Snippet = $Snippet
        $this.Details = $Details
        $this.Alias = $Alias
        $this.Tags = $Tags
        $this.Catalog = $Catalog
        $this.Run = $Run

        if ([string]::IsNullOrEmpty($Alias)) { $this.Alias = $Note }
    }

    PSNote([object]$object) {
        $this.Note = $this.GetObjectProperty($object, 'Note')
        $this.Details = $this.GetObjectProperty($object, 'Details')
        $this.Alias = $this.GetObjectProperty($object, 'Alias')
        $this.Tags = $this.GetObjectProperty($object, 'Tags')
        $this.Catalog = $this.GetObjectProperty($object, 'Catalog')
        $this.Snippet = $this.GetObjectProperty($object, 'Snippet')

        # Run (existing behavior)
        $objRun = $this.GetObjectProperty($object, 'Run')
        $tryRun = $false
        if ([bool]::TryParse($objRun, [ref]$tryRun)) { $this.Run = $tryRun } else { $this.Run = $false }

        if ([string]::IsNullOrEmpty($this.Alias)) { $this.Alias = $this.GetObjectProperty($object, 'Note') }

        # --- Kind (new, but tolerate missing/invalid) ---
        $kindText = $null
        if ($null -ne $object.PSObject.Properties['Kind']) {
            $kindText = [string]$object.Kind
        }

        if ([string]::IsNullOrWhiteSpace($kindText)) {
            $this.Kind = [PSNoteKind]::Snippet
        }
        else {
            try { $this.Kind = [PSNoteKind]::$kindText }
            catch { $this.Kind = [PSNoteKind]::Snippet }
        }
    }

    [object] GetObjectProperty([object]$object, [string]$propertyName) {
        if ($null -ne $object.PSObject.Properties[$propertyName]) {
            return $object.$propertyName
        }
        return $null
    }

    [string] GetKey() {
        return "$($this.Catalog)::$($this.Alias)"
    }

    # Optional helper: what do we show in menus?
    [string] GetDisplayText() {
        $out = switch ($this.Kind) {
            Script { "$($this.Alias) (Script)" }
            default { "$($this.Alias)" }
        }
        return $out
    }
}


class NoteCatalog {
    static [int] $CurrentStoreVersion = 1

    [string] $Path
    [string] $Catalog
    [int]    $StoreVersion
    [System.Collections.Generic.List[PSNote]] $Notes

    NoteCatalog() {
        [NoteStore]::InitializeEnvironment()
        $this.Path = [NoteCatalog]::ResolvePath('PSNotes', $env:PSNOTES_HOME)
        $this.Catalog = 'PSNotes'
        $this.StoreVersion = [NoteCatalog]::CurrentStoreVersion
        $this.Notes = [System.Collections.Generic.List[PSNote]]::new()
        $this.Open()
    }

    NoteCatalog([string] $Catalog) {
        [NoteStore]::InitializeEnvironment()
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
            $dataStoreVersion = $data.psobject.Properties | Where-Object { $_.Name -eq 'StoreVersion' } | Select-Object -ExpandProperty Value

            # Migration / backward-compat:
            # If older store was just an array of notes, wrap it.
            $jsonData = if ($dataStoreVersion -eq $this.StoreVersion) {
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

class NoteMetadataStore {
    static [int] $CurrentVersion = 1

    [string] $Path
    [int] $Version
    [System.Collections.Generic.HashSet[string]] $Favorites

    NoteMetadataStore() {
        $metaPath = Join-Path $env:PSNOTES_HOME 'config'
        if (-not (Test-Path $metaPath)) {
            $null = New-Item -Path $metaPath -ItemType Directory -Force
        }
        $this.Path = (Join-Path $metaPath 'psnotemetadatastore.json')
        $this.Version = [NoteMetadataStore]::CurrentVersion
        $this.Favorites = [System.Collections.Generic.HashSet[string]]::new()
        $this.Open()
    }

    NoteMetadataStore([string] $path) {
        $this.Path = $path
        $this.Version = [NoteMetadataStore]::CurrentVersion
        $this.Favorites = [System.Collections.Generic.HashSet[string]]::new()
        $this.Open()
    }

    [void] Open() {
        if (-not (Test-Path $this.Path)) { return }

        try {
            $json = [NoteCatalog]::ReadUtf8NoBom($this.Path)
            if ([string]::IsNullOrWhiteSpace($json)) { return }

            $data = $json | ConvertFrom-Json -ErrorAction Stop
            if ($data.Favorites) {
                foreach ($k in $data.Favorites) {
                    if (-not [string]::IsNullOrWhiteSpace([string]$k)) {
                        $null = $this.Favorites.Add([string]$k)
                    }
                }
            }
        }
        catch {
            # If metadata is corrupt, fail safe (don't crash UI). You can add logging later.
            return
        }
    }

    [string] ToJson() {
        return ($this | ConvertTo-Json -Depth 5)
    }

    [void] Save() {
        $lockStream = [NoteCatalog]::AcquireLock($this.Path, 5000, 50)
        try {
            [NoteCatalog]::WriteUtf8NoBomToLockedStream($lockStream, $this.ToJson())
        }
        finally {
            $lockStream.Dispose()
        }
    }
}

class NoteConfigStore {
    static [int] $CurrentVersion = 1

    [string] $Path
    [int] $Version
    [string] $Main
    [bool] $ExitOnCopy
    [ConsoleColor] $ForegroundColor
    [ConsoleColor] $BackgroundColor

    NoteConfigStore() {
        $metaPath = Join-Path $env:PSNOTES_HOME 'config'
        if (-not (Test-Path $metaPath)) {
            $null = New-Item -Path $metaPath -ItemType Directory -Force
        }
        $this.Path = (Join-Path $metaPath 'psnoteconfig.json')
        $this.SetDefaults()
        $this.Open()
    }

    NoteConfigStore([string] $path) {
        $this.Path = $path
        $this.SetDefaults()
        $this.Open()
    }

    [void] SetDefaults() {
        $this.Version = [NoteConfigStore]::CurrentVersion
        $this.Main = 'Favorites'
        $this.ExitOnCopy = $true
        $this.ForegroundColor = [ConsoleColor]::Black
        $this.BackgroundColor = [ConsoleColor]::Gray
    }

    [void] Open() {
        if (-not (Test-Path $this.Path)) { return }

        try {
            $json = [NoteCatalog]::ReadUtf8NoBom($this.Path)
            if ([string]::IsNullOrWhiteSpace($json)) { return }

            $data = $json | ConvertFrom-Json -ErrorAction Stop
            if (-not [string]::IsNullOrWhiteSpace([string]$data.Main)) {
                $this.Main = [string]$data.Main
            }
            if ($null -ne $data.ExitOnCopy) {
                $tryExitOnCopy = $false
                if ([bool]::TryParse($data.ExitOnCopy, [ref]$tryExitOnCopy)) {
                    $this.ExitOnCopy = $tryExitOnCopy
                }
            }
            if ($null -ne $data.ForegroundColor) {
                $tryFg = [ConsoleColor]::Black
                if ([Enum]::TryParse([string]$data.ForegroundColor, [ref]$tryFg)) {
                    $this.ForegroundColor = $tryFg
                }
            }
            if ($null -ne $data.BackgroundColor) {
                $tryBg = [ConsoleColor]::Gray
                if ([Enum]::TryParse([string]$data.BackgroundColor, [ref]$tryBg)) {
                    $this.BackgroundColor = $tryBg
                }
            }
        }
        catch {
            # If metadata is corrupt, fail safe (don't crash UI). You can add logging later.
            return
        }
    }

    [string] ToJson() {
        return ($this | ConvertTo-Json -Depth 5)
    }

    [void] Save() {
        $lockStream = [NoteCatalog]::AcquireLock($this.Path, 5000, 50)
        try {
            [NoteCatalog]::WriteUtf8NoBomToLockedStream($lockStream, $this.ToJson())
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
    [NoteMetadataStore] $Metadata
    [NoteConfigStore] $Config

    NoteStore() {
        [NoteStore]::InitializeEnvironment()
        $this.Notes = [System.Collections.Generic.List[PSNote]]::new()
        $this.Catalogs = [System.Collections.Generic.List[NoteCatalog]]::new()

        $defaultStore = [NoteCatalog]::new()
        $this.LoadCatalog($defaultStore)

        $this.Metadata = [NoteMetadataStore]::new()
        $this.Config = [NoteConfigStore]::new()

        $this.InitializeAliases()
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
        if (-not ($this.Catalogs | Where-Object { $_.Catalog -eq $catalog.Catalog })) {
            $this.Catalogs.Add($catalog)
        }
    }

    [void] InitializeAliases() {
        $this.Notes | ForEach-Object {
            Write-Debug "Alias : $($_.Alias)"
            if([string]::IsNullOrWhiteSpace($_.Alias)) { 
                Write-Warning "Note '$( $_.Note )' has an empty Alias. Skipping alias creation."
                return 
            }
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
        $noteNote = if ($null -ne $note.PSObject.Properties['Note']) {
            [string]$note.Note
        }
        $noteCatalog = if ($null -ne $note.PSObject.Properties['Kind']) {
            [string]$note.Catalog
        }
        $update = $this.Notes | Where-Object { $_.Note -eq $noteNote }
        
        if(-not $update) {
            Write-Warning "Note '$($noteNote)' not found in catalog '$($noteCatalog)'. No action taken."
            return
        }
        elseif ($update.Catalog -eq $noteCatalog) {
            $this.RemoveNote($noteNote, $noteCatalog)
            $this.AddNote($note)
        }
        else {
            Write-Warning "Note '$($noteNote)' exists in catalog '$($update.Catalog)'. Cannot update note in different catalog at this time '$($noteCatalog)'. No action taken."
        }
    }

    [string] GetNoteKey([PSNote] $note) {
        return "$($note.Catalog)::$($note.Alias)"
    }

    [bool] IsFavorite([PSNote] $note) {
        if (-not $this.Metadata) { return $false }
        return $this.Metadata.Favorites.Contains($this.GetNoteKey($note))
    }

    [void] AddFavorite([PSNote] $note) {
        if (-not $this.Metadata) { return }
        $key = $this.GetNoteKey($note)
        if ($this.Metadata.Favorites.Add($key)) { $this.Metadata.Save() }
    }

    [void] RemoveFavorite([PSNote] $note) {
        if (-not $this.Metadata) { return }
        $key = $this.GetNoteKey($note)
        if ($this.Metadata.Favorites.Remove($key)) { $this.Metadata.Save() }
    }

    [bool] ToggleFavorite([PSNote] $note) {
        if (-not $this.Metadata) { return $false }

        $key = $this.GetNoteKey($note)
        if ($this.Metadata.Favorites.Contains($key)) {
            $null = $this.Metadata.Favorites.Remove($key)
            $this.Metadata.Save()
            return $false
        }
        else {
            $null = $this.Metadata.Favorites.Add($key)
            $this.Metadata.Save()
            return $true
        }
    }

    [System.Collections.Generic.List[PSNote]] GetFavorites() {
        $list = [System.Collections.Generic.List[PSNote]]::new()
        if (-not $this.Metadata) { return $list }

        foreach ($n in $this.Notes) {
            if ($this.Metadata.Favorites.Contains($this.GetNoteKey($n))) {
                $list.Add($n) | Out-Null
            }
        }
        return $list
    }
}


