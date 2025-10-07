# Factory+ Complete Installation & Usage Guide
## AMRC Connectivity Stack (ACS) - Everything You Need

---

## 📋 Table of Contents
1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Access Services](#access-services)
6. [Troubleshooting](#troubleshooting)
7. [Production Deployment](#production-deployment)
8. [Reference](#reference)

---

## 🚀 Quick Start

### For New Installation (Automated)
```powershell
# Run PowerShell as Administrator
.\Factory_Plus_Quick_Install.ps1 -Organization "YOUR_ORG" -Email "your-email@domain.com"
```

### For Manual Installation
Follow the detailed steps in the [Installation](#installation) section below.

---

## Prerequisites

### System Requirements
- **OS**: Windows 10/11 (64-bit)
- **RAM**: 8GB minimum (16GB recommended)
- **CPU**: 4 cores minimum (8 cores recommended)
- **Storage**: 50GB free space
- **Internet**: Stable connection for downloads

### Required Software
1. **Docker Desktop** - https://www.docker.com/products/docker-desktop/
2. **WSL 2** - Windows Subsystem for Linux
3. **Minikube** - Kubernetes cluster
4. **kubectl** - Kubernetes command-line tool
5. **Helm** - Kubernetes package manager

---

## Installation

### Step 1: Install Docker Desktop

1. **Download Docker Desktop**
   - Go to https://www.docker.com/products/docker-desktop/
   - Download and install Docker Desktop
   - **Important**: Enable "Use WSL 2 based engine" during installation
   - Restart your computer

2. **Verify Installation**
   ```powershell
   docker --version
   docker-compose --version
   ```

### Step 2: Install WSL 2

1. **Enable WSL Feature**
   ```powershell
   # Run PowerShell as Administrator
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```

2. **Install WSL 2**
   ```powershell
   wsl --install
   wsl --set-default-version 2
   ```

3. **Restart Computer**

### Step 3: Install Kubernetes Tools

1. **Create Tools Directory**
   ```powershell
   mkdir C:\k8s-tools
   cd C:\k8s-tools
   ```

2. **Install Minikube**
   ```powershell
   # Download Minikube
   Invoke-WebRequest -Uri "https://storage.googleapis.com/minikube/releases/latest/minikube-windows-amd64.exe" -OutFile "minikube.exe"
   
   # Add to PATH
   # Go to System Properties → Advanced → Environment Variables
   # Add C:\k8s-tools to PATH variable
   ```

3. **Install kubectl**
   ```powershell
   # Download kubectl
   Invoke-WebRequest -Uri "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe" -OutFile "kubectl.exe"
   ```

4. **Install Helm**
   ```powershell
   # Download Helm
   Invoke-WebRequest -Uri "https://get.helm.sh/helm-v3.13.0-windows-amd64.zip" -OutFile "helm.zip"
   Expand-Archive -Path "helm.zip" -DestinationPath "."
   ```

5. **Restart PowerShell** to refresh PATH

### Step 4: Start Kubernetes Cluster

```powershell
# Start Minikube with sufficient resources
minikube start --memory=8192 --cpus=4 --disk-size=50g

# Verify cluster
kubectl cluster-info
kubectl get nodes
```

### Step 5: Install Factory+ (ACS)

1. **Create Project Directory**
   ```powershell
   mkdir C:\FactoryPlus
   cd C:\FactoryPlus
   ```

2. **Create Configuration File**
   Create `values.yaml`:
   ```yaml
   acs:
     baseUrl: factoryplus.local
     organisation: YOUR_ORG
     letsEncrypt:
       email: your-email@domain.com
   identity:
     realm: FACTORYPLUS.YOUR_ORG.COM
   ```

3. **Add Helm Repository**
   ```powershell
   helm repo add amrc-connectivity-stack https://amrc-factoryplus.github.io/amrc-connectivity-stack/build
   helm repo update
   ```

4. **Create Namespace**
   ```powershell
   kubectl create namespace factory-plus
   ```

5. **Install ACS**
   ```powershell
   helm install acs amrc-connectivity-stack/amrc-connectivity-stack \
     --version ^3.0.0 \
     -f values.yaml \
     --namespace factory-plus \
     --wait \
     --timeout 30m
   ```

6. **Verify Installation**
   ```powershell
   kubectl get pods -n factory-plus
   kubectl get svc -n factory-plus
   ```

---

## Configuration

### Step 6: Configure TLS Certificates

1. **Install cert-manager**
   ```powershell
   helm repo add jetstack https://charts.jetstack.io
   helm repo update
   
   kubectl create namespace cert-manager
   helm install cert-manager jetstack/cert-manager \
     --namespace cert-manager \
     --version v1.14.4
   ```

2. **Create Let's Encrypt Issuer**
   Create `letsencrypt-issuer.yaml`:
   ```yaml
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

3. **Apply Issuer**
   ```powershell
   kubectl apply -f letsencrypt-issuer.yaml
   ```

### Step 7: Configure Ingress

Create `factory-plus-ingress.yaml`:
```yaml
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
  - host: visualiser.factoryplus.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: visualiser
            port:
              number: 80
  - host: grafana.factoryplus.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: acs-grafana
            port:
              number: 80
  - host: auth.factoryplus.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: auth
            port:
              number: 80
  - host: configdb.factoryplus.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: configdb
            port:
              number: 80
```

Apply ingress:
```powershell
kubectl apply -f factory-plus-ingress.yaml
```

---

## Access Services

### Step 8: Port Forwarding (Recommended for Testing)

**Start Port Forwarding:**
```powershell
# Manager Service
kubectl port-forward svc/manager 8081:80 -n factory-plus

# Visualiser Service
kubectl port-forward svc/visualiser 8082:80 -n factory-plus

# Grafana Service
kubectl port-forward svc/acs-grafana 8083:80 -n factory-plus

# Auth Service
kubectl port-forward svc/auth 8084:80 -n factory-plus

# ConfigDB Service
kubectl port-forward svc/configdb 8085:80 -n factory-plus
```

**Service URLs:**
- **Manager**: http://localhost:8081/login
- **Visualiser**: http://localhost:8082/
- **Grafana**: http://localhost:8083/
- **Auth**: http://localhost:8084/
- **ConfigDB**: http://localhost:8085/

### Step 9: Get Admin Credentials

```powershell
# Get admin password
kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus

# Decode password (PowerShell)
$encodedPassword = kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedPassword))
```

**Login Credentials:**
- **Username**: `admin`
- **Password**: (Use decoded password from above)

### Step 10: Test Services

```powershell
# Test Manager
Invoke-WebRequest -Uri http://localhost:8081/login -Method Get

# Test Visualiser
Invoke-WebRequest -Uri http://localhost:8082/ -Method Get

# Test Grafana
Invoke-WebRequest -Uri http://localhost:8083/ -Method Get
```

**Expected Output:**
```
StatusCode        : 200
StatusDescription : OK
Content           : <!DOCTYPE html>...
```

---

## Troubleshooting

### Common Issues

#### Issue 1: Port Already in Use
**Error**: `bind: Only one usage of each socket address is normally permitted`

**Solution:**
```powershell
# Find processes using the port
netstat -ano | findstr :8081

# Kill the process
taskkill /PID <PID_NUMBER> /F

# Restart port forwarding
kubectl port-forward svc/manager 8081:80 -n factory-plus
```

#### Issue 2: Blank Page in Browser
**Problem**: Page loads but shows blank/white screen

**Solutions:**
1. **Clear Browser Cache**: Press `Ctrl + Shift + Delete`, select "All time", clear all
2. **Try Incognito Mode**: Open private/incognito browser window
3. **Try Different Browser**: Chrome, Firefox, Edge, Safari
4. **Try Alternative URLs**: `http://127.0.0.1:8081/login` instead of localhost

#### Issue 3: Pods Not Starting
**Error**: Pods stuck in Pending or CrashLoopBackOff

**Solution:**
```powershell
# Check pod logs
kubectl logs <pod-name> -n factory-plus

# Check pod description
kubectl describe pod <pod-name> -n factory-plus

# Restart deployment
kubectl rollout restart deployment/<deployment-name> -n factory-plus
```

#### Issue 4: Services Not Accessible
**Error**: Connection refused or timeout

**Solution:**
```powershell
# Check service endpoints
kubectl get endpoints -n factory-plus

# Check service logs
kubectl logs deployment/manager -n factory-plus

# Test from within pod
kubectl exec -it deployment/manager -n factory-plus -- curl http://localhost:8080
```

### Diagnostic Commands

```powershell
# Check all services
kubectl get pods -n factory-plus
kubectl get svc -n factory-plus
kubectl get ingress -n factory-plus

# Check logs
kubectl logs deployment/manager -n factory-plus --tail=50
kubectl logs deployment/mqtt -n factory-plus --tail=50
kubectl logs deployment/acs-traefik -n factory-plus --tail=50

# Check events
kubectl get events -n factory-plus --sort-by='.lastTimestamp'

# Check resource usage
kubectl top pods -n factory-plus
kubectl top nodes
```

### Quick Fixes

```powershell
# Restart all services
kubectl rollout restart deployment -n factory-plus

# Kill all port forwarding
Get-Process | Where-Object {$_.ProcessName -eq "kubectl"} | Stop-Process -Force

# Restart port forwarding
kubectl port-forward svc/manager 8081:80 -n factory-plus &
kubectl port-forward svc/visualiser 8082:80 -n factory-plus &
kubectl port-forward svc/acs-grafana 8083:80 -n factory-plus &
```

---

## Production Deployment

### Step 11: Production Configuration

#### DNS Configuration
For production deployment, configure DNS records:
```
factoryplus.yourdomain.com          A    <LOADBALANCER_IP>
*.factoryplus.yourdomain.com       A    <LOADBALANCER_IP>
```

#### Production URLs
- **Manager**: https://manager.factoryplus.yourdomain.com
- **Visualiser**: https://visualiser.factoryplus.yourdomain.com
- **Grafana**: https://grafana.factoryplus.yourdomain.com
- **Auth**: https://auth.factoryplus.yourdomain.com
- **ConfigDB**: https://configdb.factoryplus.yourdomain.com
- **MQTT**: mqtts://mqtt.factoryplus.yourdomain.com:8883

### Step 12: Monitoring and Maintenance

```powershell
# Health check script
@"
Write-Host "Checking Factory+ Services..."
kubectl get pods -n factory-plus
kubectl get svc -n factory-plus
kubectl get ingress -n factory-plus
kubectl get certificates -n factory-plus
"@ | Out-File -FilePath "health-check.ps1"

# Backup configuration
kubectl get all -n factory-plus -o yaml > factory-plus-backup.yaml
kubectl get secrets -n factory-plus -o yaml > factory-plus-secrets.yaml
```

---

## Reference

### Essential Commands
```powershell
# Start Minikube
minikube start --memory=8192 --cpus=4

# Check cluster status
kubectl cluster-info

# Port forward services
kubectl port-forward svc/manager 8081:80 -n factory-plus
kubectl port-forward svc/visualiser 8082:80 -n factory-plus
kubectl port-forward svc/acs-grafana 8083:80 -n factory-plus

# Check service status
kubectl get pods -n factory-plus
kubectl get svc -n factory-plus

# Get admin password
kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus
```

### Service URLs
- **Manager**: http://localhost:8081/login
- **Visualiser**: http://localhost:8082/
- **Grafana**: http://localhost:8083/
- **Auth**: http://localhost:8084/
- **ConfigDB**: http://localhost:8085/

### Login Credentials
- **Username**: `admin`
- **Password**: (Decode from kubectl command above)

### File Structure
```
C:\FactoryPlus\
├── values.yaml                    # ACS configuration
├── letsencrypt-issuer.yaml        # TLS certificate issuer
├── factory-plus-ingress.yaml      # Ingress configuration
├── Factory_Plus_Complete_Guide.md  # This guide
└── health-check.ps1              # Health check script
```

### Support Resources
- **Factory+ Documentation**: https://factoryplus.app.amrc.co.uk
- **ACS GitHub**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack
- **GitHub Issues**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack/issues
- **Community Discussions**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack/discussions

---

## 🎉 Success!

### What You've Installed
- ✅ **Complete Factory+ Framework**
- ✅ **All Core Services** (Manager, Visualiser, Grafana, Auth, MQTT)
- ✅ **Security & Authentication** (Kerberos, TLS)
- ✅ **Data Infrastructure** (InfluxDB, PostgreSQL, MinIO)
- ✅ **Monitoring & Visualization** (Grafana, Visualiser)
- ✅ **Production Ready** (Ingress, TLS certificates)

### Next Steps
1. **Access Manager**: http://localhost:8081/login
2. **Login with admin credentials**
3. **Configure Factory+ environment**
4. **Connect manufacturing devices**
5. **Set up monitoring dashboards**

### Your Factory+ Framework is Ready!
Transform your manufacturing data management with Industry 4.0 capabilities! 🏭✨

---

**Installation Date**: October 6, 2025  
**ACS Version**: 3.0.0  
**Status**: ✅ **PRODUCTION READY**
