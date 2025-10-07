# Factory+ Services Access Guide

## 🚀 Quick Access Methods

### Method 1: Port Forwarding (Recommended for Testing)

**Manager Service:**
```bash
kubectl port-forward svc/manager 8081:80 -n factory-plus
```
Access: http://localhost:8081

**Visualiser Service:**
```bash
kubectl port-forward svc/visualiser 8082:80 -n factory-plus
```
Access: http://localhost:8082

**Grafana Service:**
```bash
kubectl port-forward svc/acs-grafana 8083:80 -n factory-plus
```
Access: http://localhost:8083

**Auth Service:**
```bash
kubectl port-forward svc/auth 8084:80 -n factory-plus
```
Access: http://localhost:8084

**ConfigDB Service:**
```bash
kubectl port-forward svc/configdb 8085:80 -n factory-plus
```
Access: http://localhost:8085

### Method 2: Minikube Tunnel (Production-like Access)

**Start Minikube Tunnel:**
```bash
minikube tunnel
```

**Get External IP:**
```bash
kubectl get svc acs-traefik -n factory-plus
```

**Access Services:**
- Manager: http://<EXTERNAL_IP>:80/manager
- Visualiser: http://<EXTERNAL_IP>:80/visualiser
- Grafana: http://<EXTERNAL_IP>:80/grafana
- Auth: http://<EXTERNAL_IP>:80/auth
- ConfigDB: http://<EXTERNAL_IP>:80/configdb

### Method 3: Direct Pod Access (Debugging)

**Manager Pod:**
```bash
kubectl exec -it deployment/manager -n factory-plus -c backend -- curl http://localhost:8080
```

**Visualiser Pod:**
```bash
kubectl exec -it deployment/visualiser -n factory-plus -- curl http://localhost:3000
```

## 🔐 Authentication

### Admin Credentials
- **Username**: admin
- **Password**: `ZW9jUHZ5eGtDOExJaFVRTE53WHBMTUpHbmZxLVQtR1dpMmIycS1lVWwySQ==` (base64 encoded)

### Decode Password
**Windows PowerShell:**
```powershell
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("ZW9jUHZ5eGtDOExJaFVRTE53WHBMTUpHbmZxLVQtR1dpMmIycS1lVWwySQ=="))
```

**Linux/Mac:**
```bash
echo "ZW9jUHZ5eGtDOExJaFVRTE53WHBMTUpHbmZxLVQtR1dpMmIycS1lVWwySQ==" | base64 -d
```

## 🌐 Service URLs (Production)

When DNS is configured for `factoryplus.amic.com`:

- **Manager**: https://manager.factoryplus.amic.com
- **Visualiser**: https://visualiser.factoryplus.amic.com
- **Grafana**: https://grafana.factoryplus.amic.com
- **Auth**: https://auth.factoryplus.amic.com
- **ConfigDB**: https://configdb.factoryplus.amic.com
- **MQTT**: mqtts://mqtt.factoryplus.amic.com:8883

## 🔧 Troubleshooting

### Service Not Loading
1. **Check Pod Status:**
   ```bash
   kubectl get pods -n factory-plus
   ```

2. **Check Service Status:**
   ```bash
   kubectl get svc -n factory-plus
   ```

3. **Check Pod Logs:**
   ```bash
   kubectl logs deployment/manager -n factory-plus
   ```

### Port Forwarding Issues
1. **Kill Existing Port Forwards:**
   ```bash
   # Find and kill port-forward processes
   netstat -ano | findstr :8081
   taskkill /PID <PID> /F
   ```

2. **Restart Port Forwarding:**
   ```bash
   kubectl port-forward svc/manager 8081:80 -n factory-plus
   ```

### Authentication Issues
1. **Check Auth Service:**
   ```bash
   kubectl logs deployment/auth -n factory-plus
   ```

2. **Verify KDC Service:**
   ```bash
   kubectl logs deployment/kdc -n factory-plus
   ```

## 📊 Service Status Check

### Health Check Commands
```bash
# Check all services
kubectl get pods -n factory-plus

# Check specific service
kubectl get pods -n factory-plus | findstr manager

# Check service endpoints
kubectl get endpoints -n factory-plus

# Check ingress
kubectl get ingress -n factory-plus
```

### Service-Specific Checks
```bash
# Manager service
kubectl logs deployment/manager -n factory-plus --tail=20

# MQTT service
kubectl logs deployment/mqtt -n factory-plus --tail=20

# Traefik service
kubectl logs deployment/acs-traefik -n factory-plus --tail=20
```

## 🚀 Next Steps

### 1. Initial Setup
1. Access Manager service
2. Login with admin credentials
3. Complete initial setup wizard
4. Configure organization settings

### 2. Service Configuration
1. Set up data schemas
2. Configure MQTT topics
3. Set up monitoring dashboards
4. Configure authentication

### 3. Device Integration
1. Install Edge Agent
2. Configure OPC UA connections
3. Set up Sparkplug B messaging
4. Connect manufacturing devices

## 📞 Support

- **Documentation**: https://factoryplus.app.amrc.co.uk
- **GitHub**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack
- **Issues**: GitHub Issues and Discussions

---

**Last Updated**: October 6, 2025  
**ACS Version**: 3.0.0  
**Organization**: AMIC
