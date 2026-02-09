class SplatBlock {
    [string]$Command
    [string]$ParameterSet
	[Boolean]$IsDefault
	[string]$HashBlock
    [string]$SetBlock

    SplatBlock(
        [object]$object
    ){
        $this.Command = $object.Command
		$this.IsDefault = $object.IsDefault
		$this.HashBlock = $object.HashBlock
        $this.SetBlock = $object.SetBlock
    }
}