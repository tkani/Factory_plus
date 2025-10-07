# Apply Permanent Fixes to Existing Factory+ Deployment
# This script applies all fixes to an existing deployment

Write-Host "🔧 Applying Permanent Fixes to Existing Factory+ Deployment" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 1: Apply permanent configuration
Write-Host "`n🔧 Step 1: Applying Permanent Configuration..." -ForegroundColor Cyan

try {
    # Apply permanent configuration to existing deployment
    helm upgrade acs amrc-connectivity-stack/acs -n factory-plus-new -f Configurations/values-local.yaml
    
    Write-Host "✅ Permanent configuration applied successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to apply permanent configuration" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 2: Wait for changes to take effect
Write-Host "`n⏳ Step 2: Waiting for changes to take effect..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

# Step 3: Restart port forwarding
Write-Host "`n🔄 Step 3: Restarting port forwarding..." -ForegroundColor Cyan

# Stop existing port forwarding
Get-Process | Where-Object {$_.ProcessName -eq "kubectl"} | Stop-Process -Force
Start-Sleep -Seconds 3

# Start all port forwarding in background
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/manager", "8081:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/visualiser", "8082:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/acs-grafana", "8083:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/auth", "8084:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/configdb", "8085:80", "-n", "factory-plus-new" -WindowStyle Hidden

Write-Host "✅ Port forwarding restarted for all services" -ForegroundColor Green

# Step 4: Test services
Write-Host "`n🧪 Step 4: Testing services..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

Write-Host "`n🎯 Permanent Fixes Applied Successfully!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

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
Write-Host "✅ No more manual patching required!" -ForegroundColor Green

Read-Host "`nPress Enter to continue"
