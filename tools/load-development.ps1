param(
    [switch]$Refresh
)
$Path = Join-Path (Split-Path $PSScriptRoot) 'src'

$psd1 = Join-Path -Path $Path -ChildPath 'PSNotes.psd1'
$psm1 = Join-Path -Path $Path -ChildPath 'PSNotes.psm1'

# Create a temporary directory for test files
$script:TestDir = Join-Path ([System.IO.Path]::GetTempPath()) "PSNotesTests\MyTests"
$null = New-Item -Path $script:TestDir -ItemType Directory -Force

# Set up test environment variable
$script:OriginalPSNotesHome = $env:PSNOTES_HOME
$env:PSNOTES_HOME = $script:TestDir
if ($Refresh -and (Test-Path $env:PSNOTES_HOME)) {
    Remove-Item -Path $env:PSNOTES_HOME -Recurse -Force
}
$null = New-Item -Path $env:PSNOTES_HOME -ItemType Directory -Force

# Create the .psm1 file by dot sourcing all .ps1 files in the src folder and subfolders
$psm1Script = {
    $Path = $PSScriptRoot
    # Import the functions
    foreach ($folder in @('classes', 'private', 'public')) {
        $root = Join-Path -Path $Path -ChildPath $folder
        if (Test-Path -Path $root) {
            Write-Verbose "processing folder $root"
            $files = Get-ChildItem -Path $root -Filter *.ps1 -Recurse

            # dot source each file
            $files | where-Object { $_.name -NotLike '*.Tests.ps1' } |
            ForEach-Object { Write-Verbose $_.name; . $_.FullName }
        }
    }

    # Load all commands to noteObjects
    Initialize-PSNoteStore
}

# Create the .psm1 file, import the module, and then remove the .psm1 file
$psm1Script.ToString() | Out-File -FilePath $psm1 -Encoding UTF8 -Force
Import-Module -Name $psd1 -Force -Verbose
Remove-Item -Path $psm1 -Force

# Import the classes into the current session so they can be used to debug outside of the module
$root = Join-Path -Path $Path -ChildPath 'classes'
if (Test-Path -Path $root) {
    Write-Verbose "processing folder $root"
    $files = Get-ChildItem -Path $root -Filter *.ps1 -Recurse

    # dot source each file
    $files | where-Object { $_.name -NotLike '*.Tests.ps1' } |
    ForEach-Object { Write-Verbose $_.name; . $_.FullName }
}

# Initialize the note store for use in the current session, this allows us to use the PSNotes commands outside of the module for testing and debugging
# This is the same code that is used in the Initialize-PSNoteStore command, but we need to run it here to initialize the note store for the current session
$script:_noteStore = [NoteStore]::new()
Write-Verbose "User PSNotes Path: $env:PSNOTES_HOME"
Get-ChildItem -Path $env:PSNOTES_HOME -Filter '*.json' | Where-Object { $_.BaseName -notin 'Default' } | ForEach-Object {
    $script:_noteStore.LoadCatalog($_.BaseName)
}