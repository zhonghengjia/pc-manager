Write-Host "============================================"
Write-Host "  DRIVER HEALTH CHECK"
Write-Host "============================================"

Write-Host ""
Write-Host "=== Problem Devices ==="
$problems = Get-CimInstance Win32_PnPEntity | Where-Object { $_.ConfigManagerErrorCode -ne 0 -and $_.ConfigManagerErrorCode -ne $null }
if ($problems) {
    $codes = @{
        1="Device not configured properly"
        2="Driver loading issue"
        3="Driver corrupted"
        9="Windows cannot identify device"
        10="Device cannot start"
        12="No drivers available"
        14="Device needs restart"
        16="Cannot identify resource usage"
        18="Reinstall drivers"
        19="Registry corrupted"
        21="Device being removed"
        22="Device disabled"
        24="Device not present/not working"
        28="No drivers installed"
        29="Device disabled (BIOS)"
        31="Wrong driver installed"
        32="Driver disabled"
        33="Windows cannot determine resources"
        34="Device configuration issue"
        35="System firmware issue"
        36="IRQ conflict"
        37="Driver initialization failure"
        38="Driver already loaded"
        39="Driver conflict"
        40="Service not registered"
        41="Driver load failure"
        42="Duplicate device"
        43="Device stopped (reported problem)"
        44="Application/service stopped device"
        45="Device not connected"
        46="Device not present (cleanup pending)"
        47="Device in safe removal state"
        48="Driver blocked by policy"
        49="Device exceeds registry size limit"
        50="Device properties not supported"
        51="Device waiting on dependency"
        52="Driver not signed/damaged"
        53="No device driver assigned"
        54="Device reset required"
    }
    foreach($d in $problems) {
        $code = $d.ConfigManagerErrorCode
        $desc = if ($codes[$code]) { $codes[$code] } else { "Unknown error" }
        Write-Host "  [!] $($d.Name) : Code $code - $desc"
    }
} else {
    Write-Host "  All devices OK - no errors detected"
}

Write-Host ""
Write-Host "=== Driver Summary ==="
$types = Get-CimInstance Win32_PnPSignedDriver | Group-Object DeviceClass | Sort-Object Count -Descending
foreach($t in $types) {
    Write-Host "  $($t.Name): $($t.Count) drivers"
}

Write-Host ""
Write-Host "=== Recently Installed Drivers ==="
Get-CimInstance Win32_PnPSignedDriver | Where-Object { $_.InstallDate } | Sort-Object InstallDate -Descending | Select-Object -First 5 DeviceName,DriverVersion,InstallDate | Format-Table -AutoSize
