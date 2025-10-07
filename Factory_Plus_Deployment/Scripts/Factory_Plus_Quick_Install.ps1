# Factory+ Quick Installation Script
# AMRC Connectivity Stack (ACS) - Automated Installation

param(
    [string]$Organization = "YOUR_ORG",
    [string]$Email = "your-email@domain.com",
    [string]$BaseUrl = "factoryplus.local"
)

Write-Host "🏭 Factory+ Installation Script Starting..." -ForegroundColor Green
Write-Host "Organization: $Organization" -ForegroundColor Yellow
Write-Host "Email: $Email" -ForegroundColor Yellow
Write-Host "Base URL: $BaseUrl" -ForegroundColor Yellow

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit 1
}

# Step 1: Check Prerequisites
Write-Host "`n📋 Step 1: Checking Prerequisites..." -ForegroundColor Cyan

# Check if Docker is installed
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker not found. Please install Docker Desktop first." -ForegroundColor Red
    Write-Host "Download from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    exit 1
}

# Check if Minikube is installed
try {
    $minikubeVersion = minikube version
    Write-Host "✅ Minikube: $minikubeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Minikube not found. Installing Minikube..." -ForegroundColor Yellow
    
    # Create tools directory
    if (!(Test-Path "C:\k8s-tools")) {
        New-Item -ItemType Directory -Path "C:\k8s-tools"
    }
    
    # Download Minikube
    Write-Host "Downloading Minikube..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://storage.googleapis.com/minikube/releases/latest/minikube-windows-amd64.exe" -OutFile "C:\k8s-tools\minikube.exe"
    
    # Add to PATH
    $env:PATH += ";C:\k8s-tools"
    [Environment]::SetEnvironmentVariable("PATH", $env:PATH, [EnvironmentVariableTarget]::Machine)
    
    Write-Host "✅ Minikube installed" -ForegroundColor Green
}

# Check if kubectl is installed
try {
    $kubectlVersion = kubectl version --client
    Write-Host "✅ kubectl: $kubectlVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ kubectl not found. Installing kubectl..." -ForegroundColor Yellow
    
    # Download kubectl
    Write-Host "Downloading kubectl..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe" -OutFile "C:\k8s-tools\kubectl.exe"
    
    Write-Host "✅ kubectl installed" -ForegroundColor Green
}

# Check if Helm is installed
try {
    $helmVersion = helm version
    Write-Host "✅ Helm: $helmVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Helm not found. Installing Helm..." -ForegroundColor Yellow
    
    # Download Helm
    Write-Host "Downloading Helm..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://get.helm.sh/helm-v3.13.0-windows-amd64.zip" -OutFile "C:\k8s-tools\helm.zip"
    Expand-Archive -Path "C:\k8s-tools\helm.zip" -DestinationPath "C:\k8s-tools" -Force
    Move-Item "C:\k8s-tools\windows-amd64\helm.exe" "C:\k8s-tools\helm.exe"
    Remove-Item "C:\k8s-tools\windows-amd64" -Recurse -Force
    Remove-Item "C:\k8s-tools\helm.zip" -Force
    
    Write-Host "✅ Helm installed" -ForegroundColor Green
}

# Step 2: Start Minikube
Write-Host "`n🚀 Step 2: Starting Minikube Cluster..." -ForegroundColor Cyan

# Check if Minikube is running
$minikubeStatus = minikube status --format="json" | ConvertFrom-Json
if ($minikubeStatus.Host -eq "Running") {
    Write-Host "✅ Minikube is already running" -ForegroundColor Green
} else {
    Write-Host "Starting Minikube with 8GB RAM and 4 CPUs..." -ForegroundColor Yellow
    minikube start --memory=8192 --cpus=4 --disk-size=50g
    Write-Host "✅ Minikube started" -ForegroundColor Green
}

# Step 3: Create Project Directory
Write-Host "`n📁 Step 3: Setting up Project Directory..." -ForegroundColor Cyan

$projectDir = "C:\FactoryPlus"
if (!(Test-Path $projectDir)) {
    New-Item -ItemType Directory -Path $projectDir
    Write-Host "✅ Project directory created: $projectDir" -ForegroundColor Green
} else {
    Write-Host "✅ Project directory exists: $projectDir" -ForegroundColor Green
}

Set-Location $projectDir

# Step 4: Create Configuration
Write-Host "`n⚙️ Step 4: Creating Configuration..." -ForegroundColor Cyan

$valuesContent = @"
acs:
  baseUrl: $BaseUrl
  organisation: $Organization
  letsEncrypt:
    email: $Email
identity:
  realm: FACTORYPLUS.$($Organization.ToUpper()).COM
"@

$valuesContent | Out-File -FilePath "values.yaml" -Encoding UTF8
Write-Host "✅ Configuration file created: values.yaml" -ForegroundColor Green

# Step 5: Add Helm Repository
Write-Host "`n📦 Step 5: Adding Helm Repository..." -ForegroundColor Cyan

helm repo add amrc-connectivity-stack https://amrc-factoryplus.github.io/amrc-connectivity-stack/build
helm repo update
Write-Host "✅ Helm repository added and updated" -ForegroundColor Green

# Step 6: Create Namespace
Write-Host "`n🏗️ Step 6: Creating Namespace..." -ForegroundColor Cyan

kubectl create namespace factory-plus --dry-run=client -o yaml | kubectl apply -f -
Write-Host "✅ Namespace created: factory-plus" -ForegroundColor Green

# Step 7: Install ACS
Write-Host "`n🏭 Step 7: Installing AMRC Connectivity Stack..." -ForegroundColor Cyan
Write-Host "This may take 10-15 minutes..." -ForegroundColor Yellow

helm install acs amrc-connectivity-stack/amrc-connectivity-stack `
  --version ^3.0.0 `
  -f values.yaml `
  --namespace factory-plus `
  --wait `
  --timeout 30m

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ AMRC Connectivity Stack installed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Installation failed. Check the logs above." -ForegroundColor Red
    exit 1
}

# Step 8: Install cert-manager
Write-Host "`n🔒 Step 8: Installing cert-manager..." -ForegroundColor Cyan

helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -
helm install cert-manager jetstack/cert-manager `
  --namespace cert-manager `
  --version v1.14.4

Write-Host "✅ cert-manager installed" -ForegroundColor Green

# Step 9: Create Let's Encrypt Issuer
Write-Host "`n🌐 Step 9: Creating Let's Encrypt Issuer..." -ForegroundColor Cyan

$issuerContent = @"
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $Email
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: traefik
"@

$issuerContent | Out-File -FilePath "letsencrypt-issuer.yaml" -Encoding UTF8
kubectl apply -f letsencrypt-issuer.yaml
Write-Host "✅ Let's Encrypt issuer created" -ForegroundColor Green

# Step 10: Create Ingress
Write-Host "`n🌍 Step 10: Creating Ingress Configuration..." -ForegroundColor Cyan

$ingressContent = @"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: factory-plus-ingress
  namespace: factory-plus
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - manager.$BaseUrl
    - visualiser.$BaseUrl
    - grafana.$BaseUrl
    - auth.$BaseUrl
    - configdb.$BaseUrl
    secretName: factory-plus-tls
  rules:
  - host: manager.$BaseUrl
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: manager
            port:
              number: 80
  - host: visualiser.$BaseUrl
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: visualiser
            port:
              number: 80
  - host: grafana.$BaseUrl
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: acs-grafana
            port:
              number: 80
  - host: auth.$BaseUrl
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: auth
            port:
              number: 80
  - host: configdb.$BaseUrl
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: configdb
            port:
              number: 80
"@

$ingressContent | Out-File -FilePath "factory-plus-ingress.yaml" -Encoding UTF8
kubectl apply -f factory-plus-ingress.yaml
Write-Host "✅ Ingress configuration created" -ForegroundColor Green

# Step 11: Verify Installation
Write-Host "`n✅ Step 11: Verifying Installation..." -ForegroundColor Cyan

Write-Host "Checking pod status..." -ForegroundColor Yellow
kubectl get pods -n factory-plus

Write-Host "`nChecking services..." -ForegroundColor Yellow
kubectl get svc -n factory-plus

Write-Host "`nChecking ingress..." -ForegroundColor Yellow
kubectl get ingress -n factory-plus

# Step 12: Get Admin Credentials
Write-Host "`n🔐 Step 12: Getting Admin Credentials..." -ForegroundColor Cyan

$adminPassword = kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus
$decodedPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($adminPassword))

Write-Host "Admin Username: admin" -ForegroundColor Green
Write-Host "Admin Password: $decodedPassword" -ForegroundColor Green

# Step 13: Create Access Scripts
Write-Host "`n🔗 Step 13: Creating Access Scripts..." -ForegroundColor Cyan

$accessScript = @"
# Factory+ Service Access Script
Write-Host "🏭 Factory+ Service Access" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

Write-Host "`nStarting port forwarding for all services..." -ForegroundColor Yellow

# Start port forwarding in background
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/manager", "8081:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/visualiser", "8082:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/acs-grafana", "8083:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/auth", "8084:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/configdb", "8085:80", "-n", "factory-plus" -WindowStyle Hidden

Write-Host "`n✅ Port forwarding started for all services" -ForegroundColor Green

Write-Host "`n🌐 Service URLs:" -ForegroundColor Cyan
Write-Host "Manager:    http://localhost:8081/login" -ForegroundColor White
Write-Host "Visualiser: http://localhost:8082/" -ForegroundColor White
Write-Host "Grafana:    http://localhost:8083/" -ForegroundColor White
Write-Host "Auth:       http://localhost:8084/" -ForegroundColor White
Write-Host "ConfigDB:   http://localhost:8085/" -ForegroundColor White

Write-Host "`n🔐 Login Credentials:" -ForegroundColor Cyan
Write-Host "Username: admin" -ForegroundColor White
Write-Host "Password: $decodedPassword" -ForegroundColor White

Write-Host "`nPress any key to stop port forwarding..." -ForegroundColor Yellow
Read-Host

# Stop port forwarding
Get-Process | Where-Object {$_.ProcessName -eq "kubectl"} | Stop-Process -Force
Write-Host "`n✅ Port forwarding stopped" -ForegroundColor Green
"@

$accessScript | Out-File -FilePath "start-services.ps1" -Encoding UTF8
Write-Host "✅ Access script created: start-services.ps1" -ForegroundColor Green

# Step 14: Installation Complete
Write-Host "`n🎉 Installation Complete!" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

Write-Host "`n✅ AMRC Connectivity Stack (Factory+) has been successfully installed!" -ForegroundColor Green

Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Run: .\start-services.ps1" -ForegroundColor White
Write-Host "2. Open browser to: http://localhost:8081/login" -ForegroundColor White
Write-Host "3. Login with admin credentials" -ForegroundColor White
Write-Host "4. Begin configuring your Factory+ environment" -ForegroundColor White

Write-Host "`n📁 Files Created:" -ForegroundColor Cyan
Write-Host "- values.yaml (Configuration)" -ForegroundColor White
Write-Host "- letsencrypt-issuer.yaml (TLS Certificates)" -ForegroundColor White
Write-Host "- factory-plus-ingress.yaml (Ingress Configuration)" -ForegroundColor White
Write-Host "- start-services.ps1 (Service Access Script)" -ForegroundColor White

Write-Host "`n📚 Documentation:" -ForegroundColor Cyan
Write-Host "- Complete Installation Guide: Complete_Factory_Plus_Installation_Guide.md" -ForegroundColor White
Write-Host "- Factory+ Documentation: https://factoryplus.app.amrc.co.uk" -ForegroundColor White
Write-Host "- ACS GitHub: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack" -ForegroundColor White

Write-Host "`n🏭 Your Factory+ framework is ready to transform your manufacturing operations!" -ForegroundColor Green
