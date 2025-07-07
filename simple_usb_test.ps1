Write-Host "=== DETECCIÓN DE IMPRESORAS USB ===" -ForegroundColor Green

Write-Host "Impresoras instaladas:" -ForegroundColor Yellow
Get-WmiObject -Class Win32_Printer | Select-Object Name, PortName, DriverName, Status | Format-Table -AutoSize

Write-Host "Dispositivos USB:" -ForegroundColor Yellow  
Get-WmiObject -Class Win32_PnPEntity | Where-Object {$_.DeviceID -like "*USB*" -and $_.Status -eq "OK"} | Select-Object Name, DeviceID | Format-Table -AutoSize
