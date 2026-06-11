$ErrorActionPreference = "Continue"
Write-Host "============================================"
Write-Host "  SYSTEM OPTIMIZATION"
Write-Host "============================================"

# === 1. STARTUP ===
Write-Host ""
Write-Host "[1/5] Cleaning startup..."
$items = @(
    @{Path="HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"; Name="BaiduYunDetect"},
    @{Path="HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"; Name="com.moonshot.kimichat"},
    @{Path="HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"; Name="MicrosoftEdgeAutoLaunch_3B0FC9BEFC93E0820BDF3C298BB1BD12"}
)
foreach($item in $items) {
    $prop = Get-ItemProperty $item.Path -Name $item.Name -ErrorAction SilentlyContinue
    if ($prop) {
        Remove-ItemProperty -Path $item.Path -Name $item.Name -Force
        Write-Host "  Removed: $($item.Name)"
    }
}
# 360 in HKCU
$hcukey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$p360 = Get-ItemProperty $hcukey -Name "360Safetray" -ErrorAction SilentlyContinue
if ($p360) {
    Remove-ItemProperty -Path $hcukey -Name "360Safetray" -Force
    Write-Host "  Removed: 360Safetray"
}
Write-Host "  Done."

# === 2. SCHEDULED TASKS ===
Write-Host ""
Write-Host "[2/5] Removing scheduled tasks..."
$tasks = @(
    "ximalaya-message-push",
    "ximalaya-message-push-onstart",
    "PowerWord-Notify-jackjia_jiazhongheng",
    "PowerWord-Search-jackjia_jiazhongheng",
    "Readertray",
    "360ZipUpdater",
    "360ZipUpdaterLoop",
    "UpdateSkillIndex",
    "QuarkUpdaterTaskUser1.0.0.21{E6FCD89E-84B5-422A-B764-CAB6CCE553CB}"
)
foreach($tn in $tasks) {
    try {
        $t = Get-ScheduledTask -TaskName $tn -ErrorAction SilentlyContinue
        if ($t) {
            Unregister-ScheduledTask -TaskName $t.TaskName -Confirm:$false -ErrorAction SilentlyContinue
            Write-Host "  Removed: $tn"
        }
    } catch {
        try { Disable-ScheduledTask -TaskName $tn -ErrorAction SilentlyContinue; Write-Host "  Disabled: $tn" } catch {}
    }
}
Write-Host "  Done."

# === 3. SERVICES ===
Write-Host ""
Write-Host "[3/5] Disabling services..."
$svcs = @("SysCleanProService", "LDPlayerSvr", "HPPrintScanDoctorService", "XTU3SERVICE", "GAService", "LZService")
foreach($sn in $svcs) {
    $svc = Get-Service $sn -ErrorAction SilentlyContinue
    if ($svc) {
        Stop-Service $sn -Force -ErrorAction SilentlyContinue
        Set-Service $sn -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "  Disabled: $sn"
    }
}
Write-Host "  Done."

# === 4. TEMP FILES (skip Claude temp dir) ===
Write-Host ""
Write-Host "[4/5] Cleaning temp files..."
$total = 0
$paths = @("$env:WINDIR\Temp", "$env:LOCALAPPDATA\Microsoft\Windows\INetCache")
foreach($tp in $paths) {
    if (Test-Path $tp) {
        $files = Get-ChildItem $tp -Recurse -File -Force -ErrorAction SilentlyContinue
        $mb = [math]::Round(($files | Measure-Object Length -Sum).Sum / 1MB, 0)
        $files | Remove-Item -Force -ErrorAction SilentlyContinue
        $total += $mb
        Write-Host "  $tp : ~$mb MB"
    }
}
# User temp but exclude claude
$userTemp = $env:TEMP
if (Test-Path $userTemp) {
    $files = Get-ChildItem $userTemp -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notlike "*claude*" -and $_.FullName -notlike "*Claude*" }
    $mb = [math]::Round(($files | Measure-Object Length -Sum).Sum / 1MB, 0)
    $files | Remove-Item -Force -ErrorAction SilentlyContinue
    $total += $mb
    Write-Host "  $userTemp (excl. Claude): ~$mb MB"
}
Write-Host "  Total cleaned: ~$total MB"

# === 5. STOP BLOAT PROCESSES ===
Write-Host ""
Write-Host "[5/5] Stopping bloat processes..."
$procs = @("LegionZone", "GameChrome", "QuickInfo", "LZTray", "quark", "SysCleanPro")
foreach($pn in $procs) {
    Get-Process -Name $pn -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "  Stopped: $pn"
}
Write-Host "  Done."

Write-Host ""
Write-Host "============================================"
Write-Host "  ALL DONE"
Write-Host "============================================"
