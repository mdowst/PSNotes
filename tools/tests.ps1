$TestPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'tests'
$binPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'bin'
if(-not (Test-Path $binPath)){
   New-Item -ItemType Directory -Force -Path $binPath | Out-Null
}

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