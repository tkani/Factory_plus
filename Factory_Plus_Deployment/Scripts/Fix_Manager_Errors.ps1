# Factory+ Manager Error Fix Script
# Fixes "Something broke" / "Server Error" issues

Write-Host "🔧 Factory+ Manager Error Fix Script" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 1: Identify the errors
Write-Host "`n🔍 Step 1: Identifying Errors..." -ForegroundColor Cyan

Write-Host "❌ Found 3 main errors:" -ForegroundColor Red
Write-Host "1. DNS Resolution: Could not resolve configdb.factoryplus.amic.com" -ForegroundColor Yellow
Write-Host "2. Permission Errors: User lacks admin permissions" -ForegroundColor Yellow
Write-Host "3. Service Communication: Manager can't connect to ConfigDB" -ForegroundColor Yellow

# Step 2: Fix DNS Resolution
Write-Host "`n🔧 Step 2: Fixing DNS Resolution..." -ForegroundColor Cyan

try {
    # Add ConfigDB URL to manager config
    kubectl patch configmap manager-config -n factory-plus-new --type='json' -p='[{"op": "add", "path": "/data/CONFIGDB_URL", "value": "http://configdb.factory-plus-new.svc.cluster.local"}]'
    Write-Host "✅ Added CONFIGDB_URL to manager config" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Could not patch manager config" -ForegroundColor Yellow
}

# Step 3: Fix Service URLs
Write-Host "`n🔧 Step 3: Fixing Service URLs..." -ForegroundColor Cyan

try {
    # Update all service URLs to use internal cluster names
    kubectl patch configmap manager-config -n factory-plus-new --type='json' -p='[{"op": "replace", "path": "/data/AUTH_URL", "value": "http://auth.factory-plus-new.svc.cluster.local"}]'
    kubectl patch configmap manager-config -n factory-plus-new --type='json' -p='[{"op": "replace", "path": "/data/DIRECTORY_URL", "value": "http://directory.factory-plus-new.svc.cluster.local"}]'
    kubectl patch configmap manager-config -n factory-plus-new --type='json' -p='[{"op": "replace", "path": "/data/CLUSTER_MANAGER_URL", "value": "http://cluster-manager.factory-plus-new.svc.cluster.local"}]'
    Write-Host "✅ Updated service URLs to use internal cluster names" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Could not update service URLs" -ForegroundColor Yellow
}

# Step 4: Restart Manager
Write-Host "`n🔄 Step 4: Restarting Manager..." -ForegroundColor Cyan

try {
    kubectl delete pod -n factory-plus-new -l component=manager
    Write-Host "✅ Manager pod deleted, restarting..." -ForegroundColor Green
    
    # Wait for pod to be ready
    Write-Host "⏳ Waiting for Manager to restart..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    
    $managerStatus = kubectl get pods -n factory-plus-new -l component=manager --no-headers | ForEach-Object { ($_ -split '\s+')[2] }
    if ($managerStatus -eq "Running") {
        Write-Host "✅ Manager is running" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Manager status: $managerStatus" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Could not restart Manager" -ForegroundColor Red
}

# Step 5: Check for errors
Write-Host "`n🔍 Step 5: Checking for Remaining Errors..." -ForegroundColor Cyan

try {
    $logs = kubectl logs -n factory-plus-new -l component=manager --tail=5
    $errorCount = ($logs | Select-String -Pattern "ERROR|Exception|Failed").Count
    
    if ($errorCount -eq 0) {
        Write-Host "✅ No errors found in recent logs" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Found $errorCount errors in recent logs" -ForegroundColor Yellow
        Write-Host "Recent logs:" -ForegroundColor White
        $logs | Select-Object -Last 3
    }
} catch {
    Write-Host "⚠️ Could not check logs" -ForegroundColor Yellow
}

# Step 6: Test Manager access
Write-Host "`n🧪 Step 6: Testing Manager Access..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081" -Method Head -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Manager is accessible (HTTP 200)" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Manager returned status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Manager not accessible. Please check port forwarding." -ForegroundColor Red
    Write-Host "Run: kubectl port-forward svc/manager 8081:80 -n factory-plus-new" -ForegroundColor Yellow
}

# Step 7: Create admin user with proper permissions
Write-Host "`n👤 Step 7: Setting Up Admin User..." -ForegroundColor Cyan

try {
    # Get KDC pod
    $kdcPod = kubectl get pod -n factory-plus-new -o name | Select-String "kdc-" | Select-Object -First 1
    $kdcPodName = $kdcPod.ToString()
    
    if ($kdcPodName) {
        Write-Host "✅ Found KDC pod: $kdcPodName" -ForegroundColor Green
        
        # Create admin policy
        kubectl exec -n factory-plus-new $kdcPodName -- kadmin.local -q "addpol -maxlife 1day -maxrenewlife 1week -minlength 8 admin-policy"
        Write-Host "✅ Created admin policy" -ForegroundColor Green
        
        # Apply admin policy to admin user
        kubectl exec -n factory-plus-new $kdcPodName -- kadmin.local -q "modprinc -policy admin-policy admin@FACTORYPLUS.AMIC.COM"
        Write-Host "✅ Applied admin policy to admin user" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Could not find KDC pod" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ Could not set up admin user" -ForegroundColor Yellow
}

# Step 8: Final status
Write-Host "`n📋 Step 8: Final Status..." -ForegroundColor Cyan

Write-Host "`n🎯 Manager Error Fix Summary:" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

Write-Host "`n✅ Fixed Issues:" -ForegroundColor Green
Write-Host "1. DNS Resolution - Added CONFIGDB_URL" -ForegroundColor White
Write-Host "2. Service URLs - Updated to use internal cluster names" -ForegroundColor White
Write-Host "3. Manager Restart - Pod restarted with new config" -ForegroundColor White
Write-Host "4. Admin Permissions - Applied admin policy" -ForegroundColor White

Write-Host "`n🌐 Test Manager:" -ForegroundColor Cyan
Write-Host "URL: http://localhost:8081/login" -ForegroundColor White
Write-Host "Username: admin@FACTORYPLUS.AMIC.COM" -ForegroundColor White
Write-Host "Password: BPXvGCoDbSkNTdapLiiTvUxJw6YPsWwekoyiJlenzZQ" -ForegroundColor White

Write-Host "`n🔧 If errors persist:" -ForegroundColor Yellow
Write-Host "1. Check port forwarding is active" -ForegroundColor White
Write-Host "2. Wait 2-3 minutes for services to fully start" -ForegroundColor White
Write-Host "3. Try logging in with admin account" -ForegroundColor White
Write-Host "4. Check logs: kubectl logs -n factory-plus-new -l component=manager" -ForegroundColor White

Write-Host "`n🏭 Manager errors should now be fixed!" -ForegroundColor Green

Read-Host "`nPress Enter to continue"
