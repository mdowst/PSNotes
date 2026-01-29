Function Initialize-PSNotesRemoteJsonFile{

    # Create PSNote.json in %APPDATA%\PSNotes to save users local settings
    if(-not (Test-Path $env:PSNotesRemoteJsonFile)){
        Out-File $env:PSNotesRemoteJsonFile -Encoding UTF8
    }

    # Sync the remote JSON files
    $uri = 'https://gist.githubusercontent.com/mdowst/7198756f760ad0de0f635aaef5c4d338/raw/aa078383267e1d1613169e1a42f5c35ab70ffa7d/RemotePSNote.json'

    $outFile = Join-Path $env:PSNOTES_HOME (Split-Path $uri -Leaf)
    if([System.IO.Path]::GetExtension($outFile) -ne '.json'){
        $outFile += '.json'
    }

    try{
        Invoke-WebRequest -Uri $uri -OutFile $outFile -ErrorAction Stop
    }
    catch{
        # TODO: Write custom error message
    } 
    $download
}