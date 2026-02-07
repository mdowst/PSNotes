$Parent = $PSScriptRoot
while ( -not (Test-Path (Join-Path $Parent 'src'))) {
    $Parent = Split-Path $Parent -Parent
}

$TestPath = Join-Path $Parent 'tests'
$binPath = Join-Path $Parent 'bin'
if(-not (Test-Path $binPath)){
   New-Item -ItemType Directory -Force -Path $binPath | Out-Null
}

. "$Parent\tools\build.ps1" -Version '0.9.9.9'
Get-Module PSNotes | Remove-Module -Force

# Run Unit Tests
$config = New-PesterConfiguration
$config.Output.Verbosity = 'Detailed'
$config.Run.Path = (Join-Path $TestPath 'UnitTests')
$config.Run.Throw = $false
$config.TestResult.Enabled = $true
$config.TestResult.OutputFormat = 'NUnitXml'
$config.TestResult.OutputPath   = (Join-Path $binPath 'Pester.TestResults.xml')
Invoke-Pester -Configuration $config

# Run Script Analyzer Tests
$config.Run.Path = (Join-Path $TestPath 'ScriptAnalyzer')
$config.TestResult.OutputPath   = (Join-Path $binPath 'ScriptAnalyzer.TestResults.xml')
Invoke-Pester -Configuration $config

# Run Build Tests
$config.Run.Path = (Join-Path $TestPath 'Build')
$config.TestResult.OutputPath   = (Join-Path $binPath 'Build.TestResults.xml')
Invoke-Pester -Configuration $config