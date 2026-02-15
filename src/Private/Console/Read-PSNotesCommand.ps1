function Read-PSNotesCommand {
    <#
      Reads input like a tiny line editor, BUT fires Ctrl+Letter immediately.

      Returns:
        - '^N' for Ctrl+N (etc)
        - 'ESC' for Escape
        - Otherwise: the typed line when Enter is pressed (may be empty)
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param(
        [string] $Prompt = 'PSNotes',
        [int] $PromptRow = -1,       # -1 means "bottom line"
        [switch] $Echo               # if set, it will display typed characters
    )

    $buffer = [System.Text.StringBuilder]::new()

    # Pick a row (bottom line by default)
    $row = if ($PromptRow -ge 0) { $PromptRow } else { [Console]::WindowHeight - 2 }
    #$colPrompt = 0

    function Write-Prompt {
        param(
            [string] $text,
            [string] $Prompt
        )
        $width = [Console]::WindowWidth
        [Console]::SetCursorPosition(0, $row)

        $line = "{0}: {1}" -f $Prompt, $text
        if ($line.Length -gt $width) { $line = $line.Substring(0, $width) }

        # Clear line and redraw
        Write-Host ($line.PadRight($width)) -NoNewline
        # Put cursor at end of typed text
        $cursorCol = [Math]::Min($width - 1, ("$($Prompt): ").Length + $text.Length)
        [Console]::SetCursorPosition($cursorCol, $row)
    }

    if ($Echo) { Write-Prompt -text '' -Prompt $Prompt }

    while ($true) {
        $key = [Console]::ReadKey($true)

        # Ctrl+<letter> => return token immediately
        if ($key.Modifiers -band [ConsoleModifiers]::Control) {
            # normalize to uppercase letter keys
            if ($key.Key -match '^[A-Z]$') {
                return '^' + $key.Key.ToString().ToUpperInvariant()
            }
            continue
        }

        switch ($key.Key) {
            'Enter' {
                $text = $buffer.ToString()
                if ($Echo) { Write-Prompt -text $text -Prompt $Prompt; Write-Host "" }
                return $text
            }
            'Escape' { return 'ESC' }
            'Backspace' {
                if ($buffer.Length -gt 0) {
                    [void]$buffer.Remove($buffer.Length - 1, 1)
                    if ($Echo) { Write-Prompt -text $buffer.ToString() -Prompt $Prompt }
                }
            }
            default {
                # Only add printable chars
                if ($key.KeyChar -and -not [char]::IsControl($key.KeyChar)) {
                    [void]$buffer.Append($key.KeyChar)
                    if ($Echo) { Write-Prompt -text $buffer.ToString() -Prompt $Prompt }
                }
            }
        }
    }
}