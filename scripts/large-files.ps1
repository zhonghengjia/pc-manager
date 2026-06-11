Write-Host "============================================"
Write-Host "  LARGE FILE FINDER"
Write-Host "============================================"

$drive = if ($args[0]) { $args[0] } else { "C:\" }
$minMB = if ($args[1]) { [int]$args[1] } else { 500 }

Write-Host "Scanning $drive for files > $minMB MB..."
Write-Host ""

Get-ChildItem $drive -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt ($minMB * 1MB) } | Sort-Object Length -Descending | Select-Object -First 30 | ForEach-Object {
    $mb = [math]::Round($_.Length / 1MB, 0)
    $gb = [math]::Round($_.Length / 1GB, 2)
    $size = if ($mb -gt 1000) { "${gb}GB" } else { "${mb}MB" }
    Write-Host "  $size  $($_.FullName)"
}

Write-Host ""
Write-Host "Tip: /large-files D:\ 1000  (scan D: for files >1GB)"
