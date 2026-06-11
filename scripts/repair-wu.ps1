Write-Host "============================================"
Write-Host "  WINDOWS UPDATE REPAIR"
Write-Host "============================================"

Write-Host ""
Write-Host "[1/4] Stopping WU services..."
$wuSvcs = @("wuauserv", "bits", "cryptsvc", "msiserver")
foreach($s in $wuSvcs) {
    Stop-Service $s -Force -ErrorAction SilentlyContinue
    Write-Host "  Stopped: $s"
}

Write-Host ""
Write-Host "[2/4] Rename SoftwareDistribution cache..."
$sdOld = "C:\Windows\SoftwareDistribution.old"
if (Test-Path $sdOld) { Remove-Item $sdOld -Recurse -Force -ErrorAction SilentlyContinue }
Rename-Item "C:\Windows\SoftwareDistribution" "SoftwareDistribution.old" -Force -ErrorAction SilentlyContinue
Write-Host "  Renamed SoftwareDistribution -> SoftwareDistribution.old"

Write-Host ""
Write-Host "[3/4] Reset WU components..."
$catroot2 = "C:\Windows\System32\catroot2.old"
if (Test-Path $catroot2) { Remove-Item $catroot2 -Recurse -Force -ErrorAction SilentlyContinue }
Rename-Item "C:\Windows\System32\catroot2" "catroot2.old" -Force -ErrorAction SilentlyContinue
Write-Host "  Renamed catroot2"

# Re-register WU DLLs
Write-Host "  Re-registering WU DLLs..."
$dlls = @(
    "atl.dll", "urlmon.dll", "mshtml.dll", "shdocvw.dll",
    "browseui.dll", "jscript.dll", "vbscript.dll", "scrrun.dll",
    "msxml.dll", "msxml3.dll", "msxml6.dll", "actxprxy.dll",
    "softpub.dll", "wintrust.dll", "dssenh.dll", "rsaenh.dll",
    "gpkcsp.dll", "sccbase.dll", "slbcsp.dll", "cryptdlg.dll"
)
foreach($dll in $dlls) {
    regsvr32.exe /s "$env:WINDIR\System32\$dll" 2>&1 | Out-Null
}

# Core WU files
$wuFiles = @(
    "wuapi.dll", "wuaueng.dll", "wucltux.dll", "wups.dll",
    "wups2.dll", "wuwebv.dll", "qmgr.dll", "qmgrprxy.dll"
)
foreach($f in $wuFiles) {
    regsvr32.exe /s "$env:WINDIR\System32\$f" 2>&1 | Out-Null
}
Write-Host "  DLLs re-registered"

# Reset winsock
netsh winsock reset 2>&1 | Out-Null
Write-Host "  Winsock reset"

Write-Host ""
Write-Host "[4/4] Starting services..."
Start-Service "bits","cryptsvc","msiserver" -ErrorAction SilentlyContinue
Write-Host "  Services restarted"

Write-Host ""
Write-Host "=== NEXT: Run DISM restore (requires admin) ==="
Write-Host "Running DISM /RestoreHealth in elevated window..."
Write-Host "This may take 5-15 minutes. Please wait."
Write-Host ""

# Run DISM
dism /Online /Cleanup-Image /RestoreHealth 2>&1 | Write-Host

Write-Host ""
Write-Host "=== DISM done, running SFC ==="
sfc /scannow 2>&1 | Select-Object -Last 5

Write-Host ""
Write-Host "=== Trying to recreate UpdateOrchestrator tasks ==="
# Use the Windows Update reset commands
wuauclt.exe /resetauthorization /detectnow 2>&1

# Check if tasks appeared
Start-Sleep 5
$tasks = Get-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\' -ErrorAction SilentlyContinue
Write-Host "UpdateOrchestrator tasks after repair: $($tasks.Count)"

Write-Host ""
Write-Host "============================================"
Write-Host "  REPAIR COMPLETE"
Write-Host "  Please reboot, then check Windows Update"
Write-Host "============================================"
