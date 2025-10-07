# Factory+ New Computer Deployment Guide
## Complete Setup for Fresh Installation

---

## 🚀 Quick Start (Automated Installation)

### Option 1: One-Command Installation
```powershell
# Run PowerShell as Administrator
.\Factory_Plus_Quick_Install.ps1 -Organization "YOUR_ORG" -Email "your-email@domain.com"
```

### Option 2: Step-by-Step Manual Installation
Follow the detailed steps below for complete control over the installation process.

---

## 📋 Prerequisites Checklist

### System Requirements
- ✅ **OS**: Windows 10/11 (64-bit)
- ✅ **RAM**: 8GB minimum (16GB recommended)
- ✅ **CPU**: 4 cores minimum (8 cores recommended)
- ✅ **Storage**: 50GB free space
- ✅ **Internet**: Stable connection for downloads

### Required Software Installation Order

#### 1. Install Docker Desktop
```powershell
# Download and install from:
# https://www.docker.com/products/docker-desktop/
# After installation, restart your computer
```

#### 2. Enable WSL 2
```powershell
# Run PowerShell as Administrator
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --set-default-version 2
```

#### 3. Install Minikube
```powershell
# Download Minikube
Invoke-WebRequest -Uri "https://storage.googleapis.com/minikube/releases/latest/minikube-windows-amd64.exe" -OutFile "C:\k8s-tools\minikube.exe"

# Add to PATH
$env:PATH += ";C:\k8s-tools"
[Environment]::SetEnvironmentVariable("PATH", $env:PATH, [EnvironmentVariableTarget]::Machine)
```

#### 4. Install kubectl
```powershell
# Download kubectl
Invoke-WebRequest -Uri "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe" -OutFile "C:\k8s-tools\kubectl.exe"
```

#### 5. Install Helm
```powershell
# Download Helm
Invoke-WebRequest -Uri "https://get.helm.sh/helm-v3.13.0-windows-amd64.zip" -OutFile "C:\k8s-tools\helm.zip"
Expand-Archive -Path "C:\k8s-tools\helm.zip" -DestinationPath "C:\k8s-tools" -Force
Move-Item "C:\k8s-tools\windows-amd64\helm.exe" "C:\k8s-tools\helm.exe"
```

---

## 🏗️ Installation Process

### Step 1: Prepare Environment
```powershell
# Create project directory
New-Item -ItemType Directory -Path "C:\FactoryPlus" -Force
Set-Location "C:\FactoryPlus"

# Create tools directory
New-Item -ItemType Directory -Path "C:\k8s-tools" -Force
```

### Step 2: Start Minikube Cluster
```powershell
# Start Minikube with sufficient resources
minikube start --memory=8192 --cpus=4 --disk-size=50g

# Verify cluster is running
kubectl cluster-info
```

### Step 3: Create Configuration
```yaml
# Create values.yaml
acs:
  baseUrl: factoryplus.local
  organisation: YOUR_ORG
  letsEncrypt:
    email: your-email@domain.com
identity:
  realm: FACTORYPLUS.YOUR_ORG.COM
```

### Step 4: Add Helm Repository
```powershell
helm repo add amrc-connectivity-stack https://amrc-factoryplus.github.io/amrc-connectivity-stack/build
helm repo update
```

### Step 5: Create Namespace
```powershell
kubectl create namespace factory-plus
```

### Step 6: Install ACS Stack
```powershell
helm install acs amrc-connectivity-stack/amrc-connectivity-stack \
  --version ^3.0.0 \
  -f values.yaml \
  --namespace factory-plus \
  --wait \
  --timeout 30m
```

### Step 7: Install cert-manager
```powershell
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl create namespace cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.14.4
```

### Step 8: Create Let's Encrypt Issuer
```yaml
# Create letsencrypt-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@domain.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: traefik
```

### Step 9: Create Ingress Configuration
```yaml
# Create factory-plus-ingress.yaml
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
    - manager.factoryplus.local
    - visualiser.factoryplus.local
    - grafana.factoryplus.local
    - auth.factoryplus.local
    - configdb.factoryplus.local
    secretName: factory-plus-tls
  rules:
  - host: manager.factoryplus.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: manager
            port:
              number: 80
  # ... (additional rules for other services)
```

---

## 🔧 Configuration Fixes

### Fix Manager White Page Issue
```powershell
# Update Manager configuration to use localhost
kubectl patch configmap manager-config -n factory-plus --type='json' -p='[
  {"op": "replace", "path": "/data/APP_URL", "value": "http://localhost:8081"}, 
  {"op": "replace", "path": "/data/ASSET_URL", "value": "http://localhost:8081"}
]'

# Restart Manager pod
kubectl delete pod -n factory-plus -l component=manager
```

### Fix Monitor Service DNS Issue
```powershell
# Scale down monitor service (non-critical)
kubectl scale deployment monitor -n factory-plus --replicas=0
```

---

## 🚀 Access Services

### Create Service Access Script
```powershell
# Create start-services.ps1
Write-Host "🏭 Factory+ Service Access" -ForegroundColor Green

# Start port forwarding
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/manager", "8081:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/visualiser", "8082:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/acs-grafana", "8083:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/auth", "8084:80", "-n", "factory-plus" -WindowStyle Hidden
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/configdb", "8085:80", "-n", "factory-plus" -WindowStyle Hidden

Write-Host "🌐 Service URLs:" -ForegroundColor Cyan
Write-Host "Manager:    http://localhost:8081/login" -ForegroundColor White
Write-Host "Visualiser: http://localhost:8082/" -ForegroundColor White
Write-Host "Grafana:    http://localhost:8083/" -ForegroundColor White
Write-Host "Auth:       http://localhost:8084/" -ForegroundColor White
Write-Host "ConfigDB:   http://localhost:8085/" -ForegroundColor White
```

### Get Admin Credentials
```powershell
# Get admin password
$adminPassword = kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus
$decodedPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($adminPassword))

Write-Host "Admin Username: admin" -ForegroundColor Green
Write-Host "Admin Password: $decodedPassword" -ForegroundColor Green
```

---

## ✅ Verification Steps

### Check Pod Status
```powershell
kubectl get pods -n factory-plus
```

### Check Services
```powershell
kubectl get svc -n factory-plus
```

### Check Ingress
```powershell
kubectl get ingress -n factory-plus
```

### Test Service Access
```powershell
# Test Manager service
Invoke-WebRequest -Uri "http://localhost:8081" -Method Get
```

---

## 🛠️ Troubleshooting

### Common Issues and Solutions

#### 1. White Page on Manager
**Problem**: Manager loads but shows white page
**Solution**: Update APP_URL and ASSET_URL to localhost
```powershell
kubectl patch configmap manager-config -n factory-plus --type='json' -p='[
  {"op": "replace", "path": "/data/APP_URL", "value": "http://localhost:8081"}, 
  {"op": "replace", "path": "/data/ASSET_URL", "value": "http://localhost:8081"}
]'
```

#### 2. Monitor Service CrashLoopBackOff
**Problem**: Monitor pod keeps restarting
**Solution**: Scale down monitor service (non-critical)
```powershell
kubectl scale deployment monitor -n factory-plus --replicas=0
```

#### 3. Port Forwarding Issues
**Problem**: Cannot connect to services
**Solution**: Restart port forwarding
```powershell
# Kill existing port forwards
Get-Process | Where-Object {$_.ProcessName -eq "kubectl"} | Stop-Process -Force

# Restart port forwarding
kubectl port-forward svc/manager 8081:80 -n factory-plus
```

#### 4. Minikube Not Starting
**Problem**: Minikube fails to start
**Solution**: Check Docker and WSL2
```powershell
# Check Docker status
docker version

# Check WSL2
wsl --list --verbose

# Restart Minikube
minikube delete
minikube start --memory=8192 --cpus=4 --disk-size=50g
```

---

## 📚 Next Steps

### 1. Access Factory+ Manager
- Open browser to `http://localhost:8081/login`
- Login with admin credentials
- Configure your organization settings

### 2. Explore Services
- **Manager**: Main Factory+ interface
- **Visualiser**: Data visualization
- **Grafana**: Monitoring dashboards
- **Auth**: Authentication services
- **ConfigDB**: Configuration database

### 3. Configure Your Environment
- Set up user accounts
- Configure data sources
- Create monitoring dashboards
- Set up data pipelines

---

## 📁 File Structure

After installation, you'll have:
```
C:\FactoryPlus\
├── values.yaml                    # Configuration
├── letsencrypt-issuer.yaml        # TLS certificates
├── factory-plus-ingress.yaml      # Ingress configuration
├── start-services.ps1            # Service access script
└── Factory_Plus_New_Computer_Deployment.md  # This guide
```

---

## 🎉 Success!

Your Factory+ deployment is now ready! You have a complete AMRC Connectivity Stack running with all services accessible through localhost ports.

**Key URLs:**
- Manager: http://localhost:8081/login
- Visualiser: http://localhost:8082/
- Grafana: http://localhost:8083/
- Auth: http://localhost:8084/
- ConfigDB: http://localhost:8085/

**Login Credentials:**
- Username: admin
- Password: [Generated during installation]

Your Factory+ framework is ready to transform your manufacturing operations! 🏭
