Get-Module PSNotes | Remove-Module -Force -ErrorAction SilentlyContinue
$Global:TopLevel = $PSScriptRoot
while ( -not (Test-Path (Join-Path $Global:TopLevel 'src'))) {
    $Global:TopLevel = Split-Path $Global:TopLevel -Parent
}

BeforeAll {
    Set-StrictMode -Version Latest
    $psd1 = (Get-ChildItem -Path (Join-Path $Global:TopLevel 'bin') -Recurse -Filter 'PSNotes.psd1').FullName
    Import-Module $psd1 -Force
    $script:Version = [regex]::Match($psd1.ToLower(), '\\psnotes\\([0-9]+(?:\.[0-9]+)*)\\psnotes\.psd1').Groups[1].Value
}

Describe 'Build Script Validation' {
    It 'produces expected module files' {
        $psm1Path = Join-Path $Global:TopLevel 'bin' 'PSNotes' $script:Version 'PSNotes.psm1'
        $psd1Path = Join-Path $Global:TopLevel 'bin' 'PSNotes' $script:Version 'PSNotes.psd1'
        $formatPath = Join-Path $Global:TopLevel 'bin' 'PSNotes' $script:Version 'PSNotes.format.ps1xml'
        Test-Path $psm1Path | Should -BeTrue
        Test-Path $psd1Path | Should -BeTrue
        Test-Path $formatPath | Should -BeTrue
    }

    It 'loads the module without errors' {
        $modulePath = Join-Path $Global:TopLevel 'bin' 'PSNotes' $script:Version 'PSNotes.psd1'
        Import-Module $modulePath -Force -ErrorAction Stop
        $mod = Get-Module PSNotes
        $mod | Should -Not -BeNullOrEmpty
        $mod.Version.ToString() | Should -Be $script:Version
    }

    It 'contains expected exported functions' {
        $expectedFunctions = @(
            'Export-PSNote',
            'Get-PSNote',
            'Get-PSNoteAlias',
            'Get-PSNoteMenu',
            'Import-PSNote',
            'Initialize-PSNoteStore',
            'Move-PSNote',
            'New-PSNote',
            'Remove-PSNote',
            'Set-PSNote',
            'Update-PSNoteStore',
            'Get-RemoteCatalog',
            'Import-RemoteCatalog',
            'Remove-RemoteCatalog',
            'ConvertTo-Splatting',
            'Get-CommandSplatting'
        )
        $exportedFunctions = (Get-Command -Module PSNotes -CommandType Function).Name
        foreach ($func in $expectedFunctions) {
            $exportedFunctions | Should -Contain $func
        }
        foreach ($func in $exportedFunctions) {
            $expectedFunctions | Should -Contain $func
        }
    }
}