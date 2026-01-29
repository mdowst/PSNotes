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