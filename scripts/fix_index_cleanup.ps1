# Clean up index.html: remove escaped quotes, fix nested scripts, normalize characters, and align navbar brand
$ErrorActionPreference = 'Stop'

$root = "c:\Users\user\Downloads\portfolio"
$indexPath = Join-Path $root "index.html"

if (-not (Test-Path $indexPath)) { throw "index.html not found" }

# Backup current
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
Copy-Item $indexPath (Join-Path $root "index.cleanup.$timestamp.html") -Force

# Read
$content = Get-Content -Raw -Path $indexPath

# 1) Remove backslash-escaped quotes introduced into HTML
$content = $content -replace '\\"','"'

# 2) Remove stray <script> tag inserted before theme IIFE (keep code inside same block)
$content = [regex]::Replace($content, '(?m)^\s*<script>\s*(?=\(function\(\)\s*\{)', '')

# 3) Fix double closing </script></script></body>
$content = [regex]::Replace($content, '(?s)</script>\s*</script>\s*</body>', '</script></body>')

# 4) Split inline style and </head> onto separate lines for readability
$content = $content -replace '</style></head>', "</style>`r`n</head>"

# 5) Navbar brand: align to Isaac Tairo (change visible text only)
$content = [regex]::Replace($content, '(<a class="navbar-brand[^"]*"[^>]*>)[^<]+(</a>)', '$1Isaac Tairo$2')

# 6) Normalize common mojibake to proper UTF-8 characters
$map = @{
  'â€”' = '—';
  'â€“' = '–';
  'â€˜' = '‘';
  'â€™' = '’';
  'â€œ' = '“';
  'â€�' = '”';
  'Â©' = '©';
  'â¤ï¸' = '❤️';
  'Letâ€™s' = 'Let’s';
  'Donâ€™t' = 'Don’t'
}
foreach ($k in $map.Keys) { $content = $content -replace [regex]::Escape($k), $map[$k] }

# 7) Ensure preconnect links are properly quoted (already handled by step 1)

# 8) Write back as UTF-8 without BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($indexPath, $content, $utf8NoBom)

Write-Host "index.html cleaned successfully."
