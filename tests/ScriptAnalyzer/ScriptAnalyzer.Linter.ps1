Import-Module PSScriptAnalyzer
$Source = Join-Path (Split-Path(Split-Path $PSScriptRoot)) 'src'
$Settings = Join-Path $PSScriptRoot 'PSScriptAnalyzerSettings.psd1'
Invoke-ScriptAnalyzer -Path $Source -Recurse -Settings $Settings

