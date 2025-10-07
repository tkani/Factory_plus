# Factory+ Service Access Script
# AMRC Connectivity Stack (ACS) - Service Access

Write-Host "🏭 Factory+ Service Access" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

Write-Host "`nStopping any existing port forwarding..." -ForegroundColor Yellow
# Stop any existing kubectl port-forward processes
Get-Process | Where-Object {$_.ProcessName -eq "kubectl"} | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "`nStarting port forwarding for all services..." -ForegroundColor Yellow

# Start port forwarding in background
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/manager", "8081:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/visualiser", "8082:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/acs-grafana", "8083:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/auth", "8084:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/configdb", "8085:80", "-n", "factory-plus-new" -WindowStyle Hidden

Write-Host "`nWaiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host "`n✅ Port forwarding started for all services" -ForegroundColor Green

Write-Host "`n🌐 Service URLs:" -ForegroundColor Cyan
Write-Host "Manager:    http://localhost:8081/login" -ForegroundColor White
Write-Host "Visualiser: http://localhost:8082/" -ForegroundColor White
Write-Host "Grafana:    http://localhost:8083/" -ForegroundColor White
Write-Host "Auth:       http://localhost:8084/" -ForegroundColor White
Write-Host "ConfigDB:   http://localhost:8085/" -ForegroundColor White

Write-Host "`n🔐 Login Credentials:" -ForegroundColor Cyan
Write-Host "Username: admin" -ForegroundColor White
Write-Host "Password: -2HpTgDjNqOXdg6Q48BgSMrllPXAwAfp1B4ABlvn8rg" -ForegroundColor White

Write-Host "`nPress any key to stop port forwarding..." -ForegroundColor Yellow
Read-Host

# Stop port forwarding
Get-Process | Where-Object {$_.ProcessName -eq "kubectl"} | Stop-Process -Force
Write-Host "`n✅ Port forwarding stopped" -ForegroundColor Green
