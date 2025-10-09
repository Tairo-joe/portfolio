# Safely restore from latest backup and apply requested features
$ErrorActionPreference = 'Stop'

$root = "c:\Users\user\Downloads\portfolio"
$indexPath = Join-Path $root "index.html"

# 1) Restore from the newest backup if available
$latestBackup = Get-ChildItem -Path $root -Filter "index.backup.*.html" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($latestBackup) {
  Copy-Item $latestBackup.FullName $indexPath -Force
}

# 2) Read current index
$content = Get-Content -Raw -Path $indexPath

# 3) Title and description (preserve user's new name if already set)
if ($content -match '<title>[^<]*</title>') {
  $content = [regex]::Replace($content, '<title>[^<]*</title>', '<title>Isaac Tairo | Portfolio</title>')
}
if ($content -match '<meta name="description"[^>]*>') {
  $content = [regex]::Replace($content, '<meta name="description"[^>]*>', '<meta name="description" content="Portfolio of Isaac Tairo — Aspiring IT & AI Engineer | Information Systems Intern. Projects in IT systems, data, Database Management and AI." />')
}

# 4) Performance preconnects before Bootstrap CSS
if ($content -notmatch 'fonts\.googleapis\.com') {
  $content = $content -replace [regex]::Escape('<!-- Bootstrap CSS -->'), @"
  <!-- Performance: preconnect to Google Fonts -->
  <link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">
  <link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin>
  <!-- Bootstrap CSS -->
"@
}

# 5) Color-scheme meta after viewport
if ($content -notmatch 'name=\"color-scheme\"') {
  $content = [regex]::Replace($content, '(<meta name=\"viewport\"[^>]*>)(\s*)', '$1$2  <meta name="color-scheme" content="light dark" />' + [Environment]::NewLine)
}

# 6) Small inline style for anchor offset (avoid editing style.css)
if ($content -notmatch 'scroll-padding-top') {
  $content = [regex]::Replace($content, '(?is)</head>', '<style>html{scroll-padding-top:90px}</style></head>')
}

# 7) CTA before Contact
if ($content -notmatch '<section id=\"cta\"') {
  $cta = @"
  <!-- Call To Action -->
  <section id=\"cta\" class=\"py-5 bg-white border-top border-bottom\">
    <div class=\"container d-flex flex-column flex-lg-row align-items-center justify-content-between gap-3\">
      <h3 class=\"mb-0\">Have a project in mind? Let’s work together.</h3>
      <a href=\"#contact\" class=\"btn btn-primary btn-lg\">Start a Project</a>
    </div>
  </section>

  <!-- Contact -->
"@
  $content = $content -replace '(?m)^\s*<!-- Contact -->', $cta
}

# 8) Blog before Experience
if ($content -notmatch '<section id=\"blog\"') {
  $blog = @"
  <!-- Blog / Notes -->
  <section id=\"blog\" class=\"bg-light\">
    <div class=\"container\">
      <h2 class=\"section-title\">Blog / Notes</h2>
      <div class=\"row g-4\">
        <div class=\"col-12 col-md-4\">
          <div class=\"card h-100 shadow-sm\">
            <img src=\"assets/blog1.svg\" class=\"card-img-top\" alt=\"Blog cover 1\" loading=\"lazy\" decoding=\"async\" />
            <div class=\"card-body d-flex flex-column\">
              <h5 class=\"card-title\">Flask IT Asset System: Architecture notes</h5>
              <p class=\"card-text text-muted flex-grow-1\">Key design decisions and lessons from building a role-based asset tracker in Flask.</p>
              <a href=\"#\" class=\"btn btn-outline-primary mt-auto\">Read notes</a>
            </div>
          </div>
        </div>
        <div class=\"col-12 col-md-4\">
          <div class=\"card h-100 shadow-sm\">
            <img src=\"assets/blog2.svg\" class=\"card-img-top\" alt=\"Power BI notes cover\" loading=\"lazy\" decoding=\"async\" />
            <div class=\"card-body d-flex flex-column\">
              <h5 class=\"card-title\">Claims Dashboard metrics and DAX basics</h5>
              <p class=\"card-text text-muted flex-grow-1\">Tracking TAT, statuses, and building clean visuals with Power BI.</p>
              <a href=\"#\" class=\"btn btn-outline-primary mt-auto\">Read notes</a>
            </div>
          </div>
        </div>
        <div class=\"col-12 col-md-4\">
          <div class=\"card h-100 shadow-sm\">
            <img src=\"assets/blog3.svg\" class=\"card-img-top\" alt=\"AI notes cover\" loading=\"lazy\" decoding=\"async\" />
            <div class=\"card-body d-flex flex-column\">
              <h5 class=\"card-title\">Face recognition experiments</h5>
              <p class=\"card-text text-muted flex-grow-1\">Notes from trying face_recognition and OpenCV for basic recognition.</p>
              <a href=\"#\" class=\"btn btn-outline-primary mt-auto\">Read notes</a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

"@
  $content = $content -replace '(?m)^\s*<!-- Experience -->', ($blog + '<!-- Experience -->')
}

# 9) Dark mode toggle button before Bootstrap JS
if ($content -notmatch 'id=\"themeToggle\"') {
  $content = $content -replace '(?m)^\s*<!-- Bootstrap JS -->', @"
  <button id=\"themeToggle\" type=\"button\" class=\"btn btn-outline-secondary position-fixed bottom-0 end-0 m-4 shadow-sm\" aria-label=\"Toggle dark mode\">
    <i class=\"bi bi-moon\"></i>
  </button>

  <!-- Bootstrap JS -->
"@
}

# 10) Append theme script before closing body
if ($content -notmatch 'var THEME_KEY') {
  $themeScript = @"
  <script>
    (function() {
      var root = document.documentElement;
      var THEME_KEY = 'theme';
      var prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
      var saved = localStorage.getItem(THEME_KEY) || (prefersDark ? 'dark' : 'light');
      root.setAttribute('data-bs-theme', saved);
      window.addEventListener('DOMContentLoaded', function() {
        var btn = document.getElementById('themeToggle');
        if (!btn) return;
        var icon = btn.querySelector('i');
        function setIcon(t) {
          if (!icon) return;
          icon.classList.toggle('bi-sun', t === 'dark');
          icon.classList.toggle('bi-moon', t !== 'dark');
        }
        setIcon(saved);
        btn.addEventListener('click', function() {
          var current = root.getAttribute('data-bs-theme') === 'dark' ? 'dark' : 'light';
          var next = current === 'dark' ? 'light' : 'dark';
          root.setAttribute('data-bs-theme', next);
          localStorage.setItem(THEME_KEY, next);
          setIcon(next);
        });
      });
    })();
  </script>
"@
  if ($content -match '(?s)</script>\s*</body>') {
    $content = $content -replace '(?s)</script>\s*</body>', ($themeScript + '</script></body>')
  } else {
    $content = $content -replace '(?is)</body>', ($themeScript + '</body>')
  }
}

# 11) Lazy-load images (only if no loading attr present)
$content = [regex]::Replace($content, '<img(?![^>]*\bloading=)', '<img loading="lazy" decoding="async"')

# 12) Netlify redirect on contact form
$content = [regex]::Replace($content, '(?s)(<form[^>]*name=\"contact\"[^>]*)(>)', {
  param($m)
  if ($m.Groups[1].Value -match 'action=') {
    return $m.Value
  } else {
    return ($m.Groups[1].Value + ' action="thanks.html"' + $m.Groups[2].Value)
  }
})

# 13) Fix email links
$content = $content -replace 'href=\"cudjoetairo@gmail\.com\"', 'href="mailto:cudjoetairo@gmail.com"'
$content = $content -replace 'mailto:your\.email@example\.com', 'mailto:cudjoetairo@gmail.com'

# 14) Optional: Navbar name consistency to Isaac Tairo (uncomment to enable)
# $content = [regex]::Replace($content, '(<a class=\"navbar-brand[^\"]*\"[^>]*>)[^<]+(</a>)', '$1Isaac Tairo$2')

# 15) Write back as UTF-8 without BOM to keep Unicode characters intact
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($indexPath, $content, $utf8NoBom)

Write-Host "Restored from backup (if available) and applied features safely."
