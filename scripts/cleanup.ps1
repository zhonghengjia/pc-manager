Write-Host "============================================"
Write-Host "  SAFE SYSTEM CLEANUP"
Write-Host "============================================"
$ErrorActionPreference = "Continue"
$totalMB = 0

# Windows Temp
Write-Host ""
Write-Host "[1/4] Windows Temp..."
$wt = "$env:WINDIR\Temp"
if (Test-Path $wt) {
    $before = (Get-ChildItem $wt -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    Get-ChildItem $wt -Recurse -File -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    $mb = [math]::Round($before/1MB, 0)
    $totalMB += $mb
    Write-Host "  $wt : $mb MB"
}

# User Temp (exclude Claude)
Write-Host "[2/4] User Temp..."
$ut = $env:TEMP
if (Test-Path $ut) {
    $before = (Get-ChildItem $ut -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch 'claude|Claude' } | Measure-Object Length -Sum).Sum
    Get-ChildItem $ut -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch 'claude|Claude' } | Remove-Item -Force -ErrorAction SilentlyContinue
    $mb = [math]::Round($before/1MB, 0)
    $totalMB += $mb
    Write-Host "  $ut : $mb MB (Claude excluded)"
}

# Recycle Bin
Write-Host "[3/4] Recycle Bin..."
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Write-Host "  Emptied"

# Browser cache summary
Write-Host "[4/4] Browser cache sizes (not cleaned):"
$chromeCache = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\Cache_Data"
$edgeCache = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\Cache_Data"
if (Test-Path $chromeCache) {
    $sz = [math]::Round((Get-ChildItem $chromeCache -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum / 1MB, 0)
    Write-Host "  Chrome: $sz MB"
}
if (Test-Path $edgeCache) {
    $sz = [math]::Round((Get-ChildItem $edgeCache -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum / 1MB, 0)
    Write-Host "  Edge: $sz MB"
}

Write-Host ""
Write-Host "Total cleaned: ~$totalMB MB"
Write-Host "============================================"
