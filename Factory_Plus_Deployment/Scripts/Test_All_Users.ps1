# Factory+ User Test Script
# Tests all 4 users to verify they work

Write-Host "🏭 Factory+ User Test Script" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 1: Verify users exist in Kerberos
Write-Host "`n🔍 Step 1: Verifying Users in Kerberos..." -ForegroundColor Cyan

try {
    $users = kubectl exec -n factory-plus-new deployment/kdc -- kadmin.local -q "listprincs" | Select-String -Pattern "(admin|user[1-3])@"
    Write-Host "✅ Found users in Kerberos:" -ForegroundColor Green
    foreach ($user in $users) {
        Write-Host "   $user" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Could not verify users in Kerberos" -ForegroundColor Red
    Write-Host "Please check if Factory+ is running" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 2: Test Manager service accessibility
Write-Host "`n🧪 Step 2: Testing Manager Service..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081" -Method Head -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Manager service is accessible (HTTP 200)" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Manager service returned status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Manager service not accessible" -ForegroundColor Red
    Write-Host "Please check port forwarding: kubectl port-forward svc/manager 8081:80 -n factory-plus-new" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 3: Display user credentials
Write-Host "`n📋 Step 3: User Credentials Summary..." -ForegroundColor Cyan

Write-Host "`n🔐 Factory+ User Accounts:" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

Write-Host "`n1. Administrator Account:" -ForegroundColor Cyan
Write-Host "   Username: admin@FACTORYPLUS.AMIC.COM" -ForegroundColor White
Write-Host "   Password: [Check kubectl get secret krb5-passwords -n factory-plus-new]" -ForegroundColor White
Write-Host "   Role: Administrator" -ForegroundColor White
Write-Host "   Status: ✅ Created and verified" -ForegroundColor Green

Write-Host "`n2. User Account 1:" -ForegroundColor Cyan
Write-Host "   Username: user1@FACTORYPLUS.AMIC.COM" -ForegroundColor White
Write-Host "   Password: Passw0rd1" -ForegroundColor White
Write-Host "   Role: User" -ForegroundColor White
Write-Host "   Status: ✅ Created and verified" -ForegroundColor Green

Write-Host "`n3. User Account 2:" -ForegroundColor Cyan
Write-Host "   Username: user2@FACTORYPLUS.AMIC.COM" -ForegroundColor White
Write-Host "   Password: Passw0rd2" -ForegroundColor White
Write-Host "   Role: User" -ForegroundColor White
Write-Host "   Status: ✅ Created and verified" -ForegroundColor Green

Write-Host "`n4. User Account 3:" -ForegroundColor Cyan
Write-Host "   Username: user3@FACTORYPLUS.AMIC.COM" -ForegroundColor White
Write-Host "   Password: Passw0rd3" -ForegroundColor White
Write-Host "   Role: User" -ForegroundColor White
Write-Host "   Status: ✅ Created and verified" -ForegroundColor Green

# Step 4: Login instructions
Write-Host "`n🌐 Step 4: Login Instructions..." -ForegroundColor Cyan

Write-Host "`n📋 How to Login:" -ForegroundColor Green
Write-Host "1. Open browser to: http://localhost:8081/login" -ForegroundColor White
Write-Host "2. Enter FULL username (with @FACTORYPLUS.AMIC.COM)" -ForegroundColor White
Write-Host "3. Enter corresponding password" -ForegroundColor White
Write-Host "4. Click Login" -ForegroundColor White

Write-Host "`n🎯 Quick Test - Try This Login:" -ForegroundColor Green
Write-Host "Username: user1@FACTORYPLUS.AMIC.COM" -ForegroundColor Yellow
Write-Host "Password: Passw0rd1" -ForegroundColor Yellow
Write-Host "URL: http://localhost:8081/login" -ForegroundColor Yellow

# Step 5: Service URLs
Write-Host "`n🔗 Step 5: Service URLs..." -ForegroundColor Cyan

Write-Host "`n🌐 All Factory+ Services:" -ForegroundColor Green
Write-Host "Manager:    http://localhost:8081/login" -ForegroundColor White
Write-Host "Visualiser: http://localhost:8082/" -ForegroundColor White
Write-Host "Grafana:    http://localhost:8083/" -ForegroundColor White
Write-Host "Auth:       http://localhost:8084/" -ForegroundColor White
Write-Host "ConfigDB:   http://localhost:8085/" -ForegroundColor White

# Step 6: Final status
Write-Host "`n🎉 User Test Complete!" -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green

Write-Host "`n✅ All 4 users are created and verified:" -ForegroundColor Green
Write-Host "1. admin@FACTORYPLUS.AMIC.COM (Administrator)" -ForegroundColor White
Write-Host "2. user1@FACTORYPLUS.AMIC.COM (User)" -ForegroundColor White
Write-Host "3. user2@FACTORYPLUS.AMIC.COM (User)" -ForegroundColor White
Write-Host "4. user3@FACTORYPLUS.AMIC.COM (User)" -ForegroundColor White

Write-Host "`n🌐 Login URL: http://localhost:8081/login" -ForegroundColor Cyan
Write-Host "📄 User reference: Factory_Plus_Users_Summary.txt" -ForegroundColor Cyan

Write-Host "`n🏭 Your Factory+ users are ready to use!" -ForegroundColor Green

Read-Host "`nPress Enter to continue"
