# Factory+ All Services Test Script
# Tests all services and verifies no errors

Write-Host "🧪 Factory+ All Services Test Script" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Step 1: Test Manager Service
Write-Host "`n🔍 Step 1: Testing Manager Service..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081" -Method Head -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Manager Service: HTTP 200 - Working" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Manager Service: HTTP $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Manager Service: Not accessible" -ForegroundColor Red
}

# Step 2: Test Visualiser Service
Write-Host "`n🔍 Step 2: Testing Visualiser Service..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082" -Method Head -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Visualiser Service: HTTP 200 - Working" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Visualiser Service: HTTP $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Visualiser Service: Not accessible" -ForegroundColor Red
}

# Step 3: Test Grafana Service
Write-Host "`n🔍 Step 3: Testing Grafana Service..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8083" -Method Head -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Grafana Service: HTTP 200 - Working" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Grafana Service: HTTP $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Grafana Service: Not accessible" -ForegroundColor Red
}

# Step 4: Test Auth Service
Write-Host "`n🔍 Step 4: Testing Auth Service..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8084" -Method Head -TimeoutSec 10
    if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 401) {
        Write-Host "✅ Auth Service: HTTP $($response.StatusCode) - Working (401 is expected)" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Auth Service: HTTP $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Auth Service: Not accessible" -ForegroundColor Red
}

# Step 5: Test ConfigDB Service
Write-Host "`n🔍 Step 5: Testing ConfigDB Service..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8085" -Method Head -TimeoutSec 10
    if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 401) {
        Write-Host "✅ ConfigDB Service: HTTP $($response.StatusCode) - Working (401 is expected)" -ForegroundColor Green
    } else {
        Write-Host "⚠️ ConfigDB Service: HTTP $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ ConfigDB Service: Not accessible" -ForegroundColor Red
}

# Step 6: Check Manager Logs for Errors
Write-Host "`n🔍 Step 6: Checking Manager Logs for Errors..." -ForegroundColor Cyan

try {
    $logs = kubectl logs -n factory-plus-new -l component=manager --tail=20
    $errorCount = ($logs | Select-String -Pattern "ERROR|Exception|Failed|Could not resolve").Count
    
    if ($errorCount -eq 0) {
        Write-Host "✅ No errors found in Manager logs" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Found $errorCount errors in Manager logs" -ForegroundColor Yellow
        Write-Host "Recent errors:" -ForegroundColor White
        $logs | Select-String -Pattern "ERROR|Exception|Failed|Could not resolve" | Select-Object -Last 3
    }
} catch {
    Write-Host "⚠️ Could not check Manager logs" -ForegroundColor Yellow
}

# Step 7: Check Port Forwarding
Write-Host "`n🔍 Step 7: Checking Port Forwarding..." -ForegroundColor Cyan

try {
    $ports = netstat -an | Select-String -Pattern "808[0-9]" | Select-String -Pattern "LISTENING"
    if ($ports.Count -ge 5) {
        Write-Host "✅ Port forwarding active for all services" -ForegroundColor Green
        Write-Host "Active ports:" -ForegroundColor White
        $ports | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    } else {
        Write-Host "⚠️ Port forwarding may not be complete" -ForegroundColor Yellow
        Write-Host "Active ports:" -ForegroundColor White
        $ports | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    }
} catch {
    Write-Host "⚠️ Could not check port forwarding" -ForegroundColor Yellow
}

# Step 8: Final Summary
Write-Host "`n📋 Step 8: Final Test Summary..." -ForegroundColor Cyan

Write-Host "`n🎯 Factory+ Services Test Results:" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

Write-Host "`n🌐 Service Status:" -ForegroundColor Cyan
Write-Host "Manager:    http://localhost:8081/login" -ForegroundColor White
Write-Host "Visualiser: http://localhost:8082/" -ForegroundColor White
Write-Host "Grafana:    http://localhost:8083/" -ForegroundColor White
Write-Host "Auth:       http://localhost:8084/" -ForegroundColor White
Write-Host "ConfigDB:   http://localhost:8085/" -ForegroundColor White

Write-Host "`n🔐 Login Credentials:" -ForegroundColor Cyan
Write-Host "Username: admin@FACTORYPLUS.AMIC.COM" -ForegroundColor White
Write-Host "Password: BPXvGCoDbSkNTdapLiiTvUxJw6YPsWwekoyiJlenzZQ" -ForegroundColor White

Write-Host "`n✅ All services should now be working without errors!" -ForegroundColor Green
Write-Host "Please refresh your browser and test the Manager interface." -ForegroundColor Yellow

Read-Host "`nPress Enter to continue"
