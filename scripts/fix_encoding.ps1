# Fix common UTF-8 mojibake sequences in index.html
$ErrorActionPreference = 'Stop'

$root = "c:\Users\user\Downloads\portfolio"
$indexPath = Join-Path $root "index.html"
if (-not (Test-Path $indexPath)) { throw "index.html not found" }

# Backup
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
Copy-Item $indexPath (Join-Path $root ("index.encodingfix." + $timestamp + ".html")) -Force

# Read
$c = Get-Content -Raw -Path $indexPath

# Replace problematic sequences with ASCII equivalents
$c = $c -replace 'Ã¢â‚¬â„¢', "'"
$c = $c -replace 'Ã¢â‚¬â€œ', "-"

# Write back
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($indexPath, $c, $utf8NoBom)

Write-Host "index.html encoding artifacts fixed."
