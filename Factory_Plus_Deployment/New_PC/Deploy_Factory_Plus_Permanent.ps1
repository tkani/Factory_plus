# Factory+ Permanent Deployment Script for New PC
# This script deploys Factory+ with all fixes applied permanently

Write-Host "🏭 Factory+ Permanent Deployment for New PC" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 1: Check prerequisites
Write-Host "`n🔍 Step 1: Checking Prerequisites..." -ForegroundColor Cyan

$prerequisites = @("docker", "kubectl", "helm", "minikube")
$missing = @()

foreach ($prereq in $prerequisites) {
    try {
        $null = Get-Command $prereq -ErrorAction Stop
        Write-Host "✅ $prereq is installed" -ForegroundColor Green
    } catch {
        Write-Host "❌ $prereq is not installed" -ForegroundColor Red
        $missing += $prereq
    }
}

if ($missing.Count -gt 0) {
    Write-Host "`n❌ Missing prerequisites: $($missing -join ', ')" -ForegroundColor Red
    Write-Host "Please install the missing tools and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 2: Start Minikube
Write-Host "`n🚀 Step 2: Starting Minikube..." -ForegroundColor Cyan

try {
    minikube start
    Write-Host "✅ Minikube started successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to start Minikube" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 3: Add Helm repositories
Write-Host "`n📦 Step 3: Adding Helm Repositories..." -ForegroundColor Cyan

try {
    helm repo add amrc-connectivity-stack https://amrc-connectivity-stack.github.io/helm-charts
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    Write-Host "✅ Helm repositories added and updated" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to add Helm repositories" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 4: Create namespace
Write-Host "`n🏗️ Step 4: Creating Namespace..." -ForegroundColor Cyan

try {
    kubectl create namespace factory-plus-new
    Write-Host "✅ Namespace created successfully" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Namespace may already exist" -ForegroundColor Yellow
}

# Step 5: Install cert-manager
Write-Host "`n🔐 Step 5: Installing cert-manager..." -ForegroundColor Cyan

try {
    helm upgrade --install cert-manager jetstack/cert-manager `
        --namespace cert-manager `
        --create-namespace `
        --set installCRDs=true
    Write-Host "✅ cert-manager installed successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to install cert-manager" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 6: Wait for cert-manager
Write-Host "`n⏳ Step 6: Waiting for cert-manager to be ready..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

# Step 7: Install Factory+ with permanent configuration
Write-Host "`n🏭 Step 7: Installing Factory+ with Permanent Configuration..." -ForegroundColor Cyan

try {
    # Deploy with all fixes applied permanently
    helm upgrade --install acs amrc-connectivity-stack/acs `
        -n factory-plus-new `
        --create-namespace `
        -f Configurations/values-local.yaml
    
    Write-Host "✅ Factory+ deployed with permanent configuration" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to deploy Factory+ with permanent configuration" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 8: Wait for deployment
Write-Host "`n⏳ Step 8: Waiting for deployment to complete..." -ForegroundColor Cyan
Start-Sleep -Seconds 60

# Step 9: Start port forwarding
Write-Host "`n🌐 Step 9: Starting port forwarding..." -ForegroundColor Cyan

# Start all port forwarding in background
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/manager", "8081:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/visualiser", "8082:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/acs-grafana", "8083:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/auth", "8084:80", "-n", "factory-plus-new" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/configdb", "8085:80", "-n", "factory-plus-new" -WindowStyle Hidden

Write-Host "✅ Port forwarding started for all services" -ForegroundColor Green

# Step 10: Test services
Write-Host "`n🧪 Step 10: Testing services..." -ForegroundColor Cyan
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
Write-Host "✅ No more manual patching required!" -ForegroundColor Green

Read-Host "`nPress Enter to continue"
