Describe 'PSSA' {
    $TopLevel = $PSScriptRoot
    while ( -not (Test-Path (Join-Path $TopLevel 'src'))) {
        $TopLevel = Split-Path $TopLevel -Parent
    }
    $TestPath = Join-Path $TopLevel 'tests'

    # Get the linter settings
    $ScriptAnalyzerSettings = Join-Path -Path $TestPath -ChildPath 'ScriptAnalyzer'
    $linterSettings = Get-ChildItem -Path $ScriptAnalyzerSettings -Filter '*.psd1' -Recurse | ForEach-Object {
        Import-PowerShellDataFile -Path $_.FullName
    }

    # Get the tests ran based on the linter settings
    $Severity = @('Error', 'Warning', 'Information')
    if ($linterSettings.Severity) {
        $Severity = $linterSettings.Severity | Select-Object -Unique
    }

    $TestParameters = Get-ScriptAnalyzerRule -Severity $Severity | Where-Object { $_.RuleName -notin $linterSettings.ExcludeRules } | ForEach-Object {
        @{Name = $_.RuleName }
    }

    # Run PSScriptAnalyzer Linter


    # Run Pester Tests
    Context 'ScriptAnalyzer Linter Tests' {
        BeforeAll {
            # Run PSScriptAnalyzer Linter
            $analysis = Get-ChildItem -Path $ScriptAnalyzerSettings -Filter '*.Linter.ps1' -Recurse | ForEach-Object {
                . $_.FullName
            }
        }
        It '<Name> has no rule violations' -ForEach $TestParameters {
            ($analysis | Where-Object { $_.RuleName -eq $Name }).Message | Select-Object -Unique | Should -BeNullOrEmpty
        }

        It 'has no rule violations' {
            $analysis.Count | Should -Be 0
        }
    }
}