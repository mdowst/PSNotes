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