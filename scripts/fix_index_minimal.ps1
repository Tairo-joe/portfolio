# Minimal cleanup for index.html to fix escaped quotes, nested scripts, mojibake, and navbar brand
$ErrorActionPreference = 'Stop'

$root = "c:\Users\user\Downloads\portfolio"
$indexPath = Join-Path $root "index.html"
if (-not (Test-Path $indexPath)) { throw "index.html not found" }

# Backup current
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
Copy-Item $indexPath (Join-Path $root "index.minifix.$timestamp.html") -Force

# Read
$content = Get-Content -Raw -Path $indexPath

# 1) Remove backslash-escaped quotes introduced into HTML
$content = $content -replace '\\"','"'

# 2) Remove stray opening <script> inserted right before theme IIFE inside another <script>
$content = [regex]::Replace($content, '(?m)^\s*<script>\s*(?=\(function\(\)\s*\{)', '')

# 3) Fix double closing </script></script></body>
$content = [regex]::Replace($content, '(?s)</script>\s*</script>\s*</body>', "</script>``n</body>")

# 4) Normalize common mojibake to HTML entities to avoid encoding issues
$replacements = @{
  'â€”' = '&mdash;';
  'â€“' = '&ndash;';
  'â€˜' = '&lsquo;';
  'â€™' = '&rsquo;';
  'â€œ' = '&ldquo;';
  'â€�' = '&rdquo;';
  'Â©'  = '&copy;';
  'â¤ï¸' = '&#10084;&#65039;';
  'Letâ€™s' = 'Let&rsquo;s';
  'Donâ€™t' = 'Don&rsquo;t'
}
foreach ($k in $replacements.Keys) { $content = $content -replace [regex]::Escape($k), $replacements[$k] }

# 5) Navbar brand text -> Isaac Tairo (visible text only)
$content = [regex]::Replace($content, '(<a class="navbar-brand[^"]*"[^>]*>)[^<]+(</a>)', '$1Isaac Tairo$2')

# 6) Write back as UTF-8 (no BOM)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($indexPath, $content, $utf8NoBom)

Write-Host "index.html cleaned (minimal). Backup at index.minifix.$timestamp.html"
