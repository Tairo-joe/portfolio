# Final copy fixes for index.html (ASCII-safe)
$ErrorActionPreference = 'Stop'

$root = "c:\Users\user\Downloads\portfolio"
$indexPath = Join-Path $root "index.html"
if (-not (Test-Path $indexPath)) { throw "index.html not found" }

# Backup current
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
Copy-Item $indexPath (Join-Path $root ("index.copyfix." + $timestamp + ".html")) -Force

# Read
$content = Get-Content -Raw -Path $indexPath

# New texts (ASCII only)
$aboutNew = "Hi, I'm Isaac Cudjoe Tairo Nelson. I am currently an Information Systems Intern at SIC Insurance, where I support IT operations and develop systems that improve efficiency, and a student of Information Systems and Technology at the University of Mines and Technology (UMaT). I have strong interests in IT systems, data analytics, graphic design, videography, photography, and AI applications in engineering. My goal is to build solutions that bridge technology and business needs."
$expNew = "Information Systems Intern - SIC Insurance"
$eduNew = "Bachelor's student (Information Systems and Technology - University of Mines and Technology (UMaT))."

# Replace About paragraph inside its section
$content = [regex]::Replace($content, '(?s)(<section id="about"[\s\S]*?<p class="mb-0">)(.*?)(</p>)', {
  param($m)
  $m.Groups[1].Value + $aboutNew + $m.Groups[3].Value
})

# Replace Experience title inside its section
$content = [regex]::Replace($content, '(?s)(<section id="experience"[\s\S]*?<h5 class="card-title mb-1">)(.*?)(</h5>)', {
  param($m)
  $m.Groups[1].Value + $expNew + $m.Groups[3].Value
})

# Replace Education line inside its section
$content = [regex]::Replace($content, '(?s)(<section id="education"[\s\S]*?<p class="mb-0">)(.*?)(</p>)', {
  param($m)
  $m.Groups[1].Value + $eduNew + $m.Groups[3].Value
})

# Update image alt texts to match current name
$content = $content -replace 'alt="Isaac Leslie profile placeholder"', 'alt="Isaac Tairo profile placeholder"'

# Write back
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($indexPath, $content, $utf8NoBom)

Write-Host "index.html copy updated. Backup at index.copyfix.$timestamp.html"
