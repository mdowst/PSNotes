# Create a backup of your config so you don't lose anything during testing
$Timestamp = $((Get-Date).ToFileTime())
$UserFolder = Join-Path $env:APPDATA 'PSNotes'
$backupFolder = Join-Path $UserFolder $Timestamp
if(-not (Test-Path $backupFolder)){
    New-Item -ItemType Directory -Path $backupFolder | Out-Null
}
Get-ChildItem -LiteralPath (Join-Path $env:APPDATA '\PSNotes\') -Filter "*.json" | Copy-Item -Destination $backupFolder -Force -ErrorAction Stop
Get-ChildItem -LiteralPath (Join-Path $env:APPDATA '\PSNotes\') -Filter "*.json" | Remove-Item -Force

# create a new PSNotes.json to use for testing purposes
$UserJson = Join-Path $UserFolder 'PSNotes.json'
$mockJson = '[{"Note":"Date","Alias":"today","Details":"Get todays date","Tags":["date"],"Snippet":"Get-Date 01/01/2001","File":"' + $UserJson.Replace('\','\\') + '"}]'
$mockJson | Out-File $UserJson

Get-Module PSNotes | Remove-Module
Import-Module (Join-Path $PSScriptRoot "PSNotes.psd1")

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
        Get-PSNote -Note 'Date' | Out-String | Should -BeLike "`r`n----------------------------------------`r`n`r`nNote    : Date`r`nDetails : Get todays date`r`nAlias   : today`r`nSnippet :`r`n`r`nGet-Date 01/01/2001`r`n*"
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
        New-PSNote -Note 'ADTester' -Snippet 'Get-AdUser tester' -Details "Use to return all AD users" -Tags 'AD','Users'
        $UserJson | Should -FileContentMatch '"Note":\s+"ADTester",' 
        $UserJson | Should -FileContentMatch '"Alias":\s+"ADTester",'
        $UserJson | Should -FileContentMatch '"Details":\s+"Use\ to\ return\ all\ AD\ users",'
        $UserJson | Should -FileContentMatch '"Snippet":\s+"Get-AdUser\ tester"'
        ADTester | Should -Be 'Get-AdUser tester'
    }
    $TestDateValue = Get-Date 1/1/2001
    It "Test Adding Note with ScriptBlock" {
        New-PSNote -Note "SBTester" -ScriptBlock {Get-Date 1/1/2001} -Details "Testing Script Block" -Tags 'Date' -Alias 'TestDate'
        $UserJson | Should -FileContentMatch '"Note":\s+"SBTester",' 
        $UserJson | Should -FileContentMatch '"Alias":\s+"TestDate",'
        $UserJson | Should -FileContentMatch '"Details":\s+"Testing\ Script\ Block",'
        $UserJson | Should -FileContentMatch '"Snippet":\s+"Get-Date\ 1/1/2001"'
        TestDate | Should -Be 'Get-Date 1/1/2001'
        TestDate -run | Should -Be $TestDateValue
    }

    It "Test New Alias" {
        New-PSNote -Note 'ADTester' -Alias 'TestUser' -Force
        $UserJson | Should -FileContentMatch '"Note":\s+"ADTester",' 
        $UserJson | Should -FileContentMatch '"Alias":\s+"TestUser",'
        $UserJson | Should -FileContentMatch '"Details":\s+"Use\ to\ return\ all\ AD\ users",'
        $UserJson | Should -FileContentMatch '"Snippet":\s+"Get-AdUser\ tester"'
        TestUser | Should -Be 'Get-AdUser tester'
    }

    It "Test New without Force" {
        {New-PSNote -Note 'ADTester' -Alias 'NoForce' -ErrorAction Stop} | Should -Throw "The note 'ADTester' already exists. Use -force to overwrite existing properties"
        $UserJson | Should -FileContentMatch '"Note":\s+"ADTester",' 
        $UserJson | Should -FileContentMatch '"Alias":\s+"TestUser",'
        $UserJson | Should -FileContentMatch '"Details":\s+"Use\ to\ return\ all\ AD\ users",'
        $UserJson | Should -FileContentMatch '"Snippet":\s+"Get-AdUser\ tester"'
        TestUser | Should -Be 'Get-AdUser tester'
    }
}

Describe 'Set-PSNote' {

    It "Test Set Alias" {
        Set-PSNote -Note 'ADTester' -Alias 'SetTest'
        $UserJson | Should -FileContentMatch '"Note":\s+"ADTester",' 
        $UserJson | Should -FileContentMatch '"Alias":\s+"SetTest",'
        $UserJson | Should -FileContentMatch '"Details":\s+"Use\ to\ return\ all\ AD\ users",'
        $UserJson | Should -FileContentMatch '"Snippet":\s+"Get-AdUser\ tester"'
        SetTest | Should -Be 'Get-AdUser tester'
    }

    It "Test Set Details" {
        Set-PSNote -Note 'ADTester' -Details "Pester Tester"
        $UserJson | Should -FileContentMatch '"Note":\s+"ADTester",' 
        $UserJson | Should -FileContentMatch '"Alias":\s+"SetTest",'
        $UserJson | Should -FileContentMatch '"Details":\s+"Pester\ Tester",'
        $UserJson | Should -FileContentMatch '"Snippet":\s+"Get-AdUser\ tester"'
        SetTest | Should -Be 'Get-AdUser tester'
    }

    $TestDateValue = Get-Date 12/31/2001
    It "Test Set Note with ScriptBlock" {
        Set-PSNote -Note "SBTester" -ScriptBlock {Get-Date 12/31/2001}
        $UserJson | Should -FileContentMatch '"Note":\s+"SBTester",' 
        $UserJson | Should -FileContentMatch '"Alias":\s+"TestDate",'
        $UserJson | Should -FileContentMatch '"Details":\s+"Testing\ Script\ Block",'
        $UserJson | Should -FileContentMatch '"Snippet":\s+"Get-Date\ 12/31/2001"'
        TestDate | Should -Be 'Get-Date 12/31/2001'
        TestDate -run | Should -Be $TestDateValue
    }

    $TestDateValue = Get-Date 7/4/2001
    It "Test Set Note with Snippet" {
        Set-PSNote -Note "SBTester" -Snippet 'Get-Date 7/4/2001'
        $UserJson | Should -FileContentMatch '"Note":\s+"SBTester",' 
        $UserJson | Should -FileContentMatch '"Alias":\s+"TestDate",'
        $UserJson | Should -FileContentMatch '"Details":\s+"Testing\ Script\ Block",'
        $UserJson | Should -FileContentMatch '"Snippet":\s+"Get-Date\ 7/4/2001"'
        TestDate | Should -Be 'Get-Date 7/4/2001'
        TestDate -run | Should -Be $TestDateValue
    }
}


Get-ChildItem -LiteralPath $backupFolder -Filter "*.json" | Copy-Item -Destination $UserFolder -Force -ErrorAction Stop -PassThru
