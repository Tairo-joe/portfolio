# Update portfolio index.html with dark mode toggle, blog section, CTA, performance, and contact fixes
$ErrorActionPreference = 'Stop'

$IndexPath = "c:\Users\user\Downloads\portfolio\index.html"
if (-not (Test-Path $IndexPath)) {
  throw "index.html not found at $IndexPath"
}

# Backup
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$BackupPath = "c:\Users\user\Downloads\portfolio\index.backup.$timestamp.html"
Copy-Item $IndexPath $BackupPath -Force

# Read
$content = Get-Content -Raw -Path $IndexPath

# 1) Performance: preconnect to Google Fonts (idempotent)
if ($content -notmatch 'rel="preconnect"\s+href="https://fonts\.googleapis\.com"') {
  $content = $content -replace '(\s*<!-- Bootstrap CSS -->)', @'
  <!-- Performance: preconnect to Google Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
$1'@
}

# Add color-scheme meta (idempotent)
if ($content -notmatch 'name="color-scheme"') {
  $content = $content -replace '(<meta name="viewport"[^>]*>\s*)', '$1  <meta name="color-scheme" content="light dark" />`n'
}

# 2) Name consistency: navbar brand -> Isaac Tairo
$content = $content -replace '(<a class="navbar-brand[^"]*"[^>]*>)[^<]+(</a>)', '$1Isaac Tairo$2'

# 3) Fix email links
$content = $content -replace 'href="cudjoetairo@gmail\.com"', 'href="mailto:cudjoetairo@gmail.com"'
$content = $content -replace 'href="mailto:your\.email@example\.com"', 'href="mailto:cudjoetairo@gmail.com"'

# 4) Netlify redirect for contact form (add action if missing)
if ($content -notmatch '<form[^>]*name="contact"[^>]*action="thanks\.html"') {
  $content = [regex]::Replace($content, '(?s)(<form[^>]*name="contact"[^>]*)(>)(.*?</form>)', {
    param($m)
    $start = $m.Groups[1].Value
    if ($start -match 'action="thanks\.html"') { return $m.Value }
    return ($start + ' action="thanks.html"' + $m.Groups[2].Value + $m.Groups[3].Value)
  })
}

# 5) Contact Conversion: CTA section before Contact section (idempotent)
if ($content -notmatch '<section id="cta"') {
  $content = $content -replace '(?m)^\s*<!-- Contact -->', @'
  <!-- Call To Action -->
  <section id="cta" class="py-5 bg-white border-top border-bottom">
    <div class="container d-flex flex-column flex-lg-row align-items-center justify-content-between gap-3">
      <h3 class="mb-0">Have a project in mind? Let’s work together.</h3>
      <a href="#contact" class="btn btn-primary btn-lg">Start a Project</a>
    </div>
  </section>

  <!-- Contact -->'@
}

# 6) Blog / Notes section before Experience (idempotent)
if ($content -notmatch '<section id="blog"') {
  $content = $content -replace '(?m)^\s*<!-- Experience -->', @'
  <!-- Blog / Notes -->
  <section id="blog" class="bg-light">
    <div class="container">
      <h2 class="section-title">Blog / Notes</h2>
      <div class="row g-4">
        <div class="col-12 col-md-4">
          <div class="card h-100 shadow-sm">
            <img src="assets/blog1.svg" class="card-img-top" alt="Blog cover 1" />
            <div class="card-body d-flex flex-column">
              <h5 class="card-title">Flask IT Asset System: Architecture notes</h5>
              <p class="card-text text-muted flex-grow-1">Key design decisions and lessons from building a role-based asset tracker in Flask.</p>
              <a href="#" class="btn btn-outline-primary mt-auto">Read notes</a>
            </div>
          </div>
        </div>
        <div class="col-12 col-md-4">
          <div class="card h-100 shadow-sm">
            <img src="assets/blog2.svg" class="card-img-top" alt="Power BI notes cover" />
            <div class="card-body d-flex flex-column">
              <h5 class="card-title">Claims Dashboard metrics and DAX basics</h5>
              <p class="card-text text-muted flex-grow-1">Tracking TAT, statuses, and building clean visuals with Power BI.</p>
              <a href="#" class="btn btn-outline-primary mt-auto">Read notes</a>
            </div>
          </div>
        </div>
        <div class="col-12 col-md-4">
          <div class="card h-100 shadow-sm">
            <img src="assets/blog3.svg" class="card-img-top" alt="AI notes cover" />
            <div class="card-body d-flex flex-column">
              <h5 class="card-title">Face recognition experiments</h5>
              <p class="card-text text-muted flex-grow-1">Notes from trying face_recognition and OpenCV for basic recognition.</p>
              <a href="#" class="btn btn-outline-primary mt-auto">Read notes</a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- Experience -->'@
}

# 7) Dark mode toggle button (idempotent)
if ($content -notmatch 'id="themeToggle"') {
  $content = $content -replace '(?m)^\s*<!-- Bootstrap JS -->', @'
  <button id="themeToggle" type="button" class="btn btn-outline-secondary position-fixed bottom-0 end-0 m-4 shadow-sm" aria-label="Toggle dark mode">
    <i class="bi bi-moon"></i>
  </button>

  <!-- Bootstrap JS -->'@
}

# 8) Inject theme init/toggle script into existing script block (idempotent)
if ($content -notmatch 'THEME_KEY') {
  $content = $content -replace '(<script>\s*)', @'$1
    // Theme: initialize and toggle
    (function() {
      var root = document.documentElement;
      var THEME_KEY = "theme";
      var prefersDark = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
      var saved = localStorage.getItem(THEME_KEY) || (prefersDark ? "dark" : "light");
      root.setAttribute("data-bs-theme", saved);
      window.addEventListener("DOMContentLoaded", function() {
        var btn = document.getElementById("themeToggle");
        if (!btn) return;
        var icon = btn.querySelector("i");
        function setIcon(t) {
          if (!icon) return;
          icon.classList.toggle("bi-sun", t === "dark");
          icon.classList.toggle("bi-moon", t !== "dark");
        }
        setIcon(saved);
        btn.addEventListener("click", function() {
          var current = root.getAttribute("data-bs-theme") === "dark" ? "dark" : "light";
          var next = current === "dark" ? "light" : "dark";
          root.setAttribute("data-bs-theme", next);
          localStorage.setItem(THEME_KEY, next);
          setIcon(next);
        });
      });
    })();
'@
}

# 9) Performance: lazy-load images (simple approach; idempotent-ish)
# Adds loading and decoding if not present by replacing '<img ' with attributes
if ($content -notmatch 'loading="lazy"') {
  $content = $content -replace '<img\s+', '<img loading="lazy" decoding="async" '
}

# Write back
Set-Content -Path $IndexPath -Value $content -Encoding UTF8

Write-Host "Updated index.html. Backup at $BackupPath"
