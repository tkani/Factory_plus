# Factory+ Complete Troubleshooting Guide

## 🚨 Common Issues and Solutions

### Issue 1: Installation Fails

#### Problem: Helm installation fails
**Error**: `Error: INSTALLATION FAILED`

**Solutions**:
```powershell
# Check Helm repository
helm repo list
helm repo update

# Check namespace
kubectl get namespace factory-plus

# Delete and recreate if needed
kubectl delete namespace factory-plus
kubectl create namespace factory-plus

# Retry installation
helm install acs amrc-connectivity-stack/amrc-connectivity-stack --version ^3.0.0 -f values.yaml --namespace factory-plus --wait --timeout 30m
```

#### Problem: Pods stuck in Pending
**Error**: Pods show `Pending` status

**Solutions**:
```powershell
# Check node resources
kubectl describe nodes

# Check pod events
kubectl get events -n factory-plus --sort-by='.lastTimestamp'

# Check pod description
kubectl describe pod <pod-name> -n factory-plus

# Check if there are resource constraints
kubectl top nodes
```

#### Problem: Pods in CrashLoopBackOff
**Error**: Pods restarting continuously

**Solutions**:
```powershell
# Check pod logs
kubectl logs <pod-name> -n factory-plus --previous

# Check pod description
kubectl describe pod <pod-name> -n factory-plus

# Restart deployment
kubectl rollout restart deployment/<deployment-name> -n factory-plus

# Check resource limits
kubectl get pods -n factory-plus -o wide
```

### Issue 2: Port Forwarding Problems

#### Problem: Port already in use
**Error**: `bind: Only one usage of each socket address is normally permitted`

**Solutions**:
```powershell
# Find processes using the port
netstat -ano | findstr :8081

# Kill the process
taskkill /PID <PID_NUMBER> /F

# Alternative: Use different ports
kubectl port-forward svc/manager 9081:80 -n factory-plus
kubectl port-forward svc/visualiser 9082:80 -n factory-plus
kubectl port-forward svc/acs-grafana 9083:80 -n factory-plus
```

#### Problem: Port forwarding fails to start
**Error**: `unable to listen on any of the requested ports`

**Solutions**:
```powershell
# Check if service exists
kubectl get svc -n factory-plus

# Check service endpoints
kubectl get endpoints -n factory-plus

# Test service directly
kubectl exec -it deployment/manager -n factory-plus -- curl http://localhost:8080
```

### Issue 3: Browser Issues

#### Problem: Blank page in browser
**Error**: Page loads but shows blank/white screen

**Solutions**:
1. **Clear Browser Cache**:
   - Press `Ctrl + Shift + Delete`
   - Select "All time"
   - Clear all cached data

2. **Try Incognito Mode**:
   - Open private/incognito browser window
   - Navigate to service URL

3. **Try Different Browser**:
   - Chrome, Firefox, Edge, Safari
   - Test with different browsers

4. **Try Alternative URLs**:
   ```powershell
   # Test with 127.0.0.1 instead of localhost
   http://127.0.0.1:8081/login
   
   # Test root path
   http://localhost:8081/
   
   # Test specific paths
   http://localhost:8081/login
   ```

#### Problem: Connection refused
**Error**: `This site can't be reached`

**Solutions**:
```powershell
# Check if port forwarding is active
netstat -ano | findstr :8081

# Restart port forwarding
kubectl port-forward svc/manager 8081:80 -n factory-plus

# Test service response
Invoke-WebRequest -Uri http://localhost:8081/login -Method Get
```

### Issue 4: Service Not Responding

#### Problem: Service returns 403 Forbidden
**Error**: HTTP 403 Forbidden

**Solutions**:
```powershell
# Check service logs
kubectl logs deployment/manager -n factory-plus --tail=50

# Check authentication service
kubectl logs deployment/auth -n factory-plus --tail=50

# Check KDC service
kubectl logs deployment/kdc -n factory-plus --tail=50

# Test service internally
kubectl exec -it deployment/manager -n factory-plus -c backend -- curl http://localhost:8080
```

#### Problem: Service returns 500 Internal Server Error
**Error**: HTTP 500 Internal Server Error

**Solutions**:
```powershell
# Check application logs
kubectl logs deployment/manager -n factory-plus -c backend --tail=100

# Check database connectivity
kubectl logs deployment/manager-database -n factory-plus --tail=50

# Check service dependencies
kubectl get pods -n factory-plus | findstr -E "(database|postgres|influxdb)"
```

### Issue 5: Authentication Problems

#### Problem: Cannot login with admin credentials
**Error**: Login fails with admin credentials

**Solutions**:
```powershell
# Get correct admin password
kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus

# Decode password
$encodedPassword = kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedPassword))

# Check KDC service
kubectl logs deployment/kdc -n factory-plus --tail=50

# Check auth service
kubectl logs deployment/auth -n factory-plus --tail=50
```

#### Problem: Kerberos authentication fails
**Error**: Kerberos authentication errors

**Solutions**:
```powershell
# Check KDC service status
kubectl get pods -n factory-plus | findstr kdc

# Check KDC logs
kubectl logs deployment/kdc -n factory-plus --tail=100

# Check Kerberos configuration
kubectl get configmap krb5-conf -n factory-plus -o yaml

# Restart KDC service
kubectl rollout restart deployment/kdc -n factory-plus
```

### Issue 6: Database Problems

#### Problem: Database connection errors
**Error**: Database connection failed

**Solutions**:
```powershell
# Check database pods
kubectl get pods -n factory-plus | findstr -E "(postgres|database)"

# Check database logs
kubectl logs deployment/manager-database -n factory-plus --tail=100

# Check database service
kubectl get svc -n factory-plus | findstr database

# Test database connectivity
kubectl exec -it deployment/manager -n factory-plus -- psql -h manager-database -U postgres -c "SELECT 1"
```

#### Problem: Database initialization fails
**Error**: Database schema not created

**Solutions**:
```powershell
# Check database initialization logs
kubectl logs deployment/manager -n factory-plus -c migrate-database --tail=100

# Manually run database migrations
kubectl exec -it deployment/manager -n factory-plus -c backend -- php artisan migrate

# Check database secrets
kubectl get secret manager-database-secret -n factory-plus -o yaml
```

### Issue 7: MQTT Problems

#### Problem: MQTT broker not accessible
**Error**: Cannot connect to MQTT broker

**Solutions**:
```powershell
# Check MQTT service
kubectl get pods -n factory-plus | findstr mqtt

# Check MQTT logs
kubectl logs deployment/mqtt -n factory-plus --tail=100

# Test MQTT connectivity
kubectl port-forward svc/mqtt 1883:1883 -n factory-plus

# Check MQTT configuration
kubectl get configmap -n factory-plus | findstr mqtt
```

### Issue 8: TLS Certificate Problems

#### Problem: Certificate not issued
**Error**: TLS certificate not created

**Solutions**:
```powershell
# Check cert-manager status
kubectl get pods -n cert-manager

# Check certificate status
kubectl get certificates -n factory-plus

# Check ClusterIssuer
kubectl get clusterissuer

# Check certificate events
kubectl describe certificate <certificate-name> -n factory-plus
```

#### Problem: Certificate validation fails
**Error**: Certificate validation failed

**Solutions**:
```powershell
# Check certificate details
kubectl describe certificate <certificate-name> -n factory-plus

# Check Let's Encrypt challenges
kubectl get challenges -n factory-plus

# Check ingress configuration
kubectl get ingress -n factory-plus -o yaml
```

### Issue 9: Resource Constraints

#### Problem: Out of memory errors
**Error**: Pod killed due to memory limits

**Solutions**:
```powershell
# Check resource usage
kubectl top pods -n factory-plus

# Check node resources
kubectl top nodes

# Increase Minikube resources
minikube stop
minikube start --memory=16384 --cpus=8

# Check pod resource limits
kubectl describe pod <pod-name> -n factory-plus
```

#### Problem: CPU constraints
**Error**: High CPU usage causing performance issues

**Solutions**:
```powershell
# Check CPU usage
kubectl top pods -n factory-plus

# Check node CPU
kubectl top nodes

# Increase Minikube CPU
minikube stop
minikube start --memory=8192 --cpus=6
```

### Issue 10: Network Problems

#### Problem: Services not accessible externally
**Error**: Cannot access services from outside cluster

**Solutions**:
```powershell
# Check LoadBalancer service
kubectl get svc acs-traefik -n factory-plus

# Check ingress status
kubectl get ingress -n factory-plus

# Check Traefik logs
kubectl logs deployment/acs-traefik -n factory-plus --tail=100

# Test internal connectivity
kubectl exec -it deployment/manager -n factory-plus -- curl http://manager.factory-plus.svc.cluster.local
```

## 🔧 Diagnostic Commands

### System Health Check
```powershell
# Check cluster status
kubectl cluster-info

# Check node status
kubectl get nodes -o wide

# Check all resources
kubectl get all -n factory-plus

# Check events
kubectl get events -n factory-plus --sort-by='.lastTimestamp'
```

### Service Health Check
```powershell
# Check pod status
kubectl get pods -n factory-plus

# Check service status
kubectl get svc -n factory-plus

# Check ingress status
kubectl get ingress -n factory-plus

# Check certificate status
kubectl get certificates -n factory-plus
```

### Log Analysis
```powershell
# Manager logs
kubectl logs deployment/manager -n factory-plus --tail=100

# MQTT logs
kubectl logs deployment/mqtt -n factory-plus --tail=100

# Traefik logs
kubectl logs deployment/acs-traefik -n factory-plus --tail=100

# Auth logs
kubectl logs deployment/auth -n factory-plus --tail=100

# Database logs
kubectl logs deployment/manager-database -n factory-plus --tail=100
```

### Network Testing
```powershell
# Test internal connectivity
kubectl exec -it deployment/manager -n factory-plus -- curl http://localhost:8080

# Test service-to-service communication
kubectl exec -it deployment/manager -n factory-plus -- curl http://auth.factory-plus.svc.cluster.local

# Test external connectivity
kubectl exec -it deployment/manager -n factory-plus -- curl http://google.com
```

## 🚀 Quick Fixes

### Restart All Services
```powershell
# Restart all deployments
kubectl rollout restart deployment -n factory-plus

# Wait for rollout to complete
kubectl rollout status deployment/manager -n factory-plus
kubectl rollout status deployment/visualiser -n factory-plus
kubectl rollout status deployment/acs-grafana -n factory-plus
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
```powershell
# Clear DNS cache
ipconfig /flushdns

# Clear browser cache (Chrome)
# Press Ctrl+Shift+Delete, select "All time", clear all
```

### Reset Minikube
```powershell
# Stop Minikube
minikube stop

# Delete cluster
minikube delete

# Start fresh
minikube start --memory=8192 --cpus=4 --disk-size=50g
```

## 📞 Getting Help

### Log Collection
```powershell
# Collect all logs
kubectl logs deployment/manager -n factory-plus > manager-logs.txt
kubectl logs deployment/visualiser -n factory-plus > visualiser-logs.txt
kubectl logs deployment/acs-grafana -n factory-plus > grafana-logs.txt
kubectl logs deployment/mqtt -n factory-plus > mqtt-logs.txt
kubectl logs deployment/auth -n factory-plus > auth-logs.txt

# Collect system information
kubectl get all -n factory-plus > system-status.txt
kubectl describe pods -n factory-plus > pod-descriptions.txt
```

### Support Resources
- **Factory+ Documentation**: https://factoryplus.app.amrc.co.uk
- **ACS GitHub**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack
- **GitHub Issues**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack/issues
- **Kubernetes Docs**: https://kubernetes.io/docs/
- **Docker Docs**: https://docs.docker.com/

### Community Support
- **GitHub Discussions**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack/discussions
- **Stack Overflow**: Tag questions with `factory-plus` and `amrc-connectivity-stack`

---

**Last Updated**: October 6, 2025  
**Version**: 3.0.0  
**Status**: Complete Troubleshooting Guide
