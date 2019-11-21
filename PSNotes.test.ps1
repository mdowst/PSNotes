$UserJson = Join-Path $env:APPDATA '\PSNotes\PSNotes.json'
Copy-Item -LiteralPath $UserJson -Destination "$UserJson.testbak" 
$mockJson = '[{"Note":"Date","Alias":"today","Details":"Get todays date","Tags":["date"],"Snippet":"Get-Date 01/01/2001","File":' + ($UserJson | ConvertTo-Json) + '}]'
$mockJson | Out-File $UserJson

#Get-Content $UserJson -Raw | ConvertFrom-Json $UserJson | ConvertTo-Json -Compress

Get-Module PSNotes | Remove-Module
Import-Module (Join-Path $PSScriptRoot "PSNotes.psd1")

$Timestamp = "Test_$((Get-Date).ToFileTime())"


Describe 'Get-PSNote' {

    $mockPSNote = ConvertFrom-Json $mockJson

    It "Get Single Note" {
        $testNote = Get-PSNote -Note 'Date'
        $testNote.Note | Should -Be $mockPSNote.Note
        $testNote.Snippet | Should -Be $mockPSNote.Snippet
        $testNote.Details | Should -Be $mockPSNote.Details
        $testNote.Alias | Should -Be $mockPSNote.Alias
        $testNote.Tags | Should -Be $mockPSNote.Tags
        $testNote.file | Should -Be $mockPSNote.file
    }

    It "Output Style Check" {
        Get-PSNote -Note 'Date' | Out-String | Should -Be "`r`nAlias   : today`r`nSnippet :`r`n-------`r`nGet-Date 01/01/2001`r`n-------`r`n`r`n`r`n"
    }

    It "Test Run Parameter" {
        Get-PSNote -Note 'Date' -Run | Should -Be $(Get-Date 01/01/2001)
    }
}

Describe 'Get-PSNoteAlias' {

    It "Test Alias" {
        today | Should -Be 'Get-Date 01/01/2001'
    }

    It "Test Alias Run" {
        today -run | Should -Be $(Get-Date 01/01/2001)
    }

    It "Test Direct Call" {
        {Get-PSNoteAlias -ErrorAction Stop} | Should -Throw 'The Get-PSNoteAlias cmdlet is designed to be called using an alias and not directly.'
    }

}

Describe 'New-PSNote' {

    It "Test Adding Note" {
        New-PSNote -Note $Timestamp -Snippet 'Get-AdUser tester' -Details "Use to return all AD users" -Tags 'AD','Users'
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Note"": ""$Timestamp"","))
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Alias"": ""$Timestamp"","))
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Details"": ""Use to return all AD users"","))
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Snippet"": ""Get-AdUser tester"""))
    }

    It "Test New Alias" {
        New-PSNote -Note $Timestamp -Alias 'TestUser' -Force
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Note"": ""$Timestamp"","))
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Alias"": ""TestUser"","))
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Details"": ""Use to return all AD users"","))
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Snippet"": ""Get-AdUser tester"""))
    }

    It "Test New without Force" {
        {New-PSNote -Note $Timestamp -Alias 'NoForce' -ErrorAction Stop} | Should -Throw "The note '$Timestamp' already exists. Use -force to overwrite existing properties"
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Note"": ""$Timestamp"","))
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Alias"": ""TestUser"","))
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Details"": ""Use to return all AD users"","))
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Snippet"": ""Get-AdUser tester"""))
    }
}

Describe 'Set-PSNote' {

    It "Test Set Alias" {
        Set-PSNote -Note $Timestamp -Alias 'NoForce'
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Note"": ""$Timestamp"","))
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Alias"": ""NoForce"","))
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Details"": ""Use to return all AD users"","))
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Snippet"": ""Get-AdUser tester"""))
    }

    It "Test Set Details" {
        Set-PSNote -Note $Timestamp -Details "Pester Tester"
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Note"": ""$Timestamp"","))
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Alias"": ""NoForce"","))
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Details"": ""Pester Tester"","))
        $UserJson | Should -FileContentMatch ([regex]::Escape("""Snippet"": ""Get-AdUser tester"""))
    }
}

Copy-Item -LiteralPath "$UserJson.testbak" -Destination $UserJson -Force
Remove-Item "$UserJson.testbak" -Force
