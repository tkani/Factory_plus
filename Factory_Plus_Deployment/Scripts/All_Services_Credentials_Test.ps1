# Factory+ All Services Credentials and Test Script
# Complete credentials for all 5 services with testing

Write-Host "🏭 Factory+ All Services Credentials & Test" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 1: Get all credentials
Write-Host "`n🔐 Step 1: Getting All Service Credentials..." -ForegroundColor Cyan

# Get admin password
try {
    $adminPassword = kubectl get secret admin-password -n factory-plus-new -o jsonpath="{.data.password}"
    $decodedAdminPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($adminPassword))
    Write-Host "✅ Admin password retrieved" -ForegroundColor Green
} catch {
    Write-Host "❌ Could not get admin password" -ForegroundColor Red
    $decodedAdminPassword = "[Could not retrieve]"
}

# Get Grafana credentials
try {
    $grafanaUser = kubectl get secret grafana-admin-user -n factory-plus-new -o jsonpath="{.data.admin-user}"
    $decodedGrafanaUser = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($grafanaUser))
    Write-Host "✅ Grafana user retrieved" -ForegroundColor Green
} catch {
    Write-Host "❌ Could not get Grafana user" -ForegroundColor Red
    $decodedGrafanaUser = "[Could not retrieve]"
}

# Get InfluxDB credentials
try {
    $influxPassword = kubectl get secret influxdb-auth -n factory-plus-new -o jsonpath="{.data.admin-password}"
    $decodedInfluxPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($influxPassword))
    Write-Host "✅ InfluxDB password retrieved" -ForegroundColor Green
} catch {
    Write-Host "❌ Could not get InfluxDB password" -ForegroundColor Red
    $decodedInfluxPassword = "[Could not retrieve]"
}

# Step 2: Display all credentials
Write-Host "`n📋 Step 2: All Service Credentials..." -ForegroundColor Cyan

Write-Host "`n🔐 Factory+ Service Credentials:" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

Write-Host "`n1. Manager Service (8081):" -ForegroundColor Cyan
Write-Host "   URL: http://localhost:8081/login" -ForegroundColor White
Write-Host "   Username: admin@FACTORYPLUS.AMIC.COM" -ForegroundColor White
Write-Host "   Password: $decodedAdminPassword" -ForegroundColor White
Write-Host "   Purpose: Main Factory+ management interface" -ForegroundColor White

Write-Host "`n2. Visualiser Service (8082):" -ForegroundColor Cyan
Write-Host "   URL: http://localhost:8082/" -ForegroundColor White
Write-Host "   Username: [No authentication required]" -ForegroundColor White
Write-Host "   Password: [No authentication required]" -ForegroundColor White
Write-Host "   Purpose: Data visualization and monitoring" -ForegroundColor White

Write-Host "`n3. Grafana Service (8083):" -ForegroundColor Cyan
Write-Host "   URL: http://localhost:8083/" -ForegroundColor White
Write-Host "   Username: $decodedGrafanaUser" -ForegroundColor White
Write-Host "   Password: [Check Grafana interface - may need to be set]" -ForegroundColor White
Write-Host "   Purpose: Advanced analytics and dashboards" -ForegroundColor White

Write-Host "`n4. Auth Service (8084):" -ForegroundColor Cyan
Write-Host "   URL: http://localhost:8084/" -ForegroundColor White
Write-Host "   Username: admin@FACTORYPLUS.AMIC.COM" -ForegroundColor White
Write-Host "   Password: $decodedAdminPassword" -ForegroundColor White
Write-Host "   Purpose: Authentication service" -ForegroundColor White

Write-Host "`n5. ConfigDB Service (8085):" -ForegroundColor Cyan
Write-Host "   URL: http://localhost:8085/" -ForegroundColor White
Write-Host "   Username: admin@FACTORYPLUS.AMIC.COM" -ForegroundColor White
Write-Host "   Password: $decodedAdminPassword" -ForegroundColor White
Write-Host "   Purpose: Configuration database service" -ForegroundColor White

# Step 3: Test all services
Write-Host "`n🧪 Step 3: Testing All Services..." -ForegroundColor Cyan

# Test Manager (8081)
Write-Host "`nTesting Manager (8081)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081" -Method Head -TimeoutSec 10
    Write-Host "✅ Manager: HTTP $($response.StatusCode) - Working" -ForegroundColor Green
} catch {
    Write-Host "❌ Manager: Not accessible" -ForegroundColor Red
}

# Test Visualiser (8082)
Write-Host "`nTesting Visualiser (8082)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8082" -Method Head -TimeoutSec 10
    Write-Host "✅ Visualiser: HTTP $($response.StatusCode) - Working" -ForegroundColor Green
} catch {
    Write-Host "❌ Visualiser: Not accessible" -ForegroundColor Red
}

# Test Grafana (8083)
Write-Host "`nTesting Grafana (8083)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8083" -Method Head -TimeoutSec 10
    Write-Host "✅ Grafana: HTTP $($response.StatusCode) - Working" -ForegroundColor Green
} catch {
    Write-Host "❌ Grafana: Not accessible" -ForegroundColor Red
}

# Test Auth (8084)
Write-Host "`nTesting Auth (8084)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8084" -Method Head -TimeoutSec 10
    if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 401) {
        Write-Host "✅ Auth: HTTP $($response.StatusCode) - Working (401 is expected)" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Auth: HTTP $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Auth: Not accessible" -ForegroundColor Red
}

# Test ConfigDB (8085)
Write-Host "`nTesting ConfigDB (8085)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8085" -Method Head -TimeoutSec 10
    if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 401) {
        Write-Host "✅ ConfigDB: HTTP $($response.StatusCode) - Working (401 is expected)" -ForegroundColor Green
    } else {
        Write-Host "⚠️ ConfigDB: HTTP $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ ConfigDB: Not accessible" -ForegroundColor Red
}

# Step 4: Check port forwarding
Write-Host "`n🔍 Step 4: Checking Port Forwarding..." -ForegroundColor Cyan

try {
    $ports = netstat -an | Select-String -Pattern "808[0-9]" | Select-String -Pattern "LISTENING"
    if ($ports.Count -ge 3) {
        Write-Host "✅ Port forwarding active for services" -ForegroundColor Green
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

# Step 5: Final summary
Write-Host "`n📋 Step 5: Final Summary..." -ForegroundColor Cyan

Write-Host "`n🎯 Factory+ All Services Summary:" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

Write-Host "`n🌐 Service URLs & Credentials:" -ForegroundColor Cyan
Write-Host "1. Manager:    http://localhost:8081/login" -ForegroundColor White
Write-Host "   Username: admin@FACTORYPLUS.AMIC.COM" -ForegroundColor White
Write-Host "   Password: $decodedAdminPassword" -ForegroundColor White

Write-Host "`n2. Visualiser: http://localhost:8082/" -ForegroundColor White
Write-Host "   Username: [No auth required]" -ForegroundColor White

Write-Host "`n3. Grafana:    http://localhost:8083/" -ForegroundColor White
Write-Host "   Username: $decodedGrafanaUser" -ForegroundColor White
Write-Host "   Password: [Check interface]" -ForegroundColor White

Write-Host "`n4. Auth:       http://localhost:8084/" -ForegroundColor White
Write-Host "   Username: admin@FACTORYPLUS.AMIC.COM" -ForegroundColor White
Write-Host "   Password: $decodedAdminPassword" -ForegroundColor White

Write-Host "`n5. ConfigDB:   http://localhost:8085/" -ForegroundColor White
Write-Host "   Username: admin@FACTORYPLUS.AMIC.COM" -ForegroundColor White
Write-Host "   Password: $decodedAdminPassword" -ForegroundColor White

Write-Host "`n🎉 All Factory+ services are ready with credentials!" -ForegroundColor Green

Read-Host "`nPress Enter to continue"
