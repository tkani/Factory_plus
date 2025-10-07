# Factory+ Quick Reference Card

## 🚀 Quick Start Commands

### Prerequisites Check
```powershell
# Check Docker
docker --version

# Check Minikube
minikube version

# Check kubectl
kubectl version --client

# Check Helm
helm version
```

### Start Minikube
```powershell
minikube start --memory=8192 --cpus=4 --disk-size=50g
```

### Install Factory+
```powershell
# Add repository
helm repo add amrc-connectivity-stack https://amrc-factoryplus.github.io/amrc-connectivity-stack/build
helm repo update

# Create namespace
kubectl create namespace factory-plus

# Install ACS
helm install acs amrc-connectivity-stack/amrc-connectivity-stack --version ^3.0.0 -f values.yaml --namespace factory-plus --wait --timeout 30m
```

## 🌐 Service Access

### Port Forwarding
```powershell
# Manager
kubectl port-forward svc/manager 8081:80 -n factory-plus

# Visualiser
kubectl port-forward svc/visualiser 8082:80 -n factory-plus

# Grafana
kubectl port-forward svc/acs-grafana 8083:80 -n factory-plus

# Auth
kubectl port-forward svc/auth 8084:80 -n factory-plus

# ConfigDB
kubectl port-forward svc/configdb 8085:80 -n factory-plus
```

### Service URLs
- **Manager**: http://localhost:8081/login
- **Visualiser**: http://localhost:8082/
- **Grafana**: http://localhost:8083/
- **Auth**: http://localhost:8084/
- **ConfigDB**: http://localhost:8085/

## 🔐 Authentication

### Get Admin Password
```powershell
kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus
```

### Decode Password (PowerShell)
```powershell
$encodedPassword = kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedPassword))
```

### Login Credentials
- **Username**: `admin`
- **Password**: (Use decoded password from above)

## 🔧 Troubleshooting

### Check Service Status
```powershell
# Check pods
kubectl get pods -n factory-plus

# Check services
kubectl get svc -n factory-plus

# Check ingress
kubectl get ingress -n factory-plus
```

### Fix Port Conflicts
```powershell
# Find processes using port
netstat -ano | findstr :8081

# Kill process
taskkill /PID <PID_NUMBER> /F

# Restart port forwarding
kubectl port-forward svc/manager 8081:80 -n factory-plus
```

### Check Logs
```powershell
# Manager logs
kubectl logs deployment/manager -n factory-plus --tail=50

# MQTT logs
kubectl logs deployment/mqtt -n factory-plus --tail=50

# Traefik logs
kubectl logs deployment/acs-traefik -n factory-plus --tail=50
```

### Test Service Response
```powershell
# Test Manager
Invoke-WebRequest -Uri http://localhost:8081/login -Method Get

# Test Visualiser
Invoke-WebRequest -Uri http://localhost:8082/ -Method Get

# Test Grafana
Invoke-WebRequest -Uri http://localhost:8083/ -Method Get
```

## 🛠️ Common Fixes

### Restart Services
```powershell
# Restart all deployments
kubectl rollout restart deployment -n factory-plus

# Wait for completion
kubectl rollout status deployment/manager -n factory-plus
```

### Reset Port Forwarding
```powershell
# Kill all kubectl processes
Get-Process | Where-Object {$_.ProcessName -eq "kubectl"} | Stop-Process -Force

# Restart port forwarding
kubectl port-forward svc/manager 8081:80 -n factory-plus &
kubectl port-forward svc/visualiser 8082:80 -n factory-plus &
kubectl port-forward svc/acs-grafana 8083:80 -n factory-plus &
```

### Clear Browser Cache
1. Press `Ctrl + Shift + Delete`
2. Select "All time"
3. Clear all cached data
4. Try incognito mode

## 📊 Health Checks

### System Status
```powershell
# Cluster info
kubectl cluster-info

# Node status
kubectl get nodes -o wide

# Resource usage
kubectl top pods -n factory-plus
kubectl top nodes
```

### Service Health
```powershell
# All resources
kubectl get all -n factory-plus

# Events
kubectl get events -n factory-plus --sort-by='.lastTimestamp'

# Pod descriptions
kubectl describe pods -n factory-plus
```

## 🚨 Emergency Procedures

### Complete Reset
```powershell
# Stop Minikube
minikube stop

# Delete cluster
minikube delete

# Start fresh
minikube start --memory=8192 --cpus=4 --disk-size=50g

# Reinstall ACS
helm install acs amrc-connectivity-stack/amrc-connectivity-stack --version ^3.0.0 -f values.yaml --namespace factory-plus --wait --timeout 30m
```

### Backup Configuration
```powershell
# Backup all resources
kubectl get all -n factory-plus -o yaml > factory-plus-backup.yaml

# Backup secrets
kubectl get secrets -n factory-plus -o yaml > factory-plus-secrets.yaml
```

## 📁 File Locations

### Configuration Files
- `values.yaml` - ACS configuration
- `letsencrypt-issuer.yaml` - TLS certificate issuer
- `factory-plus-ingress.yaml` - Ingress configuration

### Scripts
- `Factory_Plus_Quick_Install.ps1` - Automated installation
- `start-services.ps1` - Service access script

### Documentation
- `Factory_Plus_Complete_Guide.md` - Full installation guide
- `Factory_Plus_Troubleshooting_Complete.md` - Troubleshooting guide
- `Factory_Plus_Quick_Reference.md` - This quick reference

## 🎯 Next Steps

### After Installation
1. Run `.\start-services.ps1`
2. Open browser to http://localhost:8081/login
3. Login with admin credentials
4. Configure Factory+ environment

### Production Deployment
1. Configure DNS records
2. Set up LoadBalancer
3. Configure TLS certificates
4. Set up monitoring

## 📞 Support

### Documentation
- **Factory+**: https://factoryplus.app.amrc.co.uk
- **ACS GitHub**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack

### Community
- **GitHub Issues**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack/issues
- **Discussions**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack/discussions

---

**Version**: 3.0.0  
**Date**: October 6, 2025  
**Status**: ✅ Production Ready
