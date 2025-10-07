# Factory+ New PC Deployment Guide
## Complete Permanent Solution - No Conflicts

### 🎯 **What This Solves**
- ✅ **No conflicts** on new PC installations
- ✅ **All fixes included** - no manual patching needed
- ✅ **Permanent** - survives restarts and upgrades
- ✅ **Reproducible** - same result every time
- ✅ **Clean deployment** - no old configuration conflicts

### 🚀 **Quick Start (3 Steps)**

#### **Step 1: Copy Files**
Copy the entire `New_PC` folder to your new PC.

#### **Step 2: Run Deployment**
```powershell
# Run as Administrator
.\Deploy_Factory_Plus_Permanent.ps1
```

#### **Step 3: Access Services**
- **Manager:** http://localhost:8081/login
- **Visualiser:** http://localhost:8082/
- **Grafana:** http://localhost:8083/
- **Auth:** http://localhost:8084/
- **ConfigDB:** http://localhost:8085/

### 🔐 **Login Credentials**
- **Username:** admin@FACTORYPLUS.AMIC.COM
- **Password:** [Get with: `kubectl get secret admin-password -n factory-plus-new`]

### 📋 **What's Included Permanently**

#### **Manager Fixes:**
- White page issue fixed (APP_URL, ASSET_URL)
- DNS resolution fixed (SERVICE_SCHEME, BASE_URL)
- Service communication fixed (all service URLs)

#### **Service Configuration:**
- All services use internal cluster DNS
- Monitor service disabled (DNS issues)
- Port forwarding automatically started

#### **User Management:**
- Admin user created
- 3 additional users (user1, user2, user3)
- All credentials documented

### 🛠️ **Manual Deployment (Alternative)**

If you prefer manual control:
```powershell
# Deploy with permanent configuration
helm upgrade --install acs amrc-connectivity-stack/acs `
    -n factory-plus-new `
    --create-namespace `
    -f Configurations/values-local.yaml

# Start port forwarding
kubectl port-forward svc/manager 8081:80 -n factory-plus-new
kubectl port-forward svc/visualiser 8082:80 -n factory-plus-new
kubectl port-forward svc/acs-grafana 8083:80 -n factory-plus-new
kubectl port-forward svc/auth 8084:80 -n factory-plus-new
kubectl port-forward svc/configdb 8085:80 -n factory-plus-new
```

### 🎉 **Benefits**

- **No Manual Patching:** All fixes are in the Helm values
- **No Conflicts:** Clean deployment every time
- **Version Controlled:** All changes tracked in Git
- **Team Ready:** Share the folder with your team
- **Upgrade Safe:** Survives Helm upgrades
- **Restart Safe:** Survives pod restarts

### 📁 **File Structure**
```
New_PC/
├── Deploy_Factory_Plus_Permanent.ps1    # Main deployment script
├── Apply_Permanent_Fixes.ps1            # Apply to existing deployment
├── Configurations/
│   ├── values-local.yaml                 # Permanent fixes
│   └── README.md                         # Configuration docs
├── Documentation/
│   └── New_PC_Deployment_Guide.md       # Complete guide
└── README.md                            # Main README
```

### 🔧 **Troubleshooting**

If you encounter issues:
1. **Check prerequisites:** Docker, WSL2, Minikube, kubectl, Helm
2. **Run as Administrator:** All scripts require admin privileges
3. **Check port conflicts:** Ensure ports 8081-8085 are free
4. **Verify deployment:** `kubectl get pods -n factory-plus-new`

### 📞 **Support**

All fixes are documented in:
- `Configurations/README.md` - Configuration details
- `Documentation/` - Complete guides
- `Scripts/` - Utility scripts for maintenance

**This solution ensures you can deploy Factory+ on any new PC without conflicts!** 🏭
