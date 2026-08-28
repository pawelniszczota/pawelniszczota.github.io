$ErrorActionPreference = 'Stop'

$siteRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\docs')).Path
$errors = [System.Collections.Generic.List[string]]::new()
$htmlFiles = Get-ChildItem -LiteralPath $siteRoot -Filter '*.html' -Recurse

foreach ($file in $htmlFiles) {
  $content = Get-Content -Raw -LiteralPath $file.FullName

  if ($content -notmatch '<!doctype html>') {
    $errors.Add("$($file.Name): missing doctype")
  }

  if ($content -notmatch '<html lang="en">') {
    $errors.Add("$($file.Name): missing language declaration")
  }

  $h1Count = ([regex]::Matches($content, '<h1(?:\s|>)', 'IgnoreCase')).Count
  if ($h1Count -ne 1) {
    $errors.Add("$($file.Name): expected one h1, found $h1Count")
  }

  foreach ($img in [regex]::Matches($content, '<img\b[^>]*>', 'IgnoreCase')) {
    if ($img.Value -notmatch '\balt="[^"]*"') {
      $errors.Add("$($file.Name): image missing alt text")
    }
  }

  $ids = [regex]::Matches($content, '\bid="([^"]+)"', 'IgnoreCase') |
    ForEach-Object { $_.Groups[1].Value }
  foreach ($duplicate in ($ids | Group-Object | Where-Object Count -gt 1)) {
    $errors.Add("$($file.Name): duplicate id '$($duplicate.Name)'")
  }

  foreach ($match in [regex]::Matches($content, '(?:href|src)="([^"]+)"', 'IgnoreCase')) {
    $url = $match.Groups[1].Value
    if ($url -match '^(https?:|mailto:|tel:|data:)') {
      continue
    }

    $parts = $url -split '#', 2
    $relativePath = [uri]::UnescapeDataString($parts[0])
    $fragment = if ($parts.Count -gt 1) { $parts[1] } else { '' }
    $target = if ([string]::IsNullOrWhiteSpace($relativePath)) {
      $file.FullName
    } else {
      Join-Path $file.DirectoryName $relativePath
    }

    if (-not (Test-Path -LiteralPath $target)) {
      $errors.Add("$($file.Name): missing local target '$url'")
      continue
    }

    if ($fragment -and ([IO.Path]::GetExtension($target) -eq '.html')) {
      $targetContent = Get-Content -Raw -LiteralPath $target
      $fragmentPattern = '\bid="' + [regex]::Escape($fragment) + '"'
      if ($targetContent -notmatch $fragmentPattern) {
        $errors.Add("$($file.Name): missing fragment target '$url'")
      }
    }
  }

  foreach ($anchor in [regex]::Matches($content, '<a\b[^>]*target="_blank"[^>]*>', 'IgnoreCase')) {
    if ($anchor.Value -notmatch 'rel="[^"]*noopener') {
      $errors.Add("$($file.Name): target=_blank link lacks noopener")
    }
  }

  $isNoIndex = $content -match '<meta name="robots" content="[^"]*noindex'
  if ($file.Name -ne '404.html' -and -not $isNoIndex) {
    if ($content -notmatch '<meta name="description"') {
      $errors.Add("$($file.Name): missing meta description")
    }
    if ($content -notmatch '<link rel="canonical"') {
      $errors.Add("$($file.Name): missing canonical URL")
    }
  }
}

if ($errors.Count -gt 0) {
  Write-Host "Site validation failed with $($errors.Count) error(s):"
  $errors | ForEach-Object { Write-Host "- $_" }
  exit 1
}

Write-Host "Site validation passed for $($htmlFiles.Count) HTML pages."
