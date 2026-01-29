Function Test-PSNotesInitalize{
    [CmdletBinding()]
    param()

    if([string]::IsNullOrEmpty($env:PSNOTES_HOME)){
        Write-Verbose '$env:PSNOTES_HOME is not set.'
        Initialize-PSNotes
    }
}