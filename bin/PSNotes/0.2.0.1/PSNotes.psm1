#Region '.\Classes\NoteStore.class.ps1' -1

# Create the PSNote class
class PSNote {
    [string]$Note
    [string]$Snippet
    [string]$Details
    [string]$Alias
    [string[]]$Tags
    [string]$Catalog

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
        [string]$Catalog
    ) {
        $this.Note = $Note
        $this.Snippet = $Snippet
        $this.Details = $Details
        $this.Alias = $Alias
        $this.Tags = $Tags
        $this.Catalog = $Catalog
        
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
            elseif(-not $dup) {
                $this.Notes.Add($newNote) 
            }
        }
        $this.Catalogs.Add($catalog)
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
        $this.Notes.Add($note)
        $catalogUpdates = $this.Catalogs | Where-Object { $_.Catalog -eq $note.Catalog } | ForEach-Object {
            $_.Notes.Add($note)
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
            $this.Notes.Remove($remove)
            $this.Catalogs | Where-Object { $_.Catalog -eq $remove.Catalog } | ForEach-Object {
                $_.Notes.Remove($remove)
                $_.Save()
                $this.LoadCatalog($_)
            }
        }
    }

    [void] UpdateNote([PSNote] $note) {
        $index = $this.Notes.FindIndex({ param($n) $n.Note -eq $note.Note })
        if ($index -ge 0) {
            $this.Notes[$index] = $note
            $catalogIndex = $this.Catalogs | Where-Object { $_.Catalog -eq $note.Catalog } | ForEach-Object {
                $Index = $_.Notes.FindIndex({ param($n) $n.Note -eq $note.Note })
                if ($Index -ge 0) {
                    [pscustomobject]@{
                        Catalog = $_.Catalog
                        Index   = $_.Notes.FindIndex({ param($n) $n.Note -eq $note.Note })
                    }
                }
            }
            foreach ($ci in $catalogIndex) {
                $catUpdate = $this.Catalogs | Where-Object { $_.Catalog -eq $ci.Catalog }
                $catUpdate.Notes[$ci.Index] = $note
                $catUpdate.Save()
                $this.LoadCatalog($catUpdate)
            }
        }
    }
}
#EndRegion '.\Classes\NoteStore.class.ps1' 335
#Region '.\Classes\PSNoteExport.class.ps1' -1

class PSNoteExport {
    [string]$Note
	[string]$Snippet
	[string]$Details
    [string]$Alias
    [string[]]$Tags

    PSNoteExport(
        [object]$object
    ){
        $this.Note = $object.Note
		$this.Snippet = $object.Snippet
		$this.Details = $object.Details
        $this.Alias = $object.Alias
        $this.Tags = $object.Tags

        if([string]::IsNullOrEmpty($this.Alias)){
            $this.Alias = $object.Note
        }

    }
}
#EndRegion '.\Classes\PSNoteExport.class.ps1' 23
#Region '.\Classes\PSNoteSearch.class.ps1' -1

class PSNoteSearch {
    [string]$Note
	[string]$Snippet
	[string]$Details
    [string]$Alias
    [string[]]$Tags
    [string]$file

    PSNoteSearch(
        [object]$object
    ){
        $this.Note = $object.Note
		$this.Snippet = $object.Snippet
		$this.Details = $object.Details
        $this.Alias = $object.Alias
        $this.Tags = $object.Tags
        $this.File = $object.File

        if([string]::IsNullOrEmpty($this.Alias)){
            $this.Alias = $object.Note
        }

    }
}
#EndRegion '.\Classes\PSNoteSearch.class.ps1' 25
#Region '.\Classes\SplatBlock.class.ps1' -1

class SplatBlock {
    [string]$Command
    [string]$ParameterSet
	[Boolean]$IsDefault
	[string]$HashBlock
    [string]$SetBlock

    PSNoteExport(
        [object]$object
    ){
        $this.Command = $object.Command
		$this.IsDefault = $object.IsDefault
		$this.HashBlock = $object.HashBlock
        $this.SetBlock = $object.SetBlock
    }
}
#EndRegion '.\Classes\SplatBlock.class.ps1' 17
#Region '.\Private\Initialize-PSNotes.ps1' -1

Function Initialize-PSNotes {
    [CmdletBinding()]
    param()
    # Global Variables

    if ([string]::IsNullOrEmpty($env:PSNOTES_HOME)) {
        if ($IsLinux) {
            $env:PSNOTES_HOME = '/home/'
        } 
        else {
            $env:PSNOTES_HOME = Join-Path $env:APPDATA 'PSNotes'
        } 
    }
    Write-Verbose "User PSNotes Path: $env:PSNOTES_HOME"

    if ($global:IsPesterTest) {
        $env:PSNOTES_HOME = Join-Path $env:PSNOTES_HOME 'Pester'
        Get-ChildItem -Path $env:PSNOTES_HOME -Filter '*.json' | Remove-Item -Force
    }

    #$env:PSNotesUserJsonFile = Join-Path $env:PSNOTES_HOME 'PSNotes.json'
    $env:PSNotesRemoteJsonFile = Join-Path $env:PSNOTES_HOME 'RemotePSNotesConnections.json'

    # Load all commands to noteObjects
    #Initialize-PSNotesRemoteJsonFile
    $script:_noteStore = [NoteStore]::new()

    # Check id Set-Clipboard cmdlet is found. If not
    if (-not (Get-Command -Name 'Set-Clipboard' -ErrorAction SilentlyContinue)) {
        # ClipboardText module is found then set an alias for the Set-Clipboard command
        if (Get-Module ClipboardText -ListAvailable) {
            if (-not (Get-Alias -Name 'Set-Clipboard' -ErrorAction SilentlyContinue)) {
                Set-Alias -Name 'Set-Clipboard' -Value 'Set-ClipboardText'
            }
        }
        else {
            $warning = "Cmdlet 'Set-Clipboard' not found. Copy functionality will not work until this is resovled. " +
            "`n`t You can install the ClipboardText module from PowerShell Gallery, to add this functionality. " + 
            "`n`n`t`t Install-Module -Name ClipboardText`n" +
            "`n`t More Details: https://www.powershellgallery.com/packages/ClipboardText"
            Write-Warning $warning
        }
    }
}
#EndRegion '.\Private\Initialize-PSNotes.ps1' 45
#Region '.\Private\Initialize-PSNotesRemoteJsonFile.ps1' -1

Function Initialize-PSNotesRemoteJsonFile{

    # Create PSNote.json in %APPDATA%\PSNotes to save users local settings
    if(-not (Test-Path $env:PSNotesRemoteJsonFile)){
        Out-File $env:PSNotesRemoteJsonFile -Encoding UTF8
    }

    # Sync the remote JSON files
    $uri = 'https://gist.githubusercontent.com/mdowst/7198756f760ad0de0f635aaef5c4d338/raw/aa078383267e1d1613169e1a42f5c35ab70ffa7d/RemotePSNote.json'

    $outFile = Join-Path $env:PSNOTES_HOME (Split-Path $uri -Leaf)
    if([System.IO.Path]::GetExtension($outFile) -ne '.json'){
        $outFile += '.json'
    }

    try{
        Invoke-WebRequest -Uri $uri -OutFile $outFile -ErrorAction Stop
    }
    catch{
        # TODO: Write custom error message
    } 
    $download
}
#EndRegion '.\Private\Initialize-PSNotesRemoteJsonFile.ps1' 24
#Region '.\Private\Test-PSNotesInitalize.ps1' -1

Function Test-PSNotesInitalize{
    [CmdletBinding()]
    param()

    if([string]::IsNullOrEmpty($env:PSNOTES_HOME)){
        Write-Verbose '$env:PSNOTES_HOME is not set.'
        Initialize-PSNotes
    }
}
#EndRegion '.\Private\Test-PSNotesInitalize.ps1' 10
#Region '.\Private\Write-NoteSnippet.ps1' -1

Function Write-NoteSnippet {
    <#
    .SYNOPSIS
    Used by the Copy-PSNote and Invoke-PSNote to display a menu and prompt for selection of a note
    
    .PARAMETER NoteSelection
    An array of PSNote objects to create a menu with
    
    #>
    [cmdletbinding()]
    param(
        [PSNote[]]$NoteSelection
    )
    $i = 0
    $noteMenu = $NoteSelection | ForEach-Object {
        $i++
        $_ | Select-Object @{l = 'Nbr'; e = { $i } }, *
    } 
    $promptMenu = $noteMenu | Format-Table Nbr, Note, Alias, Details, Tags -AutoSize | Out-String

    $Prompt = "$($promptMenu)Enter the number to run (or leave blank to cancel) and hit [Enter]"
    $Selection = Read-Host -Prompt $Prompt
    if ([string]::IsNullOrEmpty($Selection)) {
        $null
    }
    elseif (-not [int]::TryParse($Selection, [ref]$null)) {
        Write-Error "The select must a number between 1 and $($NoteSelection.Count)"
    }
    elseif ([int]$Selection -gt $NoteSelection.Count -or [int]$Selection -lt 1) {
        Write-Error "The select must be between 1 and $($NoteSelection.Count)"
    }
    else {
        $NoteSelection[$Selection - 1].Snippet
    }
}
#EndRegion '.\Private\Write-NoteSnippet.ps1' 36
#Region '.\Public\ConvertTo-Splatting.ps1' -1

Function ConvertTo-Splatting {
    <#
    .SYNOPSIS
    Use to convert an existing PowerShell command to splatting

    .DESCRIPTION
    Splatting is a much cleaner and safer way to shorten command lines without needing to use backtick.
    This function excepts any command as a string or a scriptblock and will convert the existing parameters
    to a hashtable and output the fully splatted command for you.

    .PARAMETER Command
    The command string you want to convert to using splatting

    .PARAMETER ScriptBlock
    The command scriptblock you want to convert to using splatting

    .EXAMPLE     
    $splatme = @'
    Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" -ResourceGroupName "rg-xxxx" -VMName "vm-xxxx" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -ExtensionType "MicrosoftMonitoringAgent" -TypeHandlerVersion "1.0" -Settings @{"workspaceId" = "xxxx" } -ProtectedSettings @{"workspaceKey" = "xxxx"} -Location "uksouth"
    '@
    ConvertTo-Splatting $splatme

    Converts the string splatme to splatting

    --- Output ----
    $SetAzVMExtensionParam = @{
            ExtensionName      = "MicrosoftMonitoringAgent"
            ResourceGroupName  = "rg-xxxx"
            VMName             = "vm-xxxx"
            Publisher          = "Microsoft.EnterpriseCloud.Monitoring"
            ExtensionType      = "MicrosoftMonitoringAgent"
            TypeHandlerVersion = "1.0"
            Settings           = @{ "workspaceId" = "xxxx" }
            ProtectedSettings  = @{ "workspaceKey" = "xxxx" }
            Location           = "uksouth"
    }
    Set-AzVMExtension @SetAzVMExtensionParam

    .EXAMPLE
    $splatme = {
        Copy-Item -Path "test.txt" -Destination "test2.txt" -WhatIf
    }
    ConvertTo-Splatting $splatme

    Converts the scriptblock splatme to splatting

    --- Output ----
    $CopyItemParam = @{
            Path        = "test.txt"
            Destination = "test2.txt"
            WhatIf      = $true
    }
    Copy-Item @CopyItemParam

    .EXAMPLE
    $splatme = {
        Get-AzVM `
            -ResourceGroupName "ResourceGroup11" `
            -Name "VirtualMachine07" `
            -Status
    }
    ConvertTo-Splatting $splatme

    Removed backticks and converts the scriptblock splatme to splatting

    --- Output ----
    $GetAzVMParam = @{
        ResourceGroupName = "ResourceGroup11"
        Name              = "VirtualMachine07"
        Status            = $true
    }
    Get-AzVM @GetAzVMParam

    .NOTES
    about_Splatting - https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting
    #>
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = 'string', Position = 0)]
        [string] $Command,
        [Parameter(ParameterSetName = 'scriptblock', Position = 0)]
        [ScriptBlock] $ScriptBlock
    )

    # Convert scriptblock to string for parsing
    if ($PSCmdlet.ParameterSetName -eq 'scriptblock') {
        $Command = $ScriptBlock.ToString().Trim()
    }
    # remove backticks 
    $ScriptBlockAst = [regex]::Replace($Command, '(`\r\n|`\r|`\n)', ' ')

    # Parse the script block input
    $Errors = @()
    $ref = @()
    [void][System.Management.Automation.Language.Parser]::ParseInput($ScriptBlockAst, [ref]$ref, [ref]$Errors)

    # Get the command and any variables it is being set to
    [System.Collections.Generic.List[string]]$ParsedCommand = @()
    $index = $ref | Where-Object { $_.TokenFlags -eq 'CommandName' } | Select-Object -First 1
    for ($i = 0; $i -le $ref.IndexOf($index); $i++) {
        if ($ref[$i].TokenFlags -notin 'None', 'AssignmentOperator', 'CommandName') {
            throw "Command should only start with a cmdlet or variable declaration '$($ref[$i].TokenFlags)'"
        }
        $ParsedCommand.Add($ref[$i].Text)
    }

    # set a name to make the hashtable variable
    $hash = $index.Value.Replace('-', '') + 'Param'
    $constants = (Get-Variable | Where-Object { $_.Options -match 'Constant' }).Name
    if ($ref[0].Name -eq $hash -or $hash -in $constants) {
        $hash = 'parameterSplat'
    }

    # Get all the parameters and their values
    [System.Collections.Generic.List[PSObject]]$parameters = @()
    $parametersExpected = $true
    $LParen = 0
    for ($i = $ParsedCommand.Count; $i -lt $ref.Count; $i++) {
        if ($ref[$i].Kind -eq 'EndOfInput') {
            $parameters[-1].End = $i
        }
        elseif ($LParen -eq 0 -and $ref[$i].Kind -eq 'Parameter') {
            # default value to $true to account for switches
            if ($parameters.Count -gt 0) {
                $parameters[-1].End = $i
            }
            [System.Collections.Generic.List[PSObject]] $Value = @()
            $parameters.Add([pscustomobject]@{Name = $ref[$i].ParameterName; Value = $Value; Start = $i + 1; End = 0 })
            $parametersExpected = $false
        }
        elseif ($ref[$i].Kind -in 'RParen', 'RCurly') {
            $LParen--
        }
        elseif ($LParen -eq 0 -and $parametersExpected -eq $true) {
            # if parameter was expected but not passed get the parameter name based on the position
            try {
                $ParsedCommandData = Get-Command -Name $index.Value -ErrorAction Stop
            }
            catch {
                if ($_.FullyQualifiedErrorId -eq 'CommandNotFoundException,Microsoft.PowerShell.Commands.GetCommandCommand') {
                    throw "Unable to find parameters for the command '$($index.Value)' ensure all modules and functions are loaded before retrying."
                }
                break
            }
            # using alias get the actual command resolves
            if ($ParsedCommandData.CommandType -eq 'Alias') {
                $ParsedCommandData = Get-Command -Name $ParsedCommandData.ResolvedCommand
            }
            # get the default Parameters
            if ($ParsedCommandData.ParameterSets.Count -gt 1) {
                $ParameterSet = foreach ($set in $ParsedCommandData.ParameterSets) {
                    $setParameters = $set.Parameters | Foreach-Object { $_.Name; $_.Aliases }
                    if ($parameters | Where-Object { $_.Name -notin $setParameters }) {
                        # Do nothing
                    }
                    else {
                        $set
                    }
                }
                if ($ParameterSet.Count -gt 1) {
                    $ParameterSet = $ParameterSet | Where-Object { $_.IsDefault }
                    if ($ParameterSet.Count -gt 1) {
                        $ParameterSet = $ParameterSet[0]
                    }
                }
                if (-not $ParameterSet) {
                    $ParameterSet = $ParsedCommandData.ParameterSets | Where-Object { $_.IsDefault }
                }
                
                if (-not $ParameterSet) {
                    $ParameterSet = $ParsedCommandData.ParameterSets[0]
                }
            }
            else {
                $ParameterSet = $ParsedCommandData.ParameterSets
            }
            # Get the parameter name based on the position number
            $ParameterName = ($ParameterSet.Parameters | Where-Object { $_.Position -eq $parameters.Count }).Name
            # if the position does not match, get the parameter from the array value
            if ([string]::IsNullOrEmpty($ParameterName)) {
                $ParameterName = ($ParameterSet.Parameters[$parameters.Count]).Name
            }
            if ($parameters.Count -gt 0) {
                $parameters[-1].End = $i
            }
            [System.Collections.Generic.List[PSObject]] $Value = @()
            $parameters.Add([pscustomobject]@{Name = $ParameterName; Value = $Value; Start = $i; End = 0 })
        }
        elseif ($LParen -eq 0 -and $ref[$i].Kind -notin 'Dot', 'LParen', 'DollarParen', 'AtCurly') {
            $parametersExpected = $true
        }
        Write-Debug "$LParen $parametersExpected - $($ref[$i].Text) - $($ref[$i].Kind)"
        if ($ref[$i].Kind -in 'LParen', 'DollarParen', 'AtCurly') {
            $LParen++
        }
        elseif ($ref[$i + 1].Kind -eq 'Dot') {
            $parametersExpected = $false
        }
    }


    foreach ($p in $parameters) {
        for ($i = $p.Start; $i -lt $p.End; $i++) {
            Write-Debug "$($ref[$i].Text) - $($ref[$i].Kind)"
            if ($ref[$i].Kind -in 'Identifier', 'Generic' -and $ref[$i].TokenFlags -ne 'CommandName') {
                # check if the value is in quotes and add them if not
                if ($ref[$i].Text[0] -notin '"', "'" -and ($p.End - $p.Start) -eq 1) {
                    $p.Value.Add("'$($ref[$i].Text.Replace("'","''"))'")
                }
                else {
                    $p.Value.Add($ref[$i].Text)
                }
            }
            elseif ($ref[$i].Kind -notin 'EndOfInput', 'Parameter') {
                $p.Value.Add($ref[$i].Text)
            }
        }
    }
    $parameters | Where-Object { $_.Start -eq $_.End -and $_.Value.Count -eq 0 } | ForEach-Object { $_.Value.Add('$true') }

    $spacing = ($parameters.Name | Measure-Object -Maximum -Property Length).Maximum
    $spacing++

    [System.Collections.Generic.List[PSObject]] $output = @()
    # build the output
    $output.Add("`$$($hash) = @{")
    $parameters | ForEach-Object {
        $output.Add(("`t$($_.Name)$(' '*$($spacing - $_.Name.Length))= $($_.Value -join(' '))").Replace(' . ', '.'))
    } 
    $output.Add("}")
    # if there were pipelines add them back in
    if ($Split.Count -gt 1) {
        $pipes = $Split[1..($Split.Length - 1)]
        $output.Add((@("$($ParsedCommand) @$($hash)") + @($pipes)) -join (' | '))
    }
    else {
        $output.Add("$($ParsedCommand) @$($hash)")
    }
    
    $return = [SplatBlock]@{
        Command   = $index.Value
        IsDefault = $null
        HashBlock = ($output -join ("`n"))
        SetBlock  = $null
    }

    
    $return.HashBlock | Set-Clipboard

    $return
}
#EndRegion '.\Public\ConvertTo-Splatting.ps1' 252
#Region '.\Public\Copy-PSNote.ps1' -1

Function Copy-PSNote{
    <#
    .SYNOPSIS
        Use to display a list of notes in a selectable menu so you can choose which to copy to your clipboard

    .DESCRIPTION
        Allows you to search for snippets by name or by tag. You can also search all 
        properties by using the SearchString parameter. Search results are displayed
        in a selectable menu and you are prompted to select which one you want to 
        add to your clipboard.

    .PARAMETER Note
        The note you want to return. Accepts wildcards

    .PARAMETER Tag
        The tag of the note(s) you want to return.

    .PARAMETER SearchString
        Use to search for text in the note's name, details, snippet, alias, and tags

    .EXAMPLE
        Copy-PSNote

        Returns a menu with all notes

    .EXAMPLE
        Copy-PSNote -Name 'creds'

        Returns a menu with the note creds
    
    .EXAMPLE
        Copy-PSNote -Name 'cred*'

        Returns a menu with all notes that start with cred

    .EXAMPLE
        Copy-PSNote -tag 'AD'

        Returns a menu with all notes with the tag 'AD'

    .EXAMPLE
        Copy-PSNote -Name '*user*' -tag 'AD'

        Returns a menu with all notes with user in the name and the tag 'AD'

    .EXAMPLE
        Copy-PSNote -SearchString 'day'

        Returns a menu with all notes with the word day in the name, details, snippet text, alias, or tags
    
        .LINK
        https://github.com/mdowst/PSNotes
    #>
    [cmdletbinding(DefaultParameterSetName="Note")]
    param(    
        [Alias("Name")]    
        [parameter(Mandatory=$false, ParameterSetName="Note", Position = 0)]
        [string]$Note = '*',
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [string]$Tag,
        [parameter(Mandatory=$false, ParameterSetName="Search", Position = 0)]
        [string]$SearchString
    )
    Test-PSNotesInitalize
    $NoteSelection = @(Get-PSNote @PSBoundParameters)
    $noteSnippet = Write-NoteSnippet $NoteSelection

    if(-not [string]::IsNullOrEmpty($noteSnippet)){
        $noteSnippet | Set-Clipboard
    }
}
#EndRegion '.\Public\Copy-PSNote.ps1' 72
#Region '.\Public\Export-PSNote.ps1' -1

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

        Exportall notes to a JSON file.

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
        Test-PSNotesInitalize
        [System.Collections.Generic.List[PSNoteExport]] $ExportObjects = @()
        Write-Verbose "$($noteObject | FT | Out-String)"
    }
    process{
        # If All add all objects otherwise only add those passed
        if($All){
            $script:_noteObjects | ForEach-Object{ $ExportObjects.Add( [PSNoteExport]::New( $_ ) ) }
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
#EndRegion '.\Public\Export-PSNote.ps1' 81
#Region '.\Public\Get-CommandSplatting.ps1' -1

Function Get-CommandSplatting {
    <#
    .SYNOPSIS
    Use to output the parameters for a command in splatting format

    .DESCRIPTION
    Use to output the parameters for a command in splatting format

    .PARAMETER Command
    The command to get the parameters for

    .PARAMETER ParameterSet
    Use to specify a specific parameter set. Use the -ListParameterSets to get a quick
    view of all the different Parameter Set names. 

    .PARAMETER ListParameterSets
    Use to list the different Parameter Sets available for the command. Output is shortened 
    to only show the names. Use -All to return splatting for all parameter sets.

    .PARAMETER All
    Use to return full splatting for all parameter sets

    .PARAMETER IncludeCommon
    Use to include the PowerShell common parameters in the splatting output. (e.g. Verbose, ErrorAction, etc.)

    .EXAMPLE 
    Get-CommandSplatting -Command 'Get-Item'

    Get the default parameter set for a command

    --- Output ----
    Name      : Path
    IsDefault : True
    SetBlock :
            [string[]]$Path = ''
            [string]$Filter = ''
            [string[]]$Include = ''
            [string[]]$Exclude = ''
            [Boolean]$Force = $false # Switch
            [pscredential]$Credential = ''
            [string[]]$Stream = ''
    HashBlock :
            $Item = @{
                    Path       = $Path       #Required
                    Filter     = $Filter
                    Include    = $Include
                    Exclude    = $Exclude
                    Force      = $Force
                    Credential = $Credential
                    Stream     = $Stream
            }
            Get-Item @Item


    .EXAMPLE
    Get-CommandSplatting -Command 'Get-Item' -ListParameterSets

    List the available parameter sets for a command

    --- Output ----
    ParameterSet : Path
    IsDefault    : True
    Parameters   : Path, Filter, Include, Exclude, Force, Credential, Stream

    ParameterSet : LiteralPath
    IsDefault    : False
    Parameters   : LiteralPath, Filter, Include, Exclude, Force, Credential, Stream


    .EXAMPLE 
    Get-CommandSplatting -Command 'Get-Item' -ParameterSet LiteralPath

    Get specific parameter set for a command

    --- Output ----
    ParameterSet : LiteralPath
    IsDefault    : False
    SetBlock     :
            [string[]]$LiteralPath = '' 
            [string]$Filter = '' 
            [string[]]$Include = ''
            [string[]]$Exclude = ''
            [Boolean]$Force = $false # Switch
            [pscredential]$Credential = ''
            [string[]]$Stream = ''
    HashBlock  :
            $ItemLiteralPath = @{
                    LiteralPath = $LiteralPath #Required
                    Filter      = $Filter
                    Include     = $Include
                    Exclude     = $Exclude
                    Force       = $Force
                    Credential  = $Credential
                    Stream      = $Stream
            }
            Get-Item @ItemLiteralPath


    .EXAMPLE 
    Get-CommandSplatting -Command 'Get-Item' -All

    Get all parameter sets for a command

    --- Output ----
    ParameterSet : Path
    IsDefault    : True
    SetBlock     :
            [string[]]$Path = '' 
            [string]$Filter = '' 
            [string[]]$Include = '' 
            [string[]]$Exclude = '' 
            [Boolean]$Force = $false # Switch 
            [pscredential]$Credential = '' 
            [string[]]$Stream = ''
    HashBlock  :
            $ItemPath = @{ 
                    Path       = $Path       #Required 
                    Filter     = $Filter 
                    Include    = $Include 
                    Exclude    = $Exclude
                    Force      = $Force
                    Credential = $Credential
                    Stream     = $Stream
            }
            Get-Item @ItemPath
    ParameterSet : LiteralPath
    IsDefault    : False
    SetBlock     :
            [string[]]$LiteralPath = ''
            [string]$Filter = ''
            [string[]]$Include = ''
            [string[]]$Exclude = ''
            [Boolean]$Force = $false # Switch
            [pscredential]$Credential = ''
            [string[]]$Stream = ''
    HashBlock  :
            $ItemLiteralPath = @{
                    LiteralPath = $LiteralPath #Required
                    Filter      = $Filter
                    Include     = $Include
                    Exclude     = $Exclude
                    Force       = $Force
                    Credential  = $Credential
                    Stream      = $Stream
            }
            Get-Item @ItemLiteralPath


    .NOTES
    General notes
    #>
    [CmdletBinding(DefaultParameterSetName = 'ParameterSet')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]    
        [string]$Command,
        [Parameter(ParameterSetName = 'ParameterSet', Position = 1)]
        [string]$ParameterSet,
        [Parameter(ParameterSetName = 'ListParameterSets', Position = 1)]
        [switch]$ListParameterSets,
        [Parameter(ParameterSetName = 'All', Position = 1)]
        [switch]$All,
        [Parameter(Mandatory = $false, Position = 2)]
        [switch]$IncludeCommon,
        [Parameter(Mandatory = $false, Position = 3)]
        [switch]$Copy
    )

    # Get the command
    $commandData = Get-Command $command

    # Get the parameter sets
    $ParameterSets = $null
    if ($All -eq $true) {
        $ParameterSets = @($commandData.ParameterSets)
        if ($ParameterSets.Count -eq 0) {
            throw "Unable to find parameter sets"
        }
    }
    elseif ($ListParameterSets -eq $true) {
        $Output = $commandData.ParameterSets | Select-Object -Property @{l = 'ParameterSet'; e = { $_.Name } }, IsDefault, @{l = 'Parameters'; e = { @($_.Parameters.Name | 
                    Where-Object { $_ -notin [System.Management.Automation.Cmdlet]::CommonParameters }) -join (', ') }
        } |
        ForEach-Object { 
            [SplatBlock]@{
                ParameterSet = $_.ParameterSet
                IsDefault    = $_.IsDefault
                HashBlock    = $_.Parameters
                SetBlock     = $null
            } 
        }
    }
    elseif (-not [string]::IsNullOrEmpty($ParameterSet)) {
        $ParameterSets = $commandData.ParameterSets | Where-Object { $_.Name -eq $ParameterSet }
        if ($ParameterSets.Count -lt 1 -and $Output.Count -eq 0) {
            throw "Unable to find parameter set '$($ParameterSet)'"
        }
    }
    else {
        $ParameterSets = @($commandData.ParameterSets | Where-Object { $_.IsDefault -eq $trufe })
        if ($ParameterSets.Count -eq 0) {
            $ParameterSets = @($commandData.ParameterSets[0])
        }
        if ($ParameterSets.Count -lt 1) {
            throw "Unable to find the default parameter set"
        }
    }

    $hash = $command.Split('-')[-1]

    if ($ListParameterSets -ne $true) {
        $Output = foreach ($set in $ParameterSets) {
            [System.Collections.Generic.List[PSObject]]$hashBlock = @()
            [System.Collections.Generic.List[PSObject]]$setBlock = @()
            $hashBlock.Add("`$$($hash)$($set.Name) = @{")
            $length = 0

            $Parameters = $set.Parameters
            if ($IncludeCommon -ne $true) {
                $Parameters = $set.Parameters | Where-Object { $_.Name -notin 
                    [System.Management.Automation.Cmdlet]::CommonParameters }
            }
            $Parameters.Name | ForEach-Object { if ($_.Length -gt $length) { $length = $_.length } }

            $LastOrder = $Parameters | Sort-Object Position | Select-Object -ExpandProperty Position -Last 1
            if ($LastOrder -ge 0) {
                $SortedParameters = $Parameters | 
                Select-Object -Property *, @{l = 'Order'; e = { if ($_.Position -lt 0) { $LastOrder + 1 } else { $_.Position } } } |
                Sort-Object Order
            }
            else {
                $SortedParameters = $Parameters | Sort-Object Position
            }

            Foreach ($p in $SortedParameters) {
                $l = $length - $p.Name.Length
		
                if ($p.ParameterType.Name -eq 'SwitchParameter') {
                    $setBlock.Add("[Boolean]`$$($p.Name) = `$false # Switch")
                }
                else {
                    $setBlock.Add("[$($p.ParameterType)]`$$($p.Name) = ''")	
                }
		
                [string]$row = "`t$($p.Name)$(' ' * $l) = `$$($p.Name)"
                if ($p.IsMandatory -eq $true) {
                    $row += "$(' ' * $l) #Required"
                }
                $hashBlock.Add($row)
            }
            $hashBlock.Add('}')
            $hashBlock.Add("$command @$($hash)$($set.Name)")
            [SplatBlock]@{
                Command      = $Command
                ParameterSet = $set.Name
                IsDefault    = $set.IsDefault
                HashBlock    = ($hashBlock -join ("`n"))
                SetBlock     = ($setBlock -join ("`n"))
            }
        }
    }

    if($Copy -eq $true){
        $Output | Select-Object -First 1 | ForEach-Object{
            "$($_.SetBlock)`n$($_.HashBlock)" | Set-Clipboard
        }
    }

    $Output
}
#EndRegion '.\Public\Get-CommandSplatting.ps1' 270
#Region '.\Public\Get-PSNote.ps1' -1

Function Get-PSNote{
    <#
    .SYNOPSIS
        Use to search for or list the different PSNotes

    .DESCRIPTION
        Allows you to search for snippets by name or by tag. You can also search all 
        properties by using the SearchString parameter

    .PARAMETER Note
        The note you want to return. Accepts wildcards

    .PARAMETER Tag
        The tag of the note(s) you want to return.

    .PARAMETER Copy
        If specfied the the Snippet will be copied to your clipboard

    .PARAMETER SearchString
        Use to search for text in the note's name, details, snippet, alias, and tags

    .EXAMPLE
        Get-PSNote

        Returns all notes

    .EXAMPLE
        Get-PSNote -Note 'creds'

        Returns the note creds
    
    .EXAMPLE
        Get-PSNote -Note 'cred*'

        Returns all notes that start with cred

    .EXAMPLE
        Get-PSNote -tag 'AD'

        Returns all notes with the tag 'AD'

    .EXAMPLE
        Get-PSNote -Note '*user*' -tag 'AD'

        Returns all notes with user in the name and the tag 'AD'

    .EXAMPLE
        Get-PSNote -SearchString 'day'

        Returns all notes with the word day in the name, details, snippet text, alias, or tags
    
        .LINK
        https://github.com/mdowst/PSNotes
    #>
    [cmdletbinding(DefaultParameterSetName="Note")]
    param(    
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [string]$Note = '*',
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [string]$Tag,
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [switch]$Copy,
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [switch]$Run,
        [parameter(Mandatory=$false, ParameterSetName="Search")]
        [string]$SearchString
    )
    Test-PSNotesInitalize

    if($SearchString){
        [System.Collections.Generic.List[PSNoteSearch]] $SearchResults = @()
        $script:_noteStore.Notes | Where-Object{ $_.Note -like "*$SearchString*" -or $_.Alias -like "*$SearchString*" -or 
            $_.Details -like "*$SearchString*" -or $_.Snippet -like "*$SearchString*" } | ForEach-Object { $SearchResults.Add($_) }
        $script:_noteStore.Notes | Where-Object{ $SearchResults.Note -notcontains $_.Note } | ForEach-Object { 
            $tagMatch = $false
            $_.tag | ForEach-Object {
                if($_ -like "*$SearchString*"){
                    $tagMatch = $true
                }
            }
            if($tagMatch){
                $SearchResults.Add($_) 
            }
        }
        $returned = $SearchResults
    } elseif($Tag){
        $returned = $script:_noteStore.Notes | Where-Object{$_.Note -like $note -and $_.Tags -contains $Tag}
    } else {
        $returned = $script:_noteStore.Notes | Where-Object{$_.Note -like $note}
    }
    
    if($copy){
        if(@($returned).count -gt 1){
            Write-Warning "More than 1 command returned. Only the first one will be written to the clipboard"
        }
        if(Get-Command -Name 'Set-Clipboard' -ErrorAction SilentlyContinue){
            $returned | Select-Object -First 1 -ExpandProperty Snippet | Set-Clipboard
        } else {
            Write-Debug "Cmdlet 'Set-Clipboard' not found."
        }
    }

    if($Run){
        if(@($returned).count -gt 1){
            Write-Warning -Message "$($returned | Select-Object -First 1 -ExpandProperty Snippet)"
            Write-Warning -Message "More than 1 command was returned. If you continue Only the first one will be run" -WarningAction Inquire
        }

        $Snippet = $returned | Select-Object -First 1 -ExpandProperty Snippet
        $ScriptBlock = $executioncontext.invokecommand.NewScriptBlock($Snippet)
        Invoke-Command -ScriptBlock $ScriptBlock
    } else {
        $returned
    }

}
#EndRegion '.\Public\Get-PSNote.ps1' 117
#Region '.\Public\Get-PSNoteAlias.ps1' -1

Function Get-PSNoteAlias{
    <#
    .SYNOPSIS
        Use display snippet and copy to clipboard using an Alias

    .DESCRIPTION
        When the PSNotes module loads, it creates Aliases for all snippets.
        Those aliases are mapped to this command and it will return the snippet
        and copy it to your clipboard. You cannot call this function directly
        as it will not return anything.

    .LINK
        https://github.com/mdowst/PSNotes
    
    
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$false)]
        [switch]$Copy,
        [parameter(Mandatory=$false)]
        [switch]$Run
    )
    Test-PSNotesInitalize
    if($MyInvocation.MyCommand.Name -eq $MyInvocation.InvocationName){
        Write-Error "The Get-PSNoteAlias cmdlet is designed to be called using an alias and not directly."
    } else {
        $Alias = $MyInvocation.InvocationName
        $aliasObject = $script:_noteStore.Notes | Where-Object{$_.Alias -eq $Alias}
        if($Run){
            Get-PSNote -Note $aliasObject.Note -Run
        } else {
            if(Get-Command -Name 'Set-Clipboard' -ErrorAction SilentlyContinue){
                $returned | Select-Object -First 1 -ExpandProperty Snippet | Set-Clipboard
            } else {
                Write-Debug "Cmdlet 'Set-Clipboard' not found."
            }
            Return $aliasObject.Snippet
        }
    }
}

#EndRegion '.\Public\Get-PSNoteAlias.ps1' 43
#Region '.\Public\Import-PSNote.ps1' -1

Function Import-PSNote{
    <#
    .SYNOPSIS
        Use to import a PSNotes JSON fiile

    .DESCRIPTION
        Allows you to import shared PSNotes JSON files to your local notes. They can be imported to your personal
        store, or they can be imported to a seperate file. 

    .PARAMETER NoteObject
        The PSNote objects you want to export. Use Get-PSNote to build the object and pass it to the parameter
        or use a pipeline to pass it.

    .PARAMETER Path
        The path to the PSNotes JSON file to export to.

    .PARAMETER Catalog
        Use to output snippets to a seperate file stored in the folder %APPDATA%\PSNotes.
        Useful for when you want to share different snippet types.

    .EXAMPLE
        Import-PSNote -Path C:\Import\MyPSNotes.json

        Imports the contents of the file MyPSNotes.json and saves it to your personal PSNotes.json file

    .EXAMPLE
        Import-PSNote -Path C:\Export\MyPSNotes.json -Catalog 'ADNotes'

        Imports the contents of the file MyPSNotes.json and saves it to the file ADNotes.json in the folder %APPDATA%\PSNotes
    
    .LINK
        https://github.com/mdowst/PSNotes
    #>
    [cmdletbinding(DefaultParameterSetName="Note")]
    param(    
        [parameter(Mandatory=$true)]
        [string]$Path,
        [parameter(Mandatory=$false)]
        [string]$Catalog
    )
    Test-PSNotesInitalize
    # If Catalog check name and set path
    if($Catalog){
        # confirm the Catalog string is a valid file name
        if($Catalog.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -ne -1){
            throw "The catalog name '$Catalog' is an invalid file name. Invalid characater found in place $($Catalog.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()))"
        }
        # Set path the path for the catalog item 
        $CatalogPath = Join-Path $env:PSNOTES_HOME "$Catalog.json"
    } else {
        $CatalogPath = $env:PSNotesUserJsonFile
    }

    [System.Collections.Generic.List[PSNote]] $ImportObjects = @()
    $(Get-Content $Path -Raw | ConvertFrom-Json) | Select-Object Note, Snippet, Details, Alias, Tags, @{l='file';e={$CatalogPath}}| 
        ForEach-Object{ $ImportObjects.Add([PSNote]::New($_)) }
    
    # Append the new notes to the appropriate file
    Export-PSNote -NoteObject $ImportObjects -Path $CatalogPath -Append 

    # Reinitialize the Json files to reload everything
    Initialize-PSNotesJsonFile
}
#EndRegion '.\Public\Import-PSNote.ps1' 64
#Region '.\Public\Invoke-PSNote.ps1' -1

Function Invoke-PSNote{
    <#
    .SYNOPSIS
        Use to display a list of notes in a selectable menu so you can choose which to run

    .DESCRIPTION
        Allows you to search for snippets by name or by tag. You can also search all 
        properties by using the SearchString parameter. Search results are displayed
        in a selectable menu and you are prompted to select which one you want to run.

    .PARAMETER Note
        The note you want to run. Accepts wildcards

    .PARAMETER Tag
        The tag of the note(s) you want to run.

    .PARAMETER SearchString
        Use to search for text in the note's name, details, snippet, alias, and tags

    .EXAMPLE
        Invoke-PSNote

        Returns a menu with all notes

    .EXAMPLE
        Invoke-PSNote -Name 'creds'

        Returns a menu with the note creds
    
    .EXAMPLE
        Invoke-PSNote -Name 'cred*'

        Returns a menu with all notes that start with cred

    .EXAMPLE
        Invoke-PSNote -tag 'AD'

        Returns a menu with all notes with the tag 'AD'

    .EXAMPLE
        Invoke-PSNote -Name '*user*' -tag 'AD'

        Returns a menu with all notes with user in the name and the tag 'AD'

    .EXAMPLE
        Invoke-PSNote -SearchString 'day'

        Returns a menu with all notes with the word day in the name, details, snippet text, alias, or tags
    
        .LINK
        https://github.com/mdowst/PSNotes
    #>
    [cmdletbinding(DefaultParameterSetName="Note")]
    param(    
        [Alias("Name")]    
        [parameter(Mandatory=$false, ParameterSetName="Note", Position = 0)]
        [string]$Note = '*',
        [parameter(Mandatory=$false, ParameterSetName="Note")]
        [string]$Tag,
        [parameter(Mandatory=$false, ParameterSetName="Search", Position = 0)]
        [string]$SearchString
    )
    Test-PSNotesInitalize
    $NoteSelection = @(Get-PSNote @PSBoundParameters)
    $noteSnippet = Write-NoteSnippet $NoteSelection

    if(-not [string]::IsNullOrEmpty($noteSnippet)){
        $ScriptBlock = $executioncontext.invokecommand.NewScriptBlock($noteSnippet)
        Invoke-Command -ScriptBlock $ScriptBlock
    }
}
#EndRegion '.\Public\Invoke-PSNote.ps1' 72
#Region '.\Public\New-PSNote.ps1' -1

Function New-PSNote {
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
        Specifies the snippet to save. Enclose the commands in braces { } to create a script block.

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
        New-PSNote -Note 'CpuUsage' -Tags 'perf' -Alias 'cpu' -ScriptBlock {
            Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average
        }

        Creates a new Note using a script block instead of a snippet string
    
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
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low', DefaultParameterSetName = "Note")]
    param(
        [parameter(Mandatory = $true)]
        [string]$Note,
        [parameter(Mandatory = $false, ParameterSetName = "Snippet")]
        [string]$Snippet,
        [parameter(Mandatory = $false, ParameterSetName = "ScriptBlock")]
        [ScriptBlock]$ScriptBlock,
        [parameter(Mandatory = $false)]
        [string]$Details,
        [parameter(Mandatory = $false)]
        [string]$Alias,
        [parameter(Mandatory = $false)]
        [string[]]$Tags,
        [parameter(Mandatory = $false)]
        [string]$Catalog = 'PSNotes',
        [parameter(Mandatory = $false)]
        [switch]$Force
    )
    Test-PSNotesInitalize
    Function Test-NoteAlias {
        param($Alias)
        
        $AliasCheck = [regex]::Matches($Alias, "[^0-9a-zA-Z\-_]")
        if ($AliasCheck.Success) {
            throw "'$Alias' is not a valid alias. Alias's can only contain letters, numbers, dashes(-), and underscores (_)."
        } 
    }

    if (-not [string]::IsNullOrEmpty($ScriptBlock)) {
        $Snippet = $ScriptBlock.ToString()
    }

    $newNote = $script:_noteStore.Notes | Where-Object { $_.Note -eq $Note }
    if ($newNote -and -not $force) {
        Write-Error "The note '$Note' already exists. Use -force to overwrite existing properties"
        break
    }
    elseif ($newNote -and $force) {
        $toUpdate = $script:_noteStore.Notes | Where-Object { $_.Note -eq $Note } | ForEach-Object {
            $tu = [PSNote]::new($_)
            if (-not [string]::IsNullOrEmpty($Snippet)) {
                $tu.Snippet = $Snippet
            }
            if (-not [string]::IsNullOrEmpty($Details)) {
                $tu.Details = $Details
            }
            if (-not [string]::IsNullOrEmpty($Alias)) {
                Test-NoteAlias $Alias
                $tu.Alias = $Alias
            }
            if (-not [string]::IsNullOrEmpty($Tags)) {
                $tu.Tags = $Tags
            }
            if (-not [string]::IsNullOrEmpty($Catalog)) {
                $tu.Catalog = $Catalog
            }
            $tu
        }
        $toUpdate | ForEach-Object {
            Write-Verbose "Updating Note: $($_.Note)"
            $script:_noteStore.UpdateNote($_)
        }
    }
    else {
        if ([string]::IsNullOrEmpty($Alias)) {
            $Alias = $Note
        }

        Test-NoteAlias $Alias
        
        $newNote = [PSNote]::New($Note, $Snippet, $Details, $Alias, $Tags, $Catalog)
        $script:_noteStore.AddNote($newNote)
    }
    
    Set-Alias -Name $newNote.Alias -Value Get-PSNoteAlias -Scope Global
}
#EndRegion '.\Public\New-PSNote.ps1' 148
#Region '.\Public\Remove-PSNote.ps1' -1

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
#EndRegion '.\Public\Remove-PSNote.ps1' 62
#Region '.\Public\Set-PSNote.ps1' -1

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
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low', DefaultParameterSetName = "Note")]
    param(
        [parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$True)]
        [string]$Note,
        [parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$True)]
        [string]$Catalog,
        [parameter(Mandatory = $false, ParameterSetName = "Snippet")]
        [string]$Snippet,
        [parameter(Mandatory = $false, ParameterSetName = "ScriptBlock")]
        [ScriptBlock]$ScriptBlock,
        [parameter(Mandatory = $false)]
        [string]$Details,
        [parameter(Mandatory = $false)]
        [string]$Alias,
        [parameter(Mandatory = $false)]
        [string[]]$Tags
    )
    Test-PSNotesInitalize
    $check = $script:_noteStore.Notes | Where-Object { $_.Note -eq $Note -and $_.Catalog -eq $Catalog }
    if (-not $check) {
        Write-Warning "The note '$Note' does not exist in catalog '$Catalog'. An attempt will be made to create it."
    } 

    New-PSNote @PSBoundParameters -Force
}
#EndRegion '.\Public\Set-PSNote.ps1' 74


Initialize-PSNotes

