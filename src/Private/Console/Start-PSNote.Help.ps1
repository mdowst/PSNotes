function Write-PSNoteWelcome{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param()
$welcomeMessage = @"
PSNotes is your personal command-and-snippet vault.
Store the things you run all the time (or forget just often enough),
organize them with catalogs and tags, then quickly preview, copy, or run them.

HOW TO DRIVE THE UI
  • Bottom bar shortcuts: press Ctrl+[Key] (shown as ^Key), or type the Key and press Enter.
    Example: ^F (Ctrl+F) opens Favorites, or type F then press Enter.
  • Items shown in [square brackets] use Key + Enter.
    Example: [P] Preview means type P then press Enter.

SEARCH ANYTIME
  • Type a search term at any prompt and press Enter to search across your entire library.
  • Search works no matter what view you’re in (Favorites, Catalogs, Tags, etc.).

TIP
  • Use number selections (e.g. 1, 2, 3…) to open the item shown in the list.

HIDE THIS SCREEN
  • You can suppress this welcome message in the future
    by changing the Default Screen in Settings (Ctrl+O).
"@

Write-Host $welcomeMessage

}