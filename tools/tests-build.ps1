$Parent = $PSScriptRoot
while ( -not (Test-Path (Join-Path $Parent 'src'))) {
    $Parent = Split-Path $Parent -Parent
}

$TestPath = Join-Path $Parent 'tests'
$binPath = Join-Path $Parent 'bin'
if(-not (Test-Path $binPath)){
   New-Item -ItemType Directory -Force -Path $binPath | Out-Null
}

$psd1 = Get-ChildItem -Path $binPath -Recurse -Filter 'PSNotes.psd1' | Select-Object -Last 1 -ExpandProperty FullName
if(-not $psd1){
    Write-Host "PSNotes.psd1 not found in $binPath. Please build the module before running tests."
    exit 1
}

# Run Unit Tests
$config = New-PesterConfiguration
$config.Output.Verbosity = 'Detailed'
$config.Run.Throw = $false
$config.TestResult.Enabled = $true
$config.TestResult.OutputFormat = 'JUnitXml'
$config.Run.Path = (Join-Path $TestPath 'Build')
$config.TestResult.OutputPath   = (Join-Path $binPath 'Build.TestResults.xml')
Invoke-Pester -Configuration $config

Get-ChildItem -Path $binPath -Recurse -Filter '*.TestResults.xml' | ForEach-Object {
    Write-Host "Test results found: $($_.FullName)"
}