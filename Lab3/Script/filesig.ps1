# Load signatures
$siglist = @{}
$sigFile = "$PSScriptRoot\siglist.txt"

Get-Content $sigFile | ForEach-Object {
    $parts = $_ -split ";"
    if ($parts.Length -ge 2) {
        $type = $parts[0].ToUpper()
        $header = $parts[1]
        $footer = $parts[2]

        $siglist[$type] = @{
            Header = $header
            Footer = $footer
        }
    }
}

# Target directory
$targetPath = "C:\tmp\ps"

Write-Output "Searching recursively for file signatures in: $targetPath"

$files = Get-ChildItem $targetPath -Recurse -File

foreach ($file in $files) {

    try {
        # Open file stream
        $stream = [System.IO.File]::OpenRead($file.FullName)

        # Read first bytes (header)
        $headerBytes = New-Object byte[] 8
        $stream.Read($headerBytes, 0, 8) | Out-Null

        # Read last bytes (footer)
        $footerBytes = New-Object byte[] 8
        $stream.Seek(-8, 'End') | Out-Null
        $stream.Read($footerBytes, 0, 8) | Out-Null

        $stream.Close()

        # Convert to hex
        $headerHex = ($headerBytes | ForEach-Object { $_.ToString("X2") }) -join ""
        $footerHex = ($footerBytes | ForEach-Object { $_.ToString("X2") }) -join ""

        $match = $null

        foreach ($type in $siglist.Keys) {
            $header = $siglist[$type].Header
            $footer = $siglist[$type].Footer

            if ($headerHex.StartsWith($header)) {
                if ($footer -and $footerHex.EndsWith($footer)) {
                    $match = $type
                    break
                }
                elseif (-not $footer) {
                    $match = $type
                    break
                }
            }
        }

        $extension = $file.Extension.TrimStart(".").ToUpper()
        $hash = Get-FileHash $file.FullName -Algorithm SHA256

        if ($match) {
            if ($match -eq $extension) {
                Write-Output "File: $($file.FullName) is a VALID $match file! SHA256Hash: $($hash.Hash)"
            }
            else {
                Write-Output "File: $($file.FullName) is a ROGUE $match file! SHA256Hash: $($hash.Hash)"
            }
        }
        else {
            Write-Output "File: $($file.FullName) is NOT PRESENT IN FILE SIGNATURE LIST! SHA256Hash: $($hash.Hash)"
        }
    }
    catch {
        Write-Output "Error reading file: $($file.FullName)"
    }
}