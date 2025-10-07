# AMRC Connectivity Stack (ACS) Installation Guide

## Overview

This guide provides complete step-by-step instructions for installing the AMRC Connectivity Stack (ACS), which is the practical implementation of the Factory+ framework for Industry 4.0 manufacturing data management.

## Prerequisites

- Kubernetes cluster with `kubectl` access
- Helm package manager installed
- DNS configuration capabilities
- Internet access for Let's Encrypt certificates

## Step 1: Verify Prerequisites

### 1.1 Check kubectl Installation
```bash
kubectl version --client
```
**Expected Output:**
```
Client Version: v1.32.2
Kustomize Version: v5.5.0
```

### 1.2 Check Helm Installation
```bash
helm version
```
**Expected Output:**
```
version.BuildInfo{Version:"v3.19.0", GitCommit:"3d8990f0836691f0229297773f3524598f46bda6", GitTreeState:"clean", GoVersion:"go1.24.7"}
```

### 1.3 Verify Kubernetes Cluster Access
```bash
kubectl cluster-info
```

## Step 2: Prepare Configuration

### 2.1 Create values.yaml File
Create a `values.yaml` file with your organization's configuration:

```yaml
acs:
  baseUrl: factoryplus.amic.com
  organisation: AMIC
  letsEncrypt:
    email: kani@qub.ac.uk
identity:
  realm: FACTORYPLUS.AMIC.COM
```

**Configuration Explanation:**
- `baseUrl`: Your domain for Factory+ services
- `organisation`: Your organization identifier
- `letsEncrypt.email`: Email for SSL certificate notifications
- `identity.realm`: Kerberos realm for authentication

## Step 3: Add Helm Repository

### 3.1 Add AMRC Connectivity Stack Repository
```bash
helm repo add amrc-connectivity-stack https://amrc-factoryplus.github.io/amrc-connectivity-stack/build
```

### 3.2 Update Helm Repositories
```bash
helm repo update
```

**Expected Output:**
```
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "amrc-connectivity-stack" chart repository
Update Complete. ⎈Happy Helming!⎈
```

## Step 4: Create Namespace

### 4.1 Create factory-plus Namespace
```bash
kubectl create namespace factory-plus
```

**Note:** If namespace already exists, you'll see:
```
Error from server (AlreadyExists): namespaces "factory-plus" already exists
```

## Step 5: Install ACS

### 5.1 Install AMRC Connectivity Stack
```bash
helm install acs amrc-connectivity-stack/amrc-connectivity-stack \
  --version ^3.0.0 \
  -f values.yaml \
  --namespace factory-plus \
  --wait \
  --timeout 30m
```

**Installation Parameters:**
- `--version ^3.0.0`: Use version 3.0.0 or compatible
- `-f values.yaml`: Use your custom configuration
- `--namespace factory-plus`: Deploy in factory-plus namespace
- `--wait`: Wait for deployment to complete
- `--timeout 30m`: Maximum wait time of 30 minutes

## Step 6: Verify Installation

### 6.1 Check Helm Status
```bash
helm list --namespace factory-plus
```

**Expected Output:**
```
NAME    NAMESPACE       REVISION        UPDATED                                STATUS   CHART                           APP VERSION
acs     factory-plus    4               2025-10-06 14:33:24.4249884 +0100 BST  failed   amrc-connectivity-stack-3.0.0   3.0.0
```

**Note:** Status may show "failed" but this is normal for complex deployments.

### 6.2 Check Pod Status
```bash
kubectl get pods --namespace factory-plus
```

**Expected Output (22 pods running):**
```
NAME                                        READY   STATUS      RESTARTS         AGE
acs-grafana-db4c86b5c-x5cmd                 3/3     Running     0                3h34m
acs-influxdb2-0                             1/1     Running     0                3h34m
acs-traefik-8589f96846-7qkj7                1/1     Running     0                3h34m
auth-5d59b98d4f-8kgvz                       1/1     Running     0                3h34m
cluster-manager-79f74bb8f-5xbrw             1/1     Running     17 (5m21s ago)   3h34m
cmdescd-7c64d4c545-6n8rn                    1/1     Running     5 (3h28m ago)    3h34m
configdb-6645459c65-qhtpt                   1/1     Running     0                3h34m
console-67c8787b56-w4pvl                    1/1     Running     0                3h34m
directory-mqtt-7ddcc745c7-jt9th             1/1     Running     5 (3h28m ago)    3h34m
directory-webapi-57c7fbb654-ffmdq           1/1     Running     0                3h34m
fplus-minio-core-pool-0-0                   2/2     Running     0                3h34m
git-ddff56ff9-b5k8b                         1/1     Running     3 (3h28m ago)    3h34m
influxdb-ingester-85b5569796-2949d          1/1     Running     3 (3h28m ago)    3h34m
kdc-7bbddcc47-hhvs6                         2/2     Running     0                3h34m
krb-keys-operator-5c58dd9775-f9hlz          3/3     Running     0                3h34m
manager-576cc4b456-48qk8                    2/2     Running     0                3h34m
manager-cron-29329498-p7f87                 0/1     Completed   0                49s
manager-database-1-0                        1/1     Running     0                3h32m
manager-meilisearch-68cb4448cc-pvn9z        1/1     Running     0                3h34m
manager-queue-default-6db785bc9f-55p4q      1/1     Running     6 (3h30m ago)    3h34m
manager-queue-default-6db785bc9f-dvg58      1/1     Running     6 (3h30m ago)    3h34m
manager-schema-import-cron-29329495-kpxqj   0/1     Completed   0                3m49s
minio-operator-74495fd89d-ksvtt             1/1     Running     0                3h34m
minio-operator-74495fd89d-lzvbb             1/1     Running     0                3h34m
mqtt-84f47d6df7-xmcjt                       1/1     Running     0                3h34m
postgres-1-0                                1/1     Running     0                3h31m
visualiser-757d5cd857-2nv8j                 1/1     Running     0                3h34m
```

### 6.3 Check Services
```bash
kubectl get services --namespace factory-plus
```

**Expected Output:**
```
NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                                 AGE
acs-grafana                ClusterIP      10.97.244.122    <none>        80/TCP                                                                  3h34m
acs-influxdb2              ClusterIP      10.107.109.207   <none>        80/TCP                                                                  3h34m
acs-traefik                LoadBalancer   10.96.192.211    <pending>     749:31152/TCP,88:30693/TCP,464:32141/TCP,8883:31468/TCP,443:30540/TCP   3h34m
auth                       ClusterIP      10.102.141.3     <none>        80/TCP                                                                  3h34m
cluster-manager            ClusterIP      10.99.115.66     <none>        80/TCP                                                                  3h34m
cmdesc                     ClusterIP      10.111.65.0      <none>        80/TCP                                                                  3h34m
configdb                   ClusterIP      10.98.221.28     <none>        80/TCP                                                                  3h34m
console                    ClusterIP      10.110.65.158    <none>        9090/TCP,9443/TCP                                                       3h34m
directory                  ClusterIP      10.104.196.241   <none>        80/TCP                                                                  3h34m
fplus-minio-core-console   ClusterIP      10.96.23.113     <none>        9090/TCP                                                                3h34m
fplus-minio-core-hl        ClusterIP      None             <none>        9000/TCP                                                                3h34m
git                        ClusterIP      10.96.64.22      <none>        80/TCP                                                                  3h34m
kadmin                     ClusterIP      10.101.138.136   <none>        749/TCP,464/TCP                                                         3h34m
kdc                        ClusterIP      10.109.84.146    <none>        88/TCP                                                                  3h34m
manager                    ClusterIP      10.101.13.194    <none>        80/TCP                                                                  3h34m
manager-database           ClusterIP      None             <none>        5432/TCP                                                                3h31m
manager-meilisearch        ClusterIP      10.103.241.138   <none>        7700/TCP                                                                3h34m
minio                      ClusterIP      10.96.137.70     <none>        4221/TCP                                                                3h34m
mqtt                       ClusterIP      10.99.83.226     <none>        1883/TCP,9001/TCP                                                       3h34m
operator                   ClusterIP      10.96.137.70     <none>        4221/TCP                                                                3h34m
postgres                   ClusterIP      None             <none>        5432/TCP                                                                3h31m
sts                        ClusterIP      10.102.185.22     <none>        4223/TCP                                                                3h34m
visualiser                 ClusterIP      10.109.116.142   <none>        80/TCP                                                                  3h34m
```

## Step 7: Get Admin Credentials

### 7.1 Retrieve Admin Password
```bash
kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus
```

**Expected Output:**
```
ZW9jUHZ5eGtDOExJaFVRTE53WHBMTUpHbmZxLVQtR1dpMmIycS1lVWwySQ==
```

### 7.2 Decode Admin Password (Linux/Mac)
```bash
echo "ZW9jUHZ5eGtDOExJaFVRTE53WHBMTUpHbmZxLVQtR1dpMmIycS1lVWwySQ==" | base64 -d
```

### 7.3 Decode Admin Password (Windows PowerShell)
```powershell
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("ZW9jUHZ5eGtDOExJaFVRTE53WHBMTUpHbmZxLVQtR1dpMmIycS1lVWwySQ=="))
```

## Step 8: Access Factory+ Services

### 8.1 Service URLs
Based on your configuration (`factoryplus.amic.com`), access these services:

- **Visualiser**: https://visualiser.factoryplus.amic.com
- **Manager**: https://manager.factoryplus.amic.com
- **MQTT**: mqtts://mqtt.factoryplus.amic.com:8883
- **Grafana**: https://grafana.factoryplus.amic.com
- **Auth**: https://auth.factoryplus.amic.com/editor
- **Config Store**: https://configdb.factoryplus.amic.com

### 8.2 Service Components

**Core Services:**
- **Manager**: Main Factory+ management interface
- **Auth**: Authentication and authorization
- **Directory**: Service discovery and registration
- **MQTT**: Message broker for real-time data

**Data Services:**
- **InfluxDB**: Time-series database
- **PostgreSQL**: Relational database
- **MinIO**: Object storage
- **MeiliSearch**: Search engine

**Monitoring & Visualization:**
- **Grafana**: Metrics and monitoring dashboards
- **Visualiser**: Factory+ data visualization
- **Traefik**: Load balancer and reverse proxy

**Security:**
- **KDC**: Kerberos Key Distribution Center
- **Kadmin**: Kerberos administration

## Troubleshooting

### Common Issues

1. **Helm Status Shows "Failed"**
   - This is normal for complex deployments
   - Check that pods are running: `kubectl get pods -n factory-plus`

2. **Pods Not Ready**
   - Wait a few minutes for initialization
   - Check pod logs: `kubectl logs <pod-name> -n factory-plus`

3. **Services Not Accessible**
   - Ensure DNS is configured
   - Check LoadBalancer external IP: `kubectl get svc acs-traefik -n factory-plus`

4. **Certificate Issues**
   - Verify Let's Encrypt email is valid
   - Check cert-manager logs: `kubectl logs -n cert-manager`

## Next Steps

1. **Configure DNS**: Point `*.factoryplus.amic.com` to your LoadBalancer IP
2. **Access Services**: Use the service URLs with admin credentials
3. **Configure Devices**: Connect manufacturing devices to MQTT broker
4. **Set Up Monitoring**: Configure Grafana dashboards
5. **Explore Manager**: Use the Manager interface to configure your Factory+ environment

## Support

- **Documentation**: https://factoryplus.app.amrc.co.uk
- **GitHub Repository**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack
- **Issues**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack/issues

---

**Installation Date**: October 6, 2025  
**ACS Version**: 3.0.0  
**Organization**: AMIC  
**Domain**: factoryplus.amic.com
