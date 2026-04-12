param(
    [string]$ScanPath = ".\ps",
    [string]$SigFile = ".\siglist.txt"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Labels
$labelOK   = "[OK]"
$labelBad  = "[BAD]"
$labelWarn = "[WARN]"
$labelInfo = "[INFO]"

# --- Resolve paths smart ---
if (-not (Test-Path $ScanPath)) {
    Write-Host "$labelInfo Default path '$ScanPath' not found, using current directory instead." -ForegroundColor Yellow
    $ScanPath = "."
}

if (-not (Test-Path $SigFile)) {
    throw "Signature file missing: $SigFile"
}

# --- Convert hex string to byte array ---
function Convert-Hex {
    param([string]$Value)

    $clean = ($Value -replace '\s+', '').Trim().ToUpper()

    if ([string]::IsNullOrWhiteSpace($clean)) {
        return [byte[]]@()
    }

    if (($clean.Length % 2) -ne 0) {
        throw "Invalid hex format: $clean"
    }

    $buffer = New-Object byte[] ($clean.Length / 2)

    for ($i = 0; $i -lt $clean.Length; $i += 2) {
        $buffer[$i / 2] = [Convert]::ToByte($clean.Substring($i, 2), 16)
    }

    return $buffer
}

# --- Compare prefix ---
function Match-Prefix {
    param($Data, $Expected)

    if (-not $Expected -or $Expected.Count -eq 0) { return $true }
    if (-not $Data -or $Data.Count -lt $Expected.Count) { return $false }

    for ($i = 0; $i -lt $Expected.Count; $i++) {
        if ($Data[$i] -ne $Expected[$i]) { return $false }
    }

    return $true
}

# --- Compare suffix ---
function Match-Suffix {
    param($Data, $Expected)

    if (-not $Expected -or $Expected.Count -eq 0) { return $true }
    if (-not $Data -or $Data.Count -lt $Expected.Count) { return $false }

    $offset = $Data.Count - $Expected.Count

    for ($i = 0; $i -lt $Expected.Count; $i++) {
        if ($Data[$offset + $i] -ne $Expected[$i]) { return $false }
    }

    return $true
}

# --- Read file head + tail ---
function Read-Edges {
    param(
        [string]$FilePath,
        [int]$HeadSize,
        [int]$TailSize
    )

    $fileInfo = Get-Item -LiteralPath $FilePath
    $length = $fileInfo.Length

    $stream = [System.IO.File]::OpenRead($FilePath)

    try {
        $headSize = [Math]::Min($HeadSize, [int]$length)
        $tailSize = [Math]::Min($TailSize, [int]$length)

        $head = New-Object byte[] $headSize
        [void]$stream.Read($head, 0, $headSize)

        $tail = New-Object byte[] $tailSize
        $stream.Seek(-1 * $tailSize, 'End') | Out-Null
        [void]$stream.Read($tail, 0, $tailSize)

        return @{
            Head = $head
            Tail = $tail
        }
    }
    finally {
        $stream.Dispose()
    }
}

# --- Load signatures ---
function Load-Signatures {
    param([string]$Path)

    $list = @()

    foreach ($line in Get-Content -LiteralPath $Path) {

        $row = $line.Trim()

        if (-not $row -or $row.StartsWith("#")) { continue }

        $parts = $row -split ';', 3
        if ($parts.Count -lt 2) { continue }

        $type = $parts[0].Trim().ToUpper()
        $header = ($parts[1] -replace ';','').Trim()
        $footer = if ($parts.Count -ge 3) { ($parts[2] -replace ';','').Trim() } else { "" }

        if (-not $type -or -not $header) { continue }

        $list += [pscustomobject]@{
            Type   = $type
            Header = Convert-Hex $header
            Footer = Convert-Hex $footer
        }
    }

    return $list
}

# --- Extension mapping ---
function Resolve-ExpectedType {
    param([string]$Ext)

    $e = $Ext.TrimStart('.').ToUpper()

    $map = @{
        EXE = "PE"; DLL = "PE"; SYS = "PE"; SCR = "PE"
        JPG = "JPEG"; JPEG = "JPEG"; JPE = "JPEG"
    }

    if ($map.ContainsKey($e)) {
        return @($map[$e])
    }

    return @($e)
}

# --- Detect file type ---
function Detect-Type {
    param($Head, $Tail, $Signatures)

    foreach ($sig in $Signatures) {
        if ((Match-Prefix $Head $sig.Header) -and
            (Match-Suffix $Tail $sig.Footer)) {
            return $sig.Type
        }
    }

    return $null
}

# --- Safe length ---
function Get-Len {
    param($Arr)
    if ($Arr -is [System.Array]) { return $Arr.Length }
    return 0
}

# --- Load signatures ---
$signatures = Load-Signatures $SigFile

if (-not $signatures -or $signatures.Count -eq 0) {
    throw "No valid signatures found in $SigFile"
}

$maxHead = ($signatures | ForEach-Object { Get-Len $_.Header } | Measure-Object -Maximum).Maximum
$maxTail = ($signatures | ForEach-Object { Get-Len $_.Footer } | Measure-Object -Maximum).Maximum

if ($null -eq $maxHead) { $maxHead = 0 }
if ($null -eq $maxTail) { $maxTail = 0 }

$valid = 0; $rogue = 0; $unknown = 0; $total = 0

Write-Host "`n==== File Signature Scan ====" -ForegroundColor Cyan
Write-Host "$labelInfo Path: $(Resolve-Path $ScanPath)" -ForegroundColor Cyan

Get-ChildItem -LiteralPath $ScanPath -File -Recurse | ForEach-Object {

    $file = $_
    $total++

    $hash = (Get-FileHash $file.FullName -Algorithm SHA256).Hash
    $bytes = Read-Edges $file.FullName $maxHead $maxTail

    $detected = Detect-Type $bytes.Head $bytes.Tail $signatures
    $expected = Resolve-ExpectedType $file.Extension

    if (-not $detected) {
        $unknown++
        Write-Host "$labelWarn File: $($file.FullName)" -ForegroundColor Yellow
        Write-Host "      Status       :  NOT PRESENT IN FILE SIGNATURE LIST!"
        Write-Host "      SHA256Hash   :  $hash"
    }
    elseif ($expected -contains $detected) {
        $valid++
        Write-Host "$labelOK File: $($file.FullName)" -ForegroundColor Green
        Write-Host "      Status       :  VALID $detected file!"
        Write-Host "      SHA256Hash   :  $hash"
    }
    else {
        $rogue++
        Write-Host "$labelBad File: $($file.FullName)" -ForegroundColor Red
        Write-Host "      Status       :  ROGUE $detected file!"
        Write-Host "      SHA256Hash   :  $hash"
    }
}

Write-Host "=============================================" -ForegroundColor DarkCyan
Write-Host "                 Summary" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor DarkCyan
Write-Host "Total files scanned : $total"
Write-Host "Valid files         : $valid"
Write-Host "Rogue files         : $rogue"
Write-Host "Unknown files       : $unknown"
Write-Host ""
