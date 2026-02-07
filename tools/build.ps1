[CmdletBinding()]
param(

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $OutDir = (Join-Path (Split-Path $PSScriptRoot) 'bin'),

    [Parameter()]
    [version] $Version
)

$ErrorActionPreference = 'Stop'
# This can some times cause old versions to load in the current session, so we capture the directory and then clean up anything that might have been added.
$homePath = if (Get-Variable -Name IsLinux -Scope Global -ValueOnly -ErrorAction SilentlyContinue) {
    '/home/PSNotes'
}
else {
    Join-Path $env:APPDATA 'PSNotes'
}
$beforeFiles = if (Test-Path $homePath) {
    Get-ChildItem -Path $homePath -File
}

# --- Ensure ModuleBuilder is available (build-time dependency) ---
if (-not (Get-Module -ListAvailable -Name ModuleBuilder)) {
    throw "ModuleBuilder is required to build. Install it (e.g. Install-Module ModuleBuilder -Scope CurrentUser) and re-run."
}
Import-Module ModuleBuilder -ErrorAction Stop
if (-not (Get-Module -ListAvailable -Name EZOut)) {
    throw "EZOut is required to build. Install it (e.g. Install-Module EZOut -Scope CurrentUser) and re-run."
}
Import-Module EZOut -ErrorAction Stop

$currentPath = (Get-Location).Path
$sourceRoot = Join-Path (Split-Path $PSScriptRoot -Parent) 'src'
Set-Location -LiteralPath $sourceRoot
$destRoot = Join-Path $OutDir 'PSNotes'

if (Test-Path -LiteralPath $destRoot) {
    Remove-Item -LiteralPath $destRoot -Recurse -Force
}
if (Test-Path -LiteralPath $OutDir) {
    Get-ChildItem -LiteralPath $OutDir -Filter '*.nupkg' | Remove-Item -Force
}

..\tools\PSNotes.ezformat.ps1 -formatPath (Join-Path $sourceRoot 'PSNotes.format.ps1xml') | Out-Null

$linter = . '..\tests\ScriptAnalyzer\ScriptAnalyzer.Linter.ps1'
if ($linter) {
    $linter
    throw "Failed linter tests"
}

$buildParams = @{
    SourcePath      = $sourceRoot
    OutputDirectory = $destRoot
    Encoding        = 'UTF8Bom'  # consistent cross-platform
}

$sourceManifest = Join-Path $sourceRoot 'PSNotes.psd1'

if (-not $PSBoundParameters.ContainsKey('Version') -or [string]::IsNullOrEmpty($Version)) {
    $Version = (Import-PowerShellDataFile -Path $sourceManifest).ModuleVersion
}
elseif($Version -match '^v'){
	$Version = $Version.Replace('v','')
}
$buildParams['Version'] = $Version


Write-Host "Building PSNotes module..." -ForegroundColor Cyan
Write-Host "  SourcePath     :  $sourceRoot"
Write-Host "  SourceManifest : $sourceManifest"
Write-Host "  OutputDir      : $destRoot"
Write-Host "  Version        : $Version"

Build-Module @buildParams | Out-Null

Write-Host "Build complete: $destRoot" -ForegroundColor Green
Get-ChildItem -LiteralPath $destRoot -Filter 'PSNotes.psd1' -Recurse | ForEach-Object {
    Write-Host "Validating manifest: $($_.FullName)" -ForegroundColor Cyan
    Test-ModuleManifest -Path $_.FullName | Out-Null
    Write-Host "Manifest valid." -ForegroundColor Green
}

Get-ChildItem -LiteralPath $destRoot -Filter 'PSNotes.psm1' -Recurse | ForEach-Object {
    Out-File -Append -FilePath $_.FullName -Encoding UTF8 -InputObject "`n`nInitialize-PSNoteStore`n"
}

# Create NuGet Package
Set-Location -Path $PSScriptRoot
$psd1 = Get-ChildItem $OutDir -Filter '*.psd1' -Recurse | Select-Object -Last 1
$nuspec = Get-ChildItem $PSScriptRoot -Filter '*.nuspec' -Recurse | Foreach-Object {
    Copy-Item -Path $_.FullName -Destination $psd1.DirectoryName -PassThru
}

.\nuget.exe pack "$($nuspec.FullName)" -OutputDirectory $OutDir -Version "$($Version)"

Get-ChildItem $psd1.DirectoryName -Filter '*.nuspec' | Remove-Item -Force

Set-Location -LiteralPath $currentPath


# Clean up any loaded files that were not present before.
if (Test-Path $homePath) {
    Get-ChildItem -Path $homePath -File | Where-Object {
        $beforeFiles.Name -notcontains $_.Name
    } | ForEach-Object {
        Remove-Item -Path $_.FullName -Force
    }
}