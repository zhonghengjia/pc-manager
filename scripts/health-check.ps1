Write-Host "==========================================="
Write-Host "  COMPREHENSIVE SYSTEM DEEP SCAN"
Write-Host "==========================================="

# === 1. WINDOWS INTEGRITY ===
Write-Host ""
Write-Host "=== [1/7] WINDOWS INTEGRITY ==="
Write-Host "SFC quick check (can take 2-5 min)..."
$sfcLines = sfc /verifyonly 2>&1 | Select-Object -Last 5
foreach($l in $sfcLines) { Write-Host "  $l" }

Write-Host "DISM health..."
$dismLines = DISM /Online /Cleanup-Image /CheckHealth 2>&1 | Select-Object -Last 5
foreach($l in $dismLines) { Write-Host "  $l" }

# === 2. SECURITY ===
Write-Host ""
Write-Host "=== [2/7] SECURITY STATUS ==="
$defStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue
if ($defStatus) {
    Write-Host "Defender RealTime: $($defStatus.RealTimeProtectionEnabled)"
    Write-Host "Defender AV: $($defStatus.AntivirusEnabled)"
    Write-Host "Last quick scan: $($defStatus.QuickScanEndTime)"
    Write-Host "Last full scan: $($defStatus.FullScanEndTime)"
}

Write-Host ""
$fw = Get-NetFirewallProfile -ErrorAction SilentlyContinue
foreach($p in $fw) {
    Write-Host "Firewall [$($p.Name)]: Enabled=$($p.Enabled)"
}

$zdfy = Get-Service "ZhuDongFangYu" -ErrorAction SilentlyContinue
if ($zdfy -and $zdfy.Status -eq 'Running') {
    Write-Host "360 Active Defense: Still running (requires uninstall to remove)"
}

# === 3. DISK HEALTH ===
Write-Host ""
Write-Host "=== [3/7] DISK HEALTH ==="
Get-PhysicalDisk | ForEach-Object {
    $sizeGB = [math]::Round($_.Size/1GB,0)
    Write-Host "Disk$($_.DeviceID): $($_.MediaType) ${sizeGB}GB | Health=$($_.HealthStatus) | Temp=$($_.Temperature)C"
}

Write-Host ""
Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | ForEach-Object {
    $free = [math]::Round($_.FreeSpace/1GB,1)
    $total = [math]::Round($_.Size/1GB,1)
    $pct = [math]::Round((($total-$free)/$total)*100,0)
    $mark = if($pct -gt 85){"!!"}else{""}
    Write-Host "$($_.DeviceID) $free GB free / $total GB ($pct%) $mark"
}

# === 4. NETWORK LISTENERS ===
Write-Host ""
Write-Host "=== [4/7] NETWORK LISTENING PORTS ==="
$listeners = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Group-Object OwningProcess | Sort-Object Count -Descending | Select-Object -First 15
foreach($g in $listeners) {
    $proc = Get-Process -Id $g.Name -ErrorAction SilentlyContinue
    if ($proc) {
        $ports = $g.Group.LocalPort | Sort-Object -Unique
        $portStr = ($ports | Select-Object -First 5) -join ","
        if ($ports.Count -gt 5) { $portStr = "$portStr +$($ports.Count-5) more" }
        Write-Host "  $($proc.ProcessName) => $portStr"
    }
}

# === 5. PRIVACY ===
Write-Host ""
Write-Host "=== [5/7] PRIVACY CHECK ==="
$telemetry = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -ErrorAction SilentlyContinue
if ($telemetry) {
    $levelMap = @{0="SecurityOnly"; 1="Basic"; 2="Enhanced"; 3="Full"}
    $lvl = $telemetry.AllowTelemetry
    Write-Host "Telemetry: $($levelMap[$lvl]) (level $lvl)"
} else { Write-Host "Telemetry: default (Full)" }

$adId = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -ErrorAction SilentlyContinue
if ($adId) { Write-Host "Advertising ID: $($adId.Enabled)" } else { Write-Host "Advertising ID: not found" }

# Check if 360 or other AV is registered
$av = Get-CimInstance -Namespace "root/SecurityCenter2" -ClassName AntiVirusProduct -ErrorAction SilentlyContinue
if ($av) {
    Write-Host "Registered AV products:"
    foreach($a in $av) { Write-Host "  $($a.displayName)" }
}

# === 6. PERFORMANCE ===
Write-Host ""
Write-Host "=== [6/7] PERFORMANCE ==="
$mem = Get-CimInstance Win32_OperatingSystem
$memTotal = [math]::Round($mem.TotalVisibleMemorySize/1MB,1)
$memFree = [math]::Round($mem.FreePhysicalMemory/1MB,1)
$memPct = [math]::Round((($memTotal-$memFree)/$memTotal)*100,0)
Write-Host "Memory: $memPct% ($memFree GB free / $memTotal GB)"
$cpu = (Get-CimInstance Win32_Processor).LoadPercentage
Write-Host "CPU: $cpu%"
Write-Host "Processes: $((Get-Process).Count)"

Write-Host ""
Write-Host "Top 10 CPU consumers (total time):"
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 | ForEach-Object {
    $s = [math]::Round($_.CPU,0)
    if ($s -gt 0) {
        Write-Host "  $($_.ProcessName) PID=$($_.Id): ${s}s CPU"
    }
}

# === 7. UPDATES ===
Write-Host ""
Write-Host "=== [7/7] WINDOWS UPDATES ==="
$updates = Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5
Write-Host "Last 5 updates:"
foreach($u in $updates) {
    Write-Host "  $($u.HotFixID) - $($u.InstalledOn)"
}

Write-Host ""
Write-Host "==========================================="
Write-Host "  SCAN COMPLETE"
Write-Host "==========================================="
