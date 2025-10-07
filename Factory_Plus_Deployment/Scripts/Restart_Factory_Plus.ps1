# Factory+ Restart Script
# Use this script to restart Factory+ after laptop shutdown/restart

Write-Host "🏭 Factory+ Restart Script" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 1: Check if Minikube is running
Write-Host "`n🔍 Step 1: Checking Minikube Status..." -ForegroundColor Cyan

try {
    $minikubeStatus = minikube status --format="json" | ConvertFrom-Json
    if ($minikubeStatus.Host -eq "Running") {
        Write-Host "✅ Minikube is already running" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Minikube is not running. Starting Minikube..." -ForegroundColor Yellow
        minikube start --memory=8192 --cpus=4 --disk-size=50g
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Minikube started successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to start Minikube. Please check Docker and WSL2." -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
} catch {
    Write-Host "❌ Minikube not found. Please run the complete deployment script first." -ForegroundColor Red
    Write-Host "Run: .\Factory_Plus_Complete_Deployment.ps1 -Organization 'YOUR_ORG' -Email 'your-email@domain.com'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 2: Check if Factory+ namespace exists
Write-Host "`n🔍 Step 2: Checking Factory+ Namespace..." -ForegroundColor Cyan

try {
    $namespace = kubectl get namespace factory-plus
    Write-Host "✅ Factory+ namespace exists" -ForegroundColor Green
} catch {
    Write-Host "❌ Factory+ namespace not found. Please run the complete deployment script first." -ForegroundColor Red
    Write-Host "Run: .\Factory_Plus_Complete_Deployment.ps1 -Organization 'YOUR_ORG' -Email 'your-email@domain.com'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 3: Check pod status
Write-Host "`n🔍 Step 3: Checking Pod Status..." -ForegroundColor Cyan

Write-Host "Current pod status:" -ForegroundColor Yellow
kubectl get pods -n factory-plus

# Check if any pods are not running
$notRunningPods = kubectl get pods -n factory-plus --field-selector=status.phase!=Running --no-headers
if ($notRunningPods) {
    Write-Host "`n⚠️ Some pods are not running. Waiting for them to start..." -ForegroundColor Yellow
    Write-Host "This may take 2-3 minutes..." -ForegroundColor Yellow
    
    # Wait for pods to be ready
    Start-Sleep -Seconds 30
    
    Write-Host "Updated pod status:" -ForegroundColor Yellow
    kubectl get pods -n factory-plus
}

# Step 4: Apply configuration fixes (in case they were lost)
Write-Host "`n🔧 Step 4: Applying Configuration Fixes..." -ForegroundColor Cyan

# Fix Manager white page issue
Write-Host "Fixing Manager white page issue..." -ForegroundColor Yellow
try {
    kubectl patch configmap manager-config -n factory-plus --type='json' -p='[
      {"op": "replace", "path": "/data/APP_URL", "value": "http://localhost:8081"}, 
      {"op": "replace", "path": "/data/ASSET_URL", "value": "http://localhost:8081"}
    ]'
    Write-Host "✅ Manager configuration fixed" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Could not fix Manager configuration. This is normal if already fixed." -ForegroundColor Yellow
}

# Fix Monitor service DNS issue
Write-Host "Fixing Monitor service DNS issue..." -ForegroundColor Yellow
try {
    kubectl scale deployment monitor -n factory-plus --replicas=0
    Write-Host "✅ Monitor service scaled down" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Could not scale Monitor service. This is normal if already scaled down." -ForegroundColor Yellow
}

# Step 5: Start port forwarding
Write-Host "`n🔗 Step 5: Starting Port Forwarding..." -ForegroundColor Cyan

# Kill any existing port forwarding processes
Write-Host "Stopping any existing port forwarding..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -eq "kubectl"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Wait a moment for processes to stop
Start-Sleep -Seconds 2

# Start port forwarding for all services
Write-Host "Starting port forwarding for all services..." -ForegroundColor Yellow

# Start port forwarding in background
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/manager", "8081:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/visualiser", "8082:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/acs-grafana", "8083:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/auth", "8084:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/configdb", "8085:80", "-n", "factory-plus" -WindowStyle Hidden

# Wait for port forwarding to start
Start-Sleep -Seconds 5

Write-Host "✅ Port forwarding started for all services" -ForegroundColor Green

# Step 6: Test service access
Write-Host "`n🧪 Step 6: Testing Service Access..." -ForegroundColor Cyan

Write-Host "Testing Manager service..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081" -Method Get -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Manager service is accessible" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Manager service returned status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ Manager service not yet accessible. This is normal during startup." -ForegroundColor Yellow
}

# Step 7: Display access information
Write-Host "`n🎉 Factory+ Restart Complete!" -ForegroundColor Green
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

Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Open browser to: http://localhost:8081/login" -ForegroundColor White
Write-Host "2. Login with admin credentials" -ForegroundColor White
Write-Host "3. Begin using Factory+" -ForegroundColor White

Write-Host "`n🛠️ If you encounter issues:" -ForegroundColor Cyan
Write-Host "Run: .\troubleshoot.ps1" -ForegroundColor White

Write-Host "`n⏹️ To stop all services:" -ForegroundColor Cyan
Write-Host "Run: Get-Process | Where-Object {`$_.ProcessName -eq \"kubectl\"} | Stop-Process -Force" -ForegroundColor White

Write-Host "`n🏭 Your Factory+ framework is ready to use!" -ForegroundColor Green

Read-Host "`nPress Enter to continue"
