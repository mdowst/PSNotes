Function Update-PSNotesJsonFile{
    [cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    param()
    if(-not (Test-Path (Split-Path $UserPSNotesJsonFile))){
        New-Item -type directory -Path $(Split-Path $UserPSNotesJsonFile) | Out-Null
    }

    $noteObjects | Where-Object {$_.file -eq $UserPSNotesJsonFile} | 
        Select-Object -Property Note, Alias, Details, Tags, Snippet | ConvertTo-Json | Out-File $UserPSNotesJsonFile
}