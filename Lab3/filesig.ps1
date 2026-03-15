$sigs = Import-Csv siglist.txt -Delimiter ";" -Header Type,Header,Footer
$files = Get-ChildItem "C:\tmp\ps\" -Recurse -File

foreach ($file in $files) {

    $bytes = Get-Content $file.FullName -Encoding Byte -TotalCount 8
    $hex = ($bytes | ForEach-Object { $_.ToString("X2") }) -join ""

    $foundType = "UNKNOWN"

    foreach ($sig in $sigs) {
        if ($hex.StartsWith($sig.Header)) {
            $foundType = $sig.Type
        }
    }

    $ext = $file.Extension.TrimStart(".").ToUpper()

    if ($ext -eq $foundType) {
        $status = "VALID"
    }
    else {
        $status = "ROGUE"
    }

    $hash = Get-FileHash $file.FullName -Algorithm SHA256

    Write-Host "File: $($file.FullName) is a $status $foundType file! SHA256Hash: $($hash.Hash)"
}