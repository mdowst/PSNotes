Get-Module PSNotes | Remove-Module -Force -ErrorAction SilentlyContinue
$Global:TopLevel = $PSScriptRoot
while ( -not (Test-Path (Join-Path $Global:TopLevel 'src'))) {
    $Global:TopLevel = Split-Path $Global:TopLevel -Parent
}
Describe 'Build Script Validation' {
    It 'build.ps1 runs without errors' {
        $buildScript = Join-Path $Global:TopLevel 'tools\build.ps1'
        $result = & $buildScript -Version '0.2.0.1'
        $LASTEXITCODE | Should -Be 0
    }

    It 'produces expected nupkg file' {
        $nupkgPath = Join-Path $Global:TopLevel 'bin' 'PSNotes.0.2.0.1.nupkg'
        Test-Path $nupkgPath | Should -BeTrue
    }

    It 'produces expected module files' {
        $psm1Path = Join-Path $Global:TopLevel 'bin' 'PSNotes' '0.2.0.1' 'PSNotes.psm1'
        $psd1Path = Join-Path $Global:TopLevel 'bin' 'PSNotes' '0.2.0.1' 'PSNotes.psd1'
        Test-Path $psm1Path | Should -BeTrue
        Test-Path $psd1Path | Should -BeTrue
    }

    It 'loads the module without errors' {
        $modulePath = Join-Path $Global:TopLevel 'bin' 'PSNotes' '0.2.0.1' 'PSNotes.psd1'
        Import-Module $modulePath -Force -ErrorAction Stop
        $mod = Get-Module PSNotes
        $mod | Should -Not -BeNullOrEmpty
        $mod.Version.ToString() | Should -Be '0.2.0.1'
    }

    It 'contains expected exported functions' {
        $expectedFunctions = @(
            'ConvertTo-Splatting',
            'Copy-PSNote',
            'Export-PSNote',
            'Get-CommandSplatting',
            'Get-PSNote',
            'Get-PSNoteAlias',
            'Import-PSNote',
            'Initialize-PSNoteStore',
            'New-PSNote',
            'Remove-PSNote',
            'Set-PSNote',
            'Start-PSNote'
        )
        $exportedFunctions = (Get-Command -Module PSNotes -CommandType Function).Name
        foreach ($func in $expectedFunctions) {
            $exportedFunctions | Should -Contain $func
        }
    }
}