# AMRC Connectivity Stack - Next Steps Configuration Guide

## Overview

This guide covers the post-installation configuration steps for the AMRC Connectivity Stack (ACS), including DNS setup, TLS certificate configuration, service access, and initial Factory+ environment setup.

## Current Status

✅ **Completed:**
- ACS installation successful
- All core services running (22 pods)
- cert-manager installed for TLS certificates
- Admin credentials retrieved

⚠️ **Pending:**
- DNS configuration for external access
- TLS certificate generation
- Service accessibility testing
- Factory+ environment configuration

## Step 1: DNS Configuration

### 1.1 Current LoadBalancer Status
```bash
kubectl get svc acs-traefik -n factory-plus
```

**Current Output:**
```
NAME          TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                 AGE
acs-traefik   LoadBalancer   10.96.192.211   <pending>     749:31152/TCP,88:30693/TCP,464:32141/TCP,8883:31468/TCP,443:30540/TCP   3h41m
```

**Note:** External-IP shows `<pending>` because you're using Minikube. In production, this would show your LoadBalancer IP.

### 1.2 Minikube LoadBalancer Configuration

For Minikube, you need to use the tunnel command:

```bash
# Start Minikube tunnel (run in separate terminal)
minikube tunnel
```

**Expected Output:**
```
Status:	machine: 192.168.49.2
Status:	services: [acs-traefik]
```

### 1.3 Get External IP
```bash
kubectl get svc acs-traefik -n factory-plus
```

After tunnel is running, you should see an external IP assigned.

### 1.4 DNS Configuration (Production)

For production deployment, configure your DNS records:

**Required DNS Records:**
```
# Root domain
factoryplus.amic.com          A    <LOADBALANCER_IP>

# Wildcard subdomain
*.factoryplus.amic.com        A    <LOADBALANCER_IP>
```

**Service-specific subdomains:**
- `visualiser.factoryplus.amic.com`
- `manager.factoryplus.amic.com`
- `mqtt.factoryplus.amic.com`
- `grafana.factoryplus.amic.com`
- `auth.factoryplus.amic.com`
- `configdb.factoryplus.amic.com`

## Step 2: TLS Certificate Configuration

### 2.1 Verify cert-manager Installation
```bash
kubectl get pods -n cert-manager
```

**Expected Output:**
```
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-c8ddc75bc-g68bl               1/1     Running   0          42s
cert-manager-cainjector-7d4f95c968-k2cms   1/1     Running   0          42s
cert-manager-webhook-5d776c5db-mkxn5       1/1     Running   0          42s
```

### 2.2 Create Let's Encrypt ClusterIssuer

Create a file `letsencrypt-issuer.yaml`:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: kani@qub.ac.uk
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: traefik
```

### 2.3 Apply ClusterIssuer
```bash
kubectl apply -f letsencrypt-issuer.yaml
```

### 2.4 Verify ClusterIssuer
```bash
kubectl get clusterissuer
```

**Expected Output:**
```
NAME               READY   AGE
letsencrypt-prod   True    1m
```

## Step 3: Service Access Testing

### 3.1 Test Internal Connectivity
```bash
# Test Traefik service
kubectl port-forward svc/acs-traefik 8080:80 -n factory-plus
```

### 3.2 Access Services via Port Forward

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

### 3.3 Test MQTT Connection
```bash
# Test MQTT broker connectivity
kubectl port-forward svc/mqtt 1883:1883 -n factory-plus
```

## Step 4: Factory+ Environment Configuration

### 4.1 Access Manager Interface

1. **Open Manager**: Navigate to the Manager service
2. **Login**: Use admin credentials
3. **Initial Setup**: Follow the setup wizard

### 4.2 Configure Organization Settings

**Organization Details:**
- Name: AMIC
- Domain: factoryplus.amic.com
- Realm: FACTORYPLUS.AMIC.COM

### 4.3 Set Up Data Schemas

**Create Initial Schemas:**
1. Navigate to Schema Management
2. Import standard Factory+ schemas
3. Configure custom schemas for your organization

### 4.4 Configure MQTT Topics

**Standard Topics:**
- `spBv1.0/AMIC/DDATA/+/+` - Device data
- `spBv1.0/AMIC/DBIRTH/+/+` - Device birth messages
- `spBv1.0/AMIC/DDEATH/+/+` - Device death messages

## Step 5: Device Integration

### 5.1 MQTT Client Configuration

**Connection Details:**
- Broker: `mqtt.factoryplus.amic.com:8883`
- Protocol: MQTT over TLS
- Authentication: Kerberos (SPNEGO)

### 5.2 Edge Gateway Setup

**Cell Gateway Configuration:**
1. Install Edge Agent
2. Configure OPC UA connections
3. Set up Sparkplug B encoding
4. Connect to MQTT broker

### 5.3 Data Flow Configuration

**Standard Data Flow:**
1. **Edge**: OPC UA → Cell Gateway
2. **Transport**: Sparkplug B → MQTT
3. **Processing**: InfluxDB → Time Series
4. **Storage**: MinIO → Object Storage
5. **Visualization**: Grafana → Dashboards

## Step 6: Monitoring and Maintenance

### 6.1 Health Checks

**Service Health:**
```bash
# Check all pods
kubectl get pods -n factory-plus

# Check service status
kubectl get svc -n factory-plus

# Check ingress
kubectl get ingress -n factory-plus
```

### 6.2 Log Monitoring

**Key Services to Monitor:**
```bash
# Manager logs
kubectl logs -f deployment/manager -n factory-plus

# MQTT logs
kubectl logs -f deployment/mqtt -n factory-plus

# Traefik logs
kubectl logs -f deployment/acs-traefik -n factory-plus
```

### 6.3 Backup Configuration

**Database Backups:**
```bash
# PostgreSQL backup
kubectl exec -it postgres-1-0 -n factory-plus -- pg_dumpall > factory-plus-backup.sql

# MinIO backup
kubectl exec -it fplus-minio-core-pool-0-0 -n factory-plus -- mc mirror /data /backup
```

## Step 7: Security Configuration

### 7.1 Kerberos Authentication

**KDC Configuration:**
- Realm: FACTORYPLUS.AMIC.COM
- Admin Principal: admin@FACTORYPLUS.AMIC.COM
- Service Principals: Configured automatically

### 7.2 TLS Certificate Management

**Certificate Renewal:**
- Automatic renewal via Let's Encrypt
- Monitor certificate status: `kubectl get certificates -n factory-plus`

### 7.3 Network Security

**Firewall Rules:**
- Port 443 (HTTPS): Web services
- Port 8883 (MQTTS): MQTT broker
- Port 80 (HTTP): Redirect to HTTPS

## Troubleshooting

### Common Issues

1. **Services Not Accessible**
   - Check DNS configuration
   - Verify LoadBalancer external IP
   - Test port forwarding

2. **TLS Certificate Issues**
   - Check cert-manager logs
   - Verify DNS resolution
   - Test Let's Encrypt connectivity

3. **MQTT Connection Issues**
   - Verify broker configuration
   - Check authentication
   - Test network connectivity

4. **Database Connection Issues**
   - Check PostgreSQL status
   - Verify connection strings
   - Check resource limits

### Diagnostic Commands

```bash
# Check all resources
kubectl get all -n factory-plus

# Check events
kubectl get events -n factory-plus --sort-by='.lastTimestamp'

# Check resource usage
kubectl top pods -n factory-plus

# Check persistent volumes
kubectl get pv,pvc -n factory-plus
```

## Next Steps Summary

1. ✅ **DNS Configuration**: Set up external access
2. ✅ **TLS Certificates**: Configure SSL/TLS
3. ✅ **Service Testing**: Verify all services
4. ✅ **Factory+ Setup**: Configure environment
5. ✅ **Device Integration**: Connect manufacturing devices
6. ✅ **Monitoring**: Set up monitoring and alerts
7. ✅ **Security**: Configure authentication and authorization

## Support and Resources

- **Factory+ Documentation**: https://factoryplus.app.amrc.co.uk
- **ACS GitHub**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack
- **Community Support**: GitHub Issues and Discussions
- **Training Materials**: AMRC Factory+ Training Program

---

**Configuration Date**: October 6, 2025  
**ACS Version**: 3.0.0  
**Organization**: AMIC  
**Domain**: factoryplus.amic.com  
**Status**: Ready for Production Deployment
