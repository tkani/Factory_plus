# Factory+ Quick Reference
## Essential Commands, URLs, and Information

---

## 🌐 **Service URLs**

### **Local Access (Port Forwarding)**
```
Manager Service:    http://localhost:8081
Visualiser Service: http://localhost:8082
Grafana Service:    http://localhost:8083
Auth Service:       http://localhost:8084
ConfigDB Service:   http://localhost:8085
```

### **External Access (If Configured)**
```
Manager Service:    https://manager.factoryplus.amic.com
Visualiser Service: https://visualiser.factoryplus.amic.com
Grafana Service:    https://grafana.factoryplus.amic.com
Auth Service:       https://auth.factoryplus.amic.com
ConfigDB Service:   https://configdb.factoryplus.amic.com
```

---

## 🔧 **Essential Commands**

### **Kubernetes Commands**
```bash
# Check pod status
kubectl get pods -n factory-plus

# Check service status
kubectl get services -n factory-plus

# Check ingress status
kubectl get ingress -n factory-plus

# View pod logs
kubectl logs <pod-name> -n factory-plus

# Port forwarding
kubectl port-forward svc/manager 8081:80 -n factory-plus
kubectl port-forward svc/visualiser 8082:80 -n factory-plus
kubectl port-forward svc/acs-grafana 8083:80 -n factory-plus
kubectl port-forward svc/auth 8084:80 -n factory-plus
kubectl port-forward svc/configdb 8085:80 -n factory-plus
```

### **Helm Commands**
```bash
# Check Helm releases
helm list -n factory-plus

# Check release status
helm status acs -n factory-plus

# Upgrade release
helm upgrade acs amrc-connectivity-stack/amrc-connectivity-stack -n factory-plus

# Uninstall release
helm uninstall acs -n factory-plus
```

### **System Commands**
```bash
# Check system resources
kubectl top nodes
kubectl top pods -n factory-plus

# Check storage
kubectl get pv
kubectl get pvc -n factory-plus

# Check network
kubectl get networkpolicies -n factory-plus
```

---

## 🔐 **Authentication**

### **Default Credentials**
```
Username: admin
Password: [Retrieved from kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus]
```

### **Password Retrieval**
```bash
# Get admin password
kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus | base64 --decode

# Get user passwords
kubectl get secret krb5-passwords -o jsonpath="{.data.user}" -n factory-plus | base64 --decode
```

---

## 📊 **Data Schemas**

### **Basic Temperature Sensor**
```json
{
  "name": "Temperature Sensor",
  "version": "1.0",
  "fields": [
    {
      "name": "temperature",
      "type": "double",
      "unit": "°C"
    },
    {
      "name": "humidity",
      "type": "double",
      "unit": "%"
    },
    {
      "name": "timestamp",
      "type": "datetime"
    }
  ]
}
```

### **Production Machine**
```json
{
  "name": "Production Machine",
  "version": "1.0",
  "fields": [
    {
      "name": "machine_id",
      "type": "string"
    },
    {
      "name": "status",
      "type": "string"
    },
    {
      "name": "speed",
      "type": "double",
      "unit": "rpm"
    },
    {
      "name": "temperature",
      "type": "double",
      "unit": "°C"
    },
    {
      "name": "production_count",
      "type": "integer"
    }
  ]
}
```

---

## 🌐 **MQTT Topics**

### **Topic Structure**
```
factory-plus/
├── devices/
│   ├── {device_id}/
│   │   ├── data/          # Device data
│   │   ├── status/        # Device status
│   │   ├── commands/      # Device commands
│   │   └── config/        # Device configuration
├── alerts/
│   ├── critical/          # Critical alerts
│   ├── warning/           # Warning alerts
│   └── info/              # Information alerts
└── system/
    ├── health/            # System health
    ├── metrics/           # System metrics
    └── logs/              # System logs
```

### **Example Topics**
```
factory-plus/devices/temp-sensor-001/data
factory-plus/devices/machine-001/status
factory-plus/devices/machine-001/commands
factory-plus/alerts/critical
factory-plus/system/health
```

---

## 📈 **Grafana Queries**

### **InfluxDB Queries**
```sql
-- Get latest temperature readings
SELECT temperature FROM sensors 
WHERE time > now() - 1h

-- Calculate average temperature
SELECT mean(temperature) FROM sensors 
WHERE time > now() - 24h 
GROUP BY time(1h)

-- Find temperature anomalies
SELECT temperature FROM sensors 
WHERE temperature > 80
```

### **PostgreSQL Queries**
```sql
-- Get device information
SELECT * FROM devices 
WHERE status = 'online'

-- Get user permissions
SELECT u.username, r.role_name 
FROM users u 
JOIN user_roles ur ON u.id = ur.user_id 
JOIN roles r ON ur.role_id = r.id

-- Get recent alerts
SELECT * FROM alerts 
WHERE created_at > NOW() - INTERVAL '1 hour'
ORDER BY created_at DESC
```

---

## 🔧 **Configuration Files**

### **values.yaml**
```yaml
acs:
  baseUrl: factoryplus.amic.com
  organisation: AMIC
  letsEncrypt:
    email: kani@qub.ac.uk

identity:
  realm: FACTORYPLUS.AMIC.COM
```

### **Let's Encrypt Issuer**
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: kani@qub.ac.uk
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod-private-key
    solvers:
    - http01:
        ingress:
          class: acs-traefik
```

---

## 🚨 **Troubleshooting**

### **Common Issues**

#### **Port Already in Use**
```bash
# Find process using port
netstat -ano | findstr :8081

# Kill process
taskkill /PID <PID> /F
```

#### **Pod Not Starting**
```bash
# Check pod status
kubectl describe pod <pod-name> -n factory-plus

# Check logs
kubectl logs <pod-name> -n factory-plus

# Check events
kubectl get events -n factory-plus
```

#### **Service Not Accessible**
```bash
# Check service endpoints
kubectl get endpoints -n factory-plus

# Check ingress
kubectl describe ingress -n factory-plus

# Check DNS
nslookup manager.factoryplus.amic.com
```

### **Health Checks**
```bash
# Check all pods
kubectl get pods -n factory-plus

# Check service health
curl http://localhost:8081/health
curl http://localhost:8082/health
curl http://localhost:8083/health

# Check MQTT broker
mosquitto_pub -h localhost -t test -m "hello"
```

---

## 📚 **API Endpoints**

### **Manager Service API**
```
GET    /api/organizations          # List organizations
POST   /api/organizations          # Create organization
GET    /api/devices               # List devices
POST   /api/devices               # Add device
GET    /api/schemas               # List data schemas
POST   /api/schemas               # Create schema
GET    /api/users                 # List users
POST   /api/users                 # Create user
```

### **Auth Service API**
```
POST   /auth/login                # User login
POST   /auth/logout               # User logout
GET    /auth/verify               # Verify token
POST   /auth/refresh              # Refresh token
GET    /auth/users                # List users
POST   /auth/users                # Create user
```

### **ConfigDB Service API**
```
GET    /api/config/organizations/{id}     # Get organization config
PUT    /api/config/organizations/{id}     # Update organization config
GET    /api/config/devices                # List device configurations
POST   /api/config/devices                # Create device configuration
PUT    /api/config/devices/{id}           # Update device configuration
DELETE /api/config/devices/{id}           # Delete device configuration
```

---

## 🔒 **Security**

### **User Roles**
```
admin:     Full system access
operator:  Device and data management
viewer:    Read-only access
guest:     Limited access
```

### **Permissions**
```
system:read     - Read system information
system:write    - Modify system settings
users:manage    - Manage user accounts
devices:read    - Read device data
devices:write   - Modify device settings
data:read       - Read data
alerts:manage   - Manage alerts
```

### **Security Headers**
```
X-Forwarded-User: <username>
Authorization: Bearer <token>
Content-Type: application/json
X-Request-ID: <unique-id>
```

---

## 📊 **Monitoring**

### **Key Metrics**
```
- CPU Usage: < 80%
- Memory Usage: < 80%
- Disk Usage: < 85%
- Network Latency: < 100ms
- Service Response Time: < 500ms
```

### **Alert Thresholds**
```
- High CPU: > 80%
- High Memory: > 80%
- High Disk: > 85%
- Service Down: Any service unavailable
- High Latency: > 1000ms
```

---

## 🗂️ **File Locations**

### **Configuration Files**
```
values.yaml                    # Helm values
letsencrypt-issuer.yaml        # Let's Encrypt configuration
factory-plus-ingress.yaml      # Ingress configuration
```

### **Documentation Files**
```
Factory_Plus_Complete_Guide.md
Factory_Plus_Learning_Guide.md
Factory_Plus_Components_Deep_Dive.md
Factory_Plus_Hands_On_Projects.md
Factory_Plus_Quick_Reference.md
```

### **Scripts**
```
Factory_Plus_Quick_Install.ps1
backup_factory_plus.sh
restore_factory_plus.sh
```

---

## 🚀 **Quick Start Commands**

### **Start All Services**
```bash
# Port forward all services
kubectl port-forward svc/manager 8081:80 -n factory-plus &
kubectl port-forward svc/visualiser 8082:80 -n factory-plus &
kubectl port-forward svc/acs-grafana 8083:80 -n factory-plus &
kubectl port-forward svc/auth 8084:80 -n factory-plus &
kubectl port-forward svc/configdb 8085:80 -n factory-plus &
```

### **Check System Status**
```bash
# Check all pods
kubectl get pods -n factory-plus

# Check all services
kubectl get services -n factory-plus

# Check system health
curl http://localhost:8081/health
```

### **Access Services**
```bash
# Open in browser
start http://localhost:8081  # Manager
start http://localhost:8082  # Visualiser
start http://localhost:8083  # Grafana
```

---

## 📞 **Support and Resources**

### **Documentation**
- **Factory+ Framework**: https://factoryplus.app.amrc.co.uk
- **ACS GitHub**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack
- **Local Guides**: All documentation in your project folder

### **Community**
- **GitHub Discussions**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack/discussions
- **Stack Overflow**: Tag questions with `factory-plus`
- **LinkedIn Groups**: Industry 4.0 and Manufacturing

### **Emergency Contacts**
- **System Administrator**: [Your contact]
- **Technical Support**: [Support contact]
- **Emergency Hotline**: [Emergency number]

---

**Remember**: This quick reference is your go-to guide for daily Factory+ operations. Keep it handy and update it as you learn more about your specific setup! 🏭✨
