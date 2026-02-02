function Write-PSNotePreview {
    param($Note)

    Write-Host ""
    Write-Host "Alias: $($Note.Alias)" -ForegroundColor Cyan
    Write-Host "Tags : $($Note.Tags -join ', ')" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host $Note.Snippet -ForegroundColor White
}