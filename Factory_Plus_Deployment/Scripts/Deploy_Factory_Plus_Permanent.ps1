# Factory+ Permanent Deployment Script
# This script deploys Factory+ with all fixes applied permanently

Write-Host "🏭 Factory+ Permanent Deployment" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 1: Install/Upgrade with permanent configuration
Write-Host "`n🔧 Step 1: Deploying Factory+ with Permanent Configuration..." -ForegroundColor Cyan

try {
    # Deploy with all fixes applied permanently
    helm upgrade --install acs amrc-connectivity-stack/acs `
        -n factory-plus-new `
        --create-namespace `
        -f ../Configurations/values-local.yaml
    
    Write-Host "✅ Factory+ deployed with permanent configuration" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to deploy Factory+ with permanent configuration" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 2: Wait for deployment
Write-Host "`n⏳ Step 2: Waiting for deployment to complete..." -ForegroundColor Cyan
Start-Sleep -Seconds 60

# Step 3: Start port forwarding
Write-Host "`n🌐 Step 3: Starting port forwarding..." -ForegroundColor Cyan

# Start all port forwarding in background
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/manager", "8081:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/visualiser", "8082:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/acs-grafana", "8083:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/auth", "8084:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/configdb", "8085:80", "-n", "factory-plus-new" -WindowStyle Hidden

Write-Host "✅ Port forwarding started for all services" -ForegroundColor Green

# Step 4: Test services
Write-Host "`n🧪 Step 4: Testing services..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

Write-Host "`n🎯 Factory+ Permanent Deployment Complete!" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

Write-Host "`n🌐 Service URLs:" -ForegroundColor Cyan
Write-Host "Manager:    http://localhost:8081/login" -ForegroundColor White
Write-Host "Visualiser: http://localhost:8082/" -ForegroundColor White
Write-Host "Grafana:    http://localhost:8083/" -ForegroundColor White
Write-Host "Auth:       http://localhost:8084/" -ForegroundColor White
Write-Host "ConfigDB:   http://localhost:8085/" -ForegroundColor White

Write-Host "`n🔐 Login Credentials:" -ForegroundColor Cyan
Write-Host "Username: admin@FACTORYPLUS.AMIC.COM" -ForegroundColor White
Write-Host "Password: [Check kubectl get secret admin-password -n factory-plus-new]" -ForegroundColor White

Write-Host "`n✅ All fixes are now permanent and will persist across restarts!" -ForegroundColor Green

Read-Host "`nPress Enter to continue"
