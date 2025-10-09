# Surgical ASCII-only cleanup for index.html
$ErrorActionPreference = 'Stop'

$root = "c:\Users\user\Downloads\portfolio"
$indexPath = Join-Path $root "index.html"
if (-not (Test-Path $indexPath)) { throw "index.html not found" }

# Backup current
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$backup = Join-Path $root ("index.surgery." + $timestamp + ".html")
Copy-Item $indexPath $backup -Force

# Read
$c = Get-Content -Raw -Path $indexPath

# 1) Remove backslash-escaped quotes in HTML
$c = $c -replace '\\"','"'

# 2) Remove stray <script> before the theme IIFE (when inside another <script> block)
$c = [regex]::Replace($c, '(?m)^\s*<script>\s*(?=\(function\(\)\s*\{)', '')

# 3) Fix duplicated closing script tags
$c = [regex]::Replace($c, '(?s)</script>\s*</script>\s*</body>', '</script></body>')

# 4) Ensure a clean ASCII meta description
$c = [regex]::Replace($c, '<meta name="description"[^>]*>', '<meta name="description" content="Portfolio of Isaac Tairo - Aspiring IT & AI Engineer | Information Systems Intern. Projects in IT systems, data, database management and AI." />')

# 5) Replace CTA h3 text with ASCII-only string
$c = [regex]::Replace($c, '(?s)(<section id="cta"[\s\S]*?<h3 class="mb-0">)(.*?)(</h3>)', '${1}Have a project in mind? Let''s work together.${3}')

# 6) Replace contact honeypot label text with ASCII-only string
$c = [regex]::Replace($c, '(?s)(<label>)(.*?)(<input name="bot-field" />\s*</label>)', '${1}Don''t fill this out if you''re human: ${3}')

# 7) Footer inner text -> ASCII-only text with &copy;
$c = [regex]::Replace($c, '(?s)(<footer[^>]*>\s*<div[^>]*>)(.*?)(</div>\s*</footer>)', '${1}&copy; 2025 Isaac Tairo | Built with love using Python, Flask, HTML &amp; CSS and Web Technologies${3}')

# 8) Navbar brand visible text -> Isaac Tairo
$c = [regex]::Replace($c, '(<a class="navbar-brand[^"]*"[^>]*>)[^<]+(</a>)', '$1Isaac Tairo$2')

# Write back
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($indexPath, $c, $utf8NoBom)

Write-Host "index.html cleaned. Backup at $backup"
