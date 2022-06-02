BeforeAll {
    $global:IsPesterTest = $true
    Import-Module .\PSNotes.psd1 -Force
}

Describe 'Get-PSNote' {
    BeforeAll {
        $PesterJson = Join-Path $env:TEMP "Pester.Test.json"
        $mockJson = '[{"Note":"Date_Tester","Alias":"t_today","Details":"Get todays date","Tags":["date"],"Snippet":"Get-Date 01/01/2001"}]'
        $mockJson | Out-File $PesterJson
        Import-PSNote -Path $PesterJson -Catalog 'Pester'
    }

    It "Get Single Note" {
        $testNote = Get-PSNote -Note 'Date_Tester'
        $testNote.Note | Should -Be 'Date_Tester'
        $testNote.Snippet | Should -Be 'Get-Date 01/01/2001'
        $testNote.Details | Should -Be 'Get todays date'
        $testNote.Alias | Should -Be 't_today'
        $testNote.Tags | Should -Be 'date'
        $testNote.file | Should -BeLike '*\PSNotes\Pester\Pester.json'
    }

    It "Output Style Check" {
        Get-PSNote -Note 'Date_Tester' | Out-String | Should -Be "`r`n----------------------------------------`r`n`r`nNote    : Date_Tester`r`nDetails : Get todays date`r`nAlias   : t_today`r`nSnippet :`r`n`r`nGet-Date 01/01/2001`r`n`r`n`r`n`r`n"
    }

    It "Test Run Parameter" {
        Get-PSNote -Note 'Date_Tester' -Run | Should -Be $(Get-Date 01/01/2001)
    }
}

Describe 'Get-PSNoteAlias' {
    
    It "Test Alias" {
        t_today | Should -Be 'Get-Date 01/01/2001'
    }

    It "Test Alias Run" {
        t_today -run | Should -Be $(Get-Date 01/01/2001)
    }

    It "Test Direct Call" {
        {Get-PSNoteAlias -ErrorAction Stop} | Should -Throw 'The Get-PSNoteAlias cmdlet is designed to be called using an alias and not directly.'
    }

}

Describe 'New-PSNote' {

    It "Test Adding Note" {
        New-PSNote -Note 'ADTester' -Snippet 'Get-AdUser tester' -Details "Use to return all AD users" -Tags 'AD','Users'
        ADTester | Should -Be 'Get-AdUser tester'
    }

    It "Test Adding Note with ScriptBlock" {
        New-PSNote -Note "SBTester" -ScriptBlock {Get-Date 1/1/2001} -Details "Testing Script Block" -Tags 'Date' -Alias 'TestDate'
        TestDate | Should -Be 'Get-Date 1/1/2001'
        TestDate -run | Should -Be $(Get-Date 1/1/2001)
    }

    It "Test New Alias" {
        New-PSNote -Note 'ADTester' -Alias 'TestUser' -Force
        TestUser | Should -Be 'Get-AdUser tester'
    }

    It "Test New without Force" {
        {New-PSNote -Note 'ADTester' -Alias 'NoForce' -ErrorAction Stop} | Should -Throw "The note 'ADTester' already exists. Use -force to overwrite existing properties"
        TestUser | Should -Be 'Get-AdUser tester'
    }

}

Describe 'Set-PSNote' {

    It "Test Set Alias" {
        Set-PSNote -Note 'ADTester' -Alias 'SetTest'
        SetTest | Should -Be 'Get-AdUser tester'
    }

    It "Test Set Details" {
        Set-PSNote -Note 'ADTester' -Details "Pester Tester"
        SetTest | Should -Be 'Get-AdUser tester'
    }

    It "Test Set Note with ScriptBlock" {
        Set-PSNote -Note "SBTester" -ScriptBlock {Get-Date 12/31/2001}
        TestDate | Should -Be 'Get-Date 12/31/2001'
        TestDate -run | Should -Be $(Get-Date 12/31/2001)
    }

    It "Test Set Note with Snippet" {
        Set-PSNote -Note "SBTester" -Snippet 'Get-Date 7/4/2001'
        TestDate | Should -Be 'Get-Date 7/4/2001'
        TestDate -run | Should -Be $(Get-Date 7/4/2001)
    }
}

