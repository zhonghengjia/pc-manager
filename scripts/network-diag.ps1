Write-Host "============================================"
Write-Host "  NETWORK DIAGNOSTIC"
Write-Host "============================================"

# WiFi info
Write-Host ""
Write-Host "=== WiFi Status ==="
$wifi = Get-NetAdapter | Where-Object { $_.Name -match 'Wi-Fi|WLAN|Wireless' -and $_.Status -eq 'Up' }
if ($wifi) {
    Write-Host "Adapter: $($wifi.Name)"
    Write-Host "Speed: $($wifi.LinkSpeed)"
    Write-Host "MAC: $($wifi.MacAddress)"
}

# Signal strength
try {
    $wifiInfo = netsh wlan show interfaces 2>&1 | Select-String -Pattern 'Signal|SSID|Radio|Channel|Receive|Transmit'
    foreach($l in $wifiInfo) { Write-Host $l.Line.Trim() }
} catch {}

# DNS Response Time
Write-Host ""
Write-Host "=== DNS Response (Google/Cloudflare/Baidu) ==="
$dnsServers = @("8.8.8.8", "1.1.1.1", "114.114.114.114")
foreach($dns in $dnsServers) {
    $ping = Test-Connection $dns -Count 1 -ErrorAction SilentlyContinue
    if ($ping) {
        Write-Host "  $dns : $($ping.ResponseTime)ms"
    } else {
        Write-Host "  $dns : UNREACHABLE"
    }
}

# Internet connectivity
Write-Host ""
Write-Host "=== Internet Connectivity ==="
$inet = Test-Connection "www.baidu.com" -Count 1 -ErrorAction SilentlyContinue
if ($inet) {
    Write-Host "  Internet: OK ($($inet.ResponseTime)ms to baidu.com)"
} else {
    Write-Host "  Internet: FAIL"
}

# IP config
Write-Host ""
Write-Host "=== IP Config ==="
$ips = Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.AddressState -eq 'Preferred' }
foreach($ip in $ips) {
    Write-Host "  $($ip.InterfaceAlias): $($ip.IPAddress)"
}

# Listening suspicious ports (non-standard high ports)
Write-Host ""
Write-Host "=== Open Ports Summary ==="
$listeners = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue
Write-Host "  Total listening ports: $($listeners.Count)"
$extPorts = $listeners | Where-Object { $_.LocalPort -gt 1024 } | Group-Object LocalPort | Sort-Object Count -Descending | Select-Object -First 10
foreach($p in $extPorts) {
    $proc = Get-Process -Id $p.Group[0].OwningProcess -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Host "  Port $($p.Name): $($proc.ProcessName)"
    }
}
