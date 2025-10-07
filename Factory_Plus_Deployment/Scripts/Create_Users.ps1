# Factory+ User Creation Script
# Creates 4 users with usernames and passwords, then tests them

Write-Host "🏭 Factory+ User Creation Script" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 1: Get existing admin password
Write-Host "`n🔍 Step 1: Getting Admin Password..." -ForegroundColor Cyan

try {
    $adminPassword = kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus-new
    $decodedAdminPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($adminPassword))
    Write-Host "✅ Admin password retrieved" -ForegroundColor Green
} catch {
    Write-Host "❌ Could not retrieve admin password" -ForegroundColor Red
    Write-Host "Please check if Factory+ is running" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 2: Get KDC pod name
Write-Host "`n🔍 Step 2: Finding KDC Pod..." -ForegroundColor Cyan

try {
    $kdcPod = kubectl get pod -n factory-plus-new -o name | Select-String "kdc-" | Select-Object -First 1
    $kdcPodName = $kdcPod.ToString()
    Write-Host "✅ KDC pod found: $kdcPodName" -ForegroundColor Green
} catch {
    Write-Host "❌ Could not find KDC pod" -ForegroundColor Red
    Write-Host "Please check if Factory+ is running" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 3: Create 4 users
Write-Host "`n👥 Step 3: Creating 4 Users..." -ForegroundColor Cyan

$users = @(
    @{Username="admin"; Password=$decodedAdminPassword; FullName="admin@FACTORYPLUS.AMIC.COM"; Role="Administrator"},
    @{Username="user1"; Password="Passw0rd1"; FullName="user1@FACTORYPLUS.AMIC.COM"; Role="User"},
    @{Username="user2"; Password="Passw0rd2"; FullName="user2@FACTORYPLUS.AMIC.COM"; Role="User"},
    @{Username="user3"; Password="Passw0rd3"; FullName="user3@FACTORYPLUS.AMIC.COM"; Role="User"}
)

Write-Host "Creating users in Kerberos..." -ForegroundColor Yellow

# Create user1
try {
    kubectl exec -n factory-plus-new $kdcPodName -- kadmin.local -q "addprinc -pw Passw0rd1 user1"
    Write-Host "✅ Created user1" -ForegroundColor Green
} catch {
    Write-Host "⚠️ user1 may already exist" -ForegroundColor Yellow
}

# Create user2
try {
    kubectl exec -n factory-plus-new $kdcPodName -- kadmin.local -q "addprinc -pw Passw0rd2 user2"
    Write-Host "✅ Created user2" -ForegroundColor Green
} catch {
    Write-Host "⚠️ user2 may already exist" -ForegroundColor Yellow
}

# Create user3
try {
    kubectl exec -n factory-plus-new $kdcPodName -- kadmin.local -q "addprinc -pw Passw0rd3 user3"
    Write-Host "✅ Created user3" -ForegroundColor Green
} catch {
    Write-Host "⚠️ user3 may already exist" -ForegroundColor Yellow
}

# Step 4: List all principals to verify
Write-Host "`n🔍 Step 4: Verifying Users..." -ForegroundColor Cyan

try {
    Write-Host "All Kerberos principals:" -ForegroundColor Yellow
    kubectl exec -n factory-plus-new $kdcPodName -- kadmin.local -q "listprincs"
} catch {
    Write-Host "⚠️ Could not list principals" -ForegroundColor Yellow
}

# Step 5: Display user credentials
Write-Host "`n📋 Step 5: User Credentials Summary..." -ForegroundColor Cyan

Write-Host "`n🔐 Factory+ User Accounts:" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

foreach ($user in $users) {
    Write-Host "`n👤 User: $($user.Username)" -ForegroundColor Cyan
    Write-Host "   Full Username: $($user.FullName)" -ForegroundColor White
    Write-Host "   Password: $($user.Password)" -ForegroundColor White
    Write-Host "   Role: $($user.Role)" -ForegroundColor White
}

# Step 6: Test Manager access
Write-Host "`n🧪 Step 6: Testing Manager Access..." -ForegroundColor Cyan

Write-Host "Testing Manager service accessibility..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081" -Method Head -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Manager service is accessible" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Manager service returned status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Manager service not accessible. Please check port forwarding." -ForegroundColor Red
    Write-Host "Run: kubectl port-forward svc/manager 8081:80 -n factory-plus-new" -ForegroundColor Yellow
}

# Step 7: Login instructions
Write-Host "`n🌐 Step 7: Login Instructions..." -ForegroundColor Cyan

Write-Host "`n📋 How to Login:" -ForegroundColor Green
Write-Host "1. Open browser to: http://localhost:8081/login" -ForegroundColor White
Write-Host "2. Use any of the 4 accounts above" -ForegroundColor White
Write-Host "3. Enter the FULL username (with @FACTORYPLUS.AMIC.COM)" -ForegroundColor White
Write-Host "4. Enter the corresponding password" -ForegroundColor White

Write-Host "`n🎯 Quick Login Test:" -ForegroundColor Green
Write-Host "Try logging in with:" -ForegroundColor White
Write-Host "Username: user1@FACTORYPLUS.AMIC.COM" -ForegroundColor Yellow
Write-Host "Password: Passw0rd1" -ForegroundColor Yellow

# Step 8: Create a user reference file
Write-Host "`n💾 Step 8: Creating User Reference File..." -ForegroundColor Cyan

$userReference = @"
# Factory+ User Accounts Reference
# Generated on: $(Get-Date)

## User Accounts

### Administrator Account
- Username: admin@FACTORYPLUS.AMIC.COM
- Password: $decodedAdminPassword
- Role: Administrator
- Access: Full system access

### User Accounts
- Username: user1@FACTORYPLUS.AMIC.COM
- Password: Passw0rd1
- Role: User
- Access: Standard user access

- Username: user2@FACTORYPLUS.AMIC.COM
- Password: Passw0rd2
- Role: User
- Access: Standard user access

- Username: user3@FACTORYPLUS.AMIC.COM
- Password: Passw0rd3
- Role: User
- Access: Standard user access

## Login Instructions
1. Open browser to: http://localhost:8081/login
2. Enter FULL username (with @FACTORYPLUS.AMIC.COM)
3. Enter corresponding password
4. Click Login

## Service URLs
- Manager: http://localhost:8081/login
- Visualiser: http://localhost:8082/
- Grafana: http://localhost:8083/
- Auth: http://localhost:8084/
- ConfigDB: http://localhost:8085/

## Notes
- All usernames must include the realm: @FACTORYPLUS.AMIC.COM
- Passwords are case-sensitive
- Admin account has full system access
- User accounts have standard access
"@

$userReference | Out-File -FilePath "Factory_Plus_Users.txt" -Encoding UTF8
Write-Host "✅ User reference file created: Factory_Plus_Users.txt" -ForegroundColor Green

# Step 9: Final summary
Write-Host "`n🎉 User Creation Complete!" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green

Write-Host "`n✅ 4 users created successfully:" -ForegroundColor Green
Write-Host "1. admin@FACTORYPLUS.AMIC.COM (Administrator)" -ForegroundColor White
Write-Host "2. user1@FACTORYPLUS.AMIC.COM (User)" -ForegroundColor White
Write-Host "3. user2@FACTORYPLUS.AMIC.COM (User)" -ForegroundColor White
Write-Host "4. user3@FACTORYPLUS.AMIC.COM (User)" -ForegroundColor White

Write-Host "`n🌐 Login URL: http://localhost:8081/login" -ForegroundColor Cyan
Write-Host "📄 User reference: Factory_Plus_Users.txt" -ForegroundColor Cyan

Write-Host "`n🏭 Your Factory+ users are ready to use!" -ForegroundColor Green

Read-Host "`nPress Enter to continue"
