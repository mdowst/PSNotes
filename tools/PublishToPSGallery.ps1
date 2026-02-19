<#
Run build.ps1 first
#>

# Script variables
$TopLevel = (Split-Path $PSScriptRoot)
$NugetAPIKey = Get-Content (Join-Path $PSScriptRoot 'APIKey.json')

Set-Location $TopLevel

# Get the module manifest
$psd1File = Get-ChildItem -Path (Join-Path $TopLevel 'bin\PSNotes') -Filter 'PSNotes.psd1' -Recurse | Select-Object -Last 1
$psd1 = Test-ModuleManifest $psd1File
Read-Host "Publish version '$($psd1.Version)'"

# Publish to powershell gallery
Publish-Module -Path $psd1File.DirectoryName -NugetAPIKey $NugetAPIKey -Verbose