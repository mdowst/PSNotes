Function Update-PSNotesJsonFile{
    [cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    param()
    if(-not (Test-Path (Split-Path $script:_UserPSNotesJsonFile))){
        New-Item -type directory -Path $(Split-Path $script:_UserPSNotesJsonFile) | Out-Null
    }

    $script:_noteObjects | Where-Object {$_.file -eq $script:_UserPSNotesJsonFile} | 
        Select-Object -Property Note, Alias, Details, Tags, Snippet | ConvertTo-Json | Out-File $script:_UserPSNotesJsonFile
}