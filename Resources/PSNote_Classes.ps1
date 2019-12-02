# Create the PSNote class
class PSNote {
    [string]$Note
	[string]$Snippet
	[string]$Details
    [string]$Alias
    [string[]]$Tags
    [string]$file

    PSNote(
        [string]$Note,
		[string]$Snippet,
		[string]$Details,
        [string]$Alias,
        [string[]]$Tags
    ){
        $this.Note = $Note
		$this.Snippet = $Snippet
		$this.Details = $Details
        $this.Alias = $Alias
        $this.Tags = $Tags
        $this.File = $script:UserPSNotesJsonFile

        if([string]::IsNullOrEmpty($Alias)){
            $this.Alias = $Note
        }
    }

    PSNote(
        [object]$object
    ){
        $this.Note = $object.Note
		$this.Snippet = $object.Snippet
		$this.Details = $object.Details
        $this.Alias = $object.Alias
        $this.Tags = $object.Tags
        $this.File = $object.File

        if([string]::IsNullOrEmpty($this.Alias)){
            $this.Alias = $object.Note
        }

    }
}

class PSNoteSearch {
    [string]$Note
	[string]$Snippet
	[string]$Details
    [string]$Alias
    [string[]]$Tags
    [string]$file

    PSNoteSearch(
        [object]$object
    ){
        $this.Note = $object.Note
		$this.Snippet = $object.Snippet
		$this.Details = $object.Details
        $this.Alias = $object.Alias
        $this.Tags = $object.Tags
        $this.File = $object.File

        if([string]::IsNullOrEmpty($this.Alias)){
            $this.Alias = $object.Note
        }

    }
}

class PSNoteExport {
    [string]$Note
	[string]$Snippet
	[string]$Details
    [string]$Alias
    [string[]]$Tags

    PSNoteExport(
        [object]$object
    ){
        $this.Note = $object.Note
		$this.Snippet = $object.Snippet
		$this.Details = $object.Details
        $this.Alias = $object.Alias
        $this.Tags = $object.Tags

        if([string]::IsNullOrEmpty($this.Alias)){
            $this.Alias = $object.Note
        }

    }
}