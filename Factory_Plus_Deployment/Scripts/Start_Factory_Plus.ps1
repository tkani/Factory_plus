# Factory+ Quick Start Script
# Run this every time you start your laptop

Write-Host "🏭 Starting Factory+ Services..." -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Start Minikube if not running
Write-Host "🚀 Starting Minikube..." -ForegroundColor Cyan
$minikubeStatus = minikube status --format="json" | ConvertFrom-Json
if ($minikubeStatus.Host -ne "Running") {
    Write-Host "Starting Minikube cluster..." -ForegroundColor Yellow
    minikube start --memory=8192 --cpus=4 --disk-size=50g
} else {
    Write-Host "✅ Minikube is already running" -ForegroundColor Green
}

# Wait for cluster to be ready
Write-Host "⏳ Waiting for cluster to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Start port forwarding
Write-Host "🔗 Starting port forwarding..." -ForegroundColor Cyan

# Kill any existing port forwarding
Get-Process | Where-Object {$_.ProcessName -eq "kubectl"} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Start all services
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/manager", "8081:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/visualiser", "8082:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/acs-grafana", "8083:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/auth", "8084:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/configdb", "8085:80", "-n", "factory-plus" -WindowStyle Hidden

Write-Host "✅ Port forwarding started" -ForegroundColor Green

# Wait for services to be ready
Write-Host "⏳ Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Display access information
Write-Host "`n🎉 Factory+ Services Started!" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

Write-Host "`n🌐 Service URLs:" -ForegroundColor Cyan
Write-Host "Manager:    http://localhost:8081/login" -ForegroundColor White
Write-Host "Visualiser: http://localhost:8082/" -ForegroundColor White
Write-Host "Grafana:    http://localhost:8083/" -ForegroundColor White
Write-Host "Auth:       http://localhost:8084/" -ForegroundColor White
Write-Host "ConfigDB:   http://localhost:8085/" -ForegroundColor White

Write-Host "`n🔐 Login Credentials:" -ForegroundColor Cyan
try {
    $adminPassword = kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus
    $decodedPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($adminPassword))
    Write-Host "Username: admin" -ForegroundColor White
    Write-Host "Password: $decodedPassword" -ForegroundColor White
} catch {
    Write-Host "Username: admin" -ForegroundColor White
    Write-Host "Password: [Check kubectl get secret krb5-passwords -n factory-plus]" -ForegroundColor Yellow
}

Write-Host "`n⏹️ To stop all services:" -ForegroundColor Cyan
Write-Host "Get-Process | Where-Object {`$_.ProcessName -eq \"kubectl\"} | Stop-Process -Force" -ForegroundColor White

Write-Host "`n🏭 Factory+ is ready to use!" -ForegroundColor Green
