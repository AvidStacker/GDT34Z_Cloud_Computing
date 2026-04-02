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

# --- FIX: Extension mapping ---
$extensionMap = @{
    "JPG"  = "JPEG"
    "JPEG" = "JPEG"
    "EXE"  = "PE"
    "DLL"  = "PE"
    "PDF"  = "PDF"
    "ZIP"  = "ZIP"
    "DB3"  = "DB3"
}

# Target directory
$targetPath = "C:\tmp\ps"

Write-Output "Searching recursively for file signatures in: $targetPath"

$files = Get-ChildItem $targetPath -Recurse -File

foreach ($file in $files) {

    try {
        $stream = [System.IO.File]::OpenRead($file.FullName)

        # --- FIX: hantera små filer ---
        $length = $stream.Length

        $headerBytes = New-Object byte[] ([Math]::Min(8, $length))
        $stream.Read($headerBytes, 0, $headerBytes.Length) | Out-Null

        $footerBytes = New-Object byte[] ([Math]::Min(8, $length))
        $stream.Seek(-$footerBytes.Length, 'End') | Out-Null
        $stream.Read($footerBytes, 0, $footerBytes.Length) | Out-Null

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

            # --- FIX: använd mapping ---
            if ($extensionMap.ContainsKey($extension)) {
                $expectedType = $extensionMap[$extension]
            } else {
                $expectedType = $extension
            }

            if ($match -eq $expectedType) {
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