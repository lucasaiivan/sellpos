# Script para probar la detección de impresoras térmicas USB en puertos USB002 y similares
Write-Host "=== PRUEBA DE DETECCIÓN DE IMPRESORAS USB ===" -ForegroundColor Green
Write-Host ""

$ports = @("USB001", "USB002", "USB003", "USB004", "USB005", "USB006", "USB007", "USB008", "USB009", "USB010")
$foundDevices = @()

Write-Host "1. Detectando impresoras por puertos USB específicos..." -ForegroundColor Yellow
foreach ($port in $ports) {
    $printers = Get-WmiObject -Class Win32_Printer | Where-Object {
        $_.PortName -eq $port -or $_.PortName -like "*$port*" -or $_.PortName -like "USB$port*"
    }
    if ($printers) {
        Write-Host "   ✓ Encontradas impresoras en puerto $port" -ForegroundColor Green
        $foundDevices += $printers | Select-Object Name, PortName, DriverName, DeviceID, Status, @{Name='DetectionMethod';Expression={'Win32_Printer'}}
    }
}

Write-Host ""
Write-Host "2. Detectando dispositivos PnP USB con características de impresora..." -ForegroundColor Yellow
$usbPnpDevices = Get-WmiObject -Class Win32_PnPEntity | Where-Object {
    ($_.DeviceID -like "*USB*" -and ($_.Name -like "*printer*" -or $_.Name -like "*thermal*" -or $_.Name -like "*receipt*" -or $_.Name -like "*POS*")) -or
    ($_.DeviceID -like "*USBPRINT*") -or
    ($_.DeviceID -like "*USB\\VID_*" -and $_.Class -eq "Printer")
}
if ($usbPnpDevices) {
    Write-Host "   ✓ Encontrados dispositivos PnP USB" -ForegroundColor Green
    $foundDevices += $usbPnpDevices | Select-Object Name, @{Name='PortName';Expression={'USB'}}, @{Name='DriverName';Expression={$_.Service}}, DeviceID, Status, @{Name='DetectionMethod';Expression={'PnPEntity'}}
}

Write-Host ""
Write-Host "3. Detectando puertos TCP/IP que podrían ser USB..." -ForegroundColor Yellow
$usbTcpPorts = Get-WmiObject -Class Win32_TCPIPPrinterPort | Where-Object {
    $_.Name -like "USB*" -or $_.HostAddress -like "*USB*"
}
if ($usbTcpPorts) {
    Write-Host "   ✓ Encontrados puertos TCP/IP USB" -ForegroundColor Green
    $foundDevices += $usbTcpPorts | Select-Object @{Name='Name';Expression={$_.Name}}, @{Name='PortName';Expression={$_.Name}}, @{Name='DriverName';Expression={'USB TCP Port'}}, @{Name='DeviceID';Expression={$_.Name}}, @{Name='Status';Expression={'OK'}}, @{Name='DetectionMethod';Expression={'TCPIPPort'}}
}

Write-Host ""
Write-Host "=== RESUMEN DE DISPOSITIVOS ENCONTRADOS ===" -ForegroundColor Green
if ($foundDevices.Count -gt 0) {
    $foundDevices | Format-Table -AutoSize
    Write-Host "Total de dispositivos encontrados: $($foundDevices.Count)" -ForegroundColor Green
} else {
    Write-Host "No se encontraron dispositivos de impresora USB." -ForegroundColor Red
    Write-Host ""
    Write-Host "Mostrando todas las impresoras disponibles para referencia:" -ForegroundColor Yellow
    Get-WmiObject -Class Win32_Printer | Select-Object Name, PortName, DriverName, Status | Format-Table -AutoSize
}

Write-Host ""
Write-Host "=== INFORMACIÓN ADICIONAL ===" -ForegroundColor Green
Write-Host "Dispositivos USB conectados actualmente:" -ForegroundColor Yellow
Get-WmiObject -Class Win32_PnPEntity | Where-Object {$_.DeviceID -like "*USB*" -and $_.Status -eq "OK"} | Select-Object Name, DeviceID | Format-Table -AutoSize
