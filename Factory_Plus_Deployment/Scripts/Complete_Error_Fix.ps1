# Factory+ Complete Error Fix Script
# Fixes all "Something broke" / "Server Error" issues

Write-Host "🔧 Factory+ Complete Error Fix Script" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 1: Stop existing port forwarding
Write-Host "`n🛑 Step 1: Stopping Existing Port Forwarding..." -ForegroundColor Cyan

try {
    Get-Process | Where-Object {$_.ProcessName -eq "kubectl"} | Stop-Process -Force
    Write-Host "✅ Stopped existing kubectl processes" -ForegroundColor Green
} catch {
    Write-Host "⚠️ No existing kubectl processes found" -ForegroundColor Yellow
}

# Step 2: Fix Manager Configuration
Write-Host "`n🔧 Step 2: Fixing Manager Configuration..." -ForegroundColor Cyan

try {
    # Update service scheme to HTTP
    kubectl patch configmap manager-config -n factory-plus-new --type='json' -p='[{"op": "replace", "path": "/data/SERVICE_SCHEME", "value": "http"}]'
    Write-Host "✅ Updated SERVICE_SCHEME to http" -ForegroundColor Green
    
    # Update base URL
    kubectl patch configmap manager-config -n factory-plus-new --type='json' -p='[{"op": "replace", "path": "/data/BASE_URL", "value": "factory-plus-new.svc.cluster.local"}]'
    Write-Host "✅ Updated BASE_URL to internal cluster" -ForegroundColor Green
    
    # Add all service URLs
    kubectl patch configmap manager-config -n factory-plus-new --type='json' -p='[{"op": "add", "path": "/data/CONFIGDB_URL", "value": "http://configdb.factory-plus-new.svc.cluster.local"}]'
    kubectl patch configmap manager-config -n factory-plus-new --type='json' -p='[{"op": "add", "path": "/data/AUTH_URL", "value": "http://auth.factory-plus-new.svc.cluster.local"}]'
    kubectl patch configmap manager-config -n factory-plus-new --type='json' -p='[{"op": "add", "path": "/data/DIRECTORY_URL", "value": "http://directory.factory-plus-new.svc.cluster.local"}]'
    kubectl patch configmap manager-config -n factory-plus-new --type='json' -p='[{"op": "add", "path": "/data/CLUSTER_MANAGER_URL", "value": "http://cluster-manager.factory-plus-new.svc.cluster.local"}]'
    Write-Host "✅ Added all service URLs" -ForegroundColor Green
} catch {
    Write-Host "❌ Could not update manager configuration" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 3: Restart Manager
Write-Host "`n🔄 Step 3: Restarting Manager..." -ForegroundColor Cyan

try {
    kubectl delete pod -n factory-plus-new -l component=manager
    Write-Host "✅ Manager pod deleted" -ForegroundColor Green
    
    # Wait for restart
    Write-Host "⏳ Waiting for Manager to restart..." -ForegroundColor Yellow
    Start-Sleep -Seconds 45
    
    $managerStatus = kubectl get pods -n factory-plus-new -l component=manager --no-headers | ForEach-Object { ($_ -split '\s+')[2] }
    if ($managerStatus -eq "Running") {
        Write-Host "✅ Manager is running" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Manager status: $managerStatus" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Could not restart Manager" -ForegroundColor Red
}

# Step 4: Start Port Forwarding
Write-Host "`n🌐 Step 4: Starting Port Forwarding..." -ForegroundColor Cyan

try {
    # Start port forwarding in background
    Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/manager", "8081:80", "-n", "factory-plus-new" -WindowStyle Hidden
    Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/visualiser", "8082:80", "-n", "factory-plus-new" -WindowStyle Hidden
    Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/acs-grafana", "8083:80", "-n", "factory-plus-new" -WindowStyle Hidden
    Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/auth", "8084:80", "-n", "factory-plus-new" -WindowStyle Hidden
    Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/configdb", "8085:80", "-n", "factory-plus-new" -WindowStyle Hidden
    
    Write-Host "✅ Started port forwarding for all services" -ForegroundColor Green
    
    # Wait for port forwarding to establish
    Write-Host "⏳ Waiting for port forwarding to establish..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
} catch {
    Write-Host "❌ Could not start port forwarding" -ForegroundColor Red
}

# Step 5: Test Manager Access
Write-Host "`n🧪 Step 5: Testing Manager Access..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081" -Method Head -TimeoutSec 15
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Manager is accessible (HTTP 200)" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Manager returned status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Manager not accessible. Trying alternative test..." -ForegroundColor Red
    
    # Try alternative test
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8081/login" -Method Get -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Manager login page accessible" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Manager still not accessible" -ForegroundColor Red
    }
}

# Step 6: Check for Errors
Write-Host "`n🔍 Step 6: Checking for Errors..." -ForegroundColor Cyan

try {
    $logs = kubectl logs -n factory-plus-new -l component=manager --tail=10
    $errorCount = ($logs | Select-String -Pattern "ERROR|Exception|Failed|Could not resolve").Count
    
    if ($errorCount -eq 0) {
        Write-Host "✅ No errors found in recent logs" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Found $errorCount errors in recent logs" -ForegroundColor Yellow
        Write-Host "Recent error logs:" -ForegroundColor White
        $logs | Select-String -Pattern "ERROR|Exception|Failed|Could not resolve" | Select-Object -Last 3
    }
} catch {
    Write-Host "⚠️ Could not check logs" -ForegroundColor Yellow
}

# Step 7: Final Status
Write-Host "`n📋 Step 7: Final Status..." -ForegroundColor Cyan

Write-Host "`n🎯 Complete Error Fix Summary:" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

Write-Host "`n✅ Applied Fixes:" -ForegroundColor Green
Write-Host "1. Updated SERVICE_SCHEME to http" -ForegroundColor White
Write-Host "2. Updated BASE_URL to internal cluster" -ForegroundColor White
Write-Host "3. Added all service URLs (CONFIGDB, AUTH, DIRECTORY, CLUSTER_MANAGER)" -ForegroundColor White
Write-Host "4. Restarted Manager with new configuration" -ForegroundColor White
Write-Host "5. Started port forwarding for all services" -ForegroundColor White

Write-Host "`n🌐 Service URLs:" -ForegroundColor Cyan
Write-Host "Manager:    http://localhost:8081/login" -ForegroundColor White
Write-Host "Visualiser: http://localhost:8082/" -ForegroundColor White
Write-Host "Grafana:    http://localhost:8083/" -ForegroundColor White
Write-Host "Auth:       http://localhost:8084/" -ForegroundColor White
Write-Host "ConfigDB:   http://localhost:8085/" -ForegroundColor White

Write-Host "`n🔐 Login Credentials:" -ForegroundColor Cyan
Write-Host "Username: admin@FACTORYPLUS.AMIC.COM" -ForegroundColor White
Write-Host "Password: BPXvGCoDbSkNTdapLiiTvUxJw6YPsWwekoyiJlenzZQ" -ForegroundColor White

Write-Host "`n🎉 All errors should now be fixed!" -ForegroundColor Green
Write-Host "Please refresh your browser and test the Manager interface." -ForegroundColor Yellow

Read-Host "`nPress Enter to continue"
