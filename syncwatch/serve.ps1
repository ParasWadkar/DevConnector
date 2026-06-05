# Minimal static file server using .NET HttpListener
param([int]$Port = 3000)

$root = $PSScriptRoot
# Canonical root, with a trailing separator so "C:\site" can't match "C:\site-evil".
$rootFull = [System.IO.Path]::GetFullPath($root)
if (-not $rootFull.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
  $rootFull += [System.IO.Path]::DirectorySeparatorChar
}

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Serving $root on http://localhost:$Port/"

$mimeTypes = @{
  ".html" = "text/html; charset=utf-8"
  ".js"   = "application/javascript"
  ".css"  = "text/css"
  ".json" = "application/json"
  ".png"  = "image/png"
  ".jpg"  = "image/jpeg"
  ".svg"  = "image/svg+xml"
  ".ico"  = "image/x-icon"
}

while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $req = $ctx.Request
  $res = $ctx.Response

  # Hardening headers (defence in depth; the listener is localhost-only).
  $res.Headers.Add("X-Content-Type-Options", "nosniff")
  $res.Headers.Add("X-Frame-Options", "DENY")
  $res.Headers.Add("Referrer-Policy", "no-referrer")

  $urlPath = $req.Url.LocalPath
  if ($urlPath -eq "/" -or $urlPath -eq "") { $urlPath = "/index.html" }

  $filePath = Join-Path $root ($urlPath.TrimStart("/").Replace("/", [System.IO.Path]::DirectorySeparatorChar))

  # Resolve to a canonical absolute path and verify it stays inside the web root.
  # Don't rely on .NET URI normalisation alone — reject anything that escapes $root.
  $filePathFull = $null
  try { $filePathFull = [System.IO.Path]::GetFullPath($filePath) } catch { $filePathFull = $null }

  # Deploy-only / sensitive files that should never be served to a browser.
  $leaf = [System.IO.Path]::GetFileName($filePathFull)
  $denied = @("firebase.json", "database.rules.json", ".firebaserc")
  $isDotPath = ($urlPath -split "/") | Where-Object { $_.StartsWith(".") }

  if (-not $filePathFull -or -not $filePathFull.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
    $res.StatusCode = 403
    $body = [System.Text.Encoding]::UTF8.GetBytes("Forbidden")
    $res.OutputStream.Write($body, 0, $body.Length)
  } elseif (($denied -contains $leaf) -or $isDotPath) {
    $res.StatusCode = 403
    $body = [System.Text.Encoding]::UTF8.GetBytes("Forbidden")
    $res.OutputStream.Write($body, 0, $body.Length)
  } elseif (Test-Path $filePathFull -PathType Leaf) {
    $ext = [System.IO.Path]::GetExtension($filePathFull)
    $res.ContentType = if ($mimeTypes[$ext]) { $mimeTypes[$ext] } else { "application/octet-stream" }
    $bytes = [System.IO.File]::ReadAllBytes($filePathFull)
    $res.ContentLength64 = $bytes.Length
    $res.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $res.StatusCode = 404
    $body = [System.Text.Encoding]::UTF8.GetBytes("Not found")
    $res.OutputStream.Write($body, 0, $body.Length)
  }
  $res.OutputStream.Close()
}
