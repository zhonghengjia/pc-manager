Write-Host "============================================"
Write-Host "  WINDOWS DEFENDER QUICK SCAN"
Write-Host "============================================"

Write-Host "Starting quick scan..."
$result = Start-MpScan -ScanType QuickScan -ErrorAction SilentlyContinue

if ($result) {
    Write-Host "Scan complete."
} else {
    Write-Host "Quick scan returned empty (no threats or scan already running)."
}

Write-Host ""
Write-Host "=== Threat history (last 7 days) ==="
Get-MpThreatDetection -ErrorAction SilentlyContinue | Where-Object { $_.DetectionTime -gt (Get-Date).AddDays(-7) } | Select-Object DetectionTime,ThreatName,ActionSuccess | Format-Table -AutoSize

Write-Host ""
Write-Host "=== Protection status ==="
$status = Get-MpComputerStatus
Write-Host "RealTime: $($status.RealTimeProtectionEnabled)"
Write-Host "AV Signature: $($status.AntivirusSignatureLastUpdated)"
Write-Host "NIS Signature: $($status.NISSignatureLastUpdated)"
