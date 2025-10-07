# Factory+ Deployment Package
## AMRC Connectivity Stack (ACS) - Organized Deployment

---

## 📁 **Folder Structure**

```
Factory_Plus_Deployment/
├── 📁 Scripts/                    # All deployment and management scripts
├── 📁 Documentation/              # Complete guides and documentation
├── 📁 Configurations/             # YAML configuration files
├── 📁 Learning/                   # Learning materials and tutorials
└── 📄 README.md                   # This file
```

---

## 🚀 **Quick Start Guide**

### **For New Computer Setup (Permanent Solution):**
```powershell
# Run PowerShell as Administrator
cd Scripts
.\Deploy_Factory_Plus_Permanent.ps1
```

### **For Existing Deployment (Apply Permanent Fixes):**
```powershell
# Run PowerShell as Administrator
cd Scripts
.\Apply_Permanent_Fixes.ps1
```

### **For Daily Startup:**
```powershell
# Double-click or run as Administrator
cd Scripts
.\Start_Factory_Plus.bat
```

### **For Troubleshooting:**
```powershell
cd Scripts
.\Restart_Factory_Plus.ps1
```

---

## 📁 **Scripts Folder**

| File | Purpose | When to Use |
|------|---------|-------------|
| **`Setup_Factory_Plus_New_Computer.ps1`** | One-command setup for new computers | First-time installation |
| **`Factory_Plus_Complete_Deployment.ps1`** | Full deployment with all fixes | Advanced setup |
| **`Start_Factory_Plus.bat`** | Quick daily startup | Every time you boot laptop |
| **`Start_Factory_Plus.ps1`** | PowerShell startup script | Alternative to .bat |
| **`Restart_Factory_Plus.ps1`** | Full restart with diagnostics | When issues occur |
| **`Factory_Plus_Quick_Install.ps1`** | Original quick install | Legacy method |

### **Script Usage:**

#### **New Computer Setup:**
```powershell
cd Scripts
.\Setup_Factory_Plus_New_Computer.ps1 -Organization "YOUR_ORG" -Email "your-email@domain.com"
```

#### **Daily Startup:**
```powershell
cd Scripts
.\Start_Factory_Plus.bat
```

#### **Troubleshooting:**
```powershell
cd Scripts
.\Restart_Factory_Plus.ps1
```

---

## 📚 **Documentation Folder**

| File | Purpose |
|------|---------|
| **`Factory_Plus_New_Computer_Deployment.md`** | Complete deployment guide for new computers |
| **`Factory_Plus_Complete_Guide.md`** | Comprehensive Factory+ guide |
| **`Factory_Plus_Final_Complete_Status.md`** | Current deployment status |
| **`Factory_Plus_Quick_Reference.md`** | Quick reference commands |
| **`Factory_Plus_Troubleshooting_Complete.md`** | Complete troubleshooting guide |
| **`AMRC_Connectivity_Stack_Complete_Summary.md`** | ACS stack overview |

### **Key Documentation:**

#### **For New Users:**
- Start with: `Factory_Plus_New_Computer_Deployment.md`
- Quick reference: `Factory_Plus_Quick_Reference.md`

#### **For Advanced Users:**
- Complete guide: `Factory_Plus_Complete_Guide.md`
- Troubleshooting: `Factory_Plus_Troubleshooting_Complete.md`

---

## ⚙️ **Configurations Folder**

| File | Purpose |
|------|---------|
| **`values.yaml`** | Main Factory+ configuration |
| **`values-minimal.yaml`** | Minimal configuration template |
| **`factory-plus-ingress.yaml`** | Ingress configuration for services |
| **`letsencrypt-issuer.yaml`** | TLS certificate configuration |
| **`patch-namespace.yaml`** | Namespace configuration |

### **Configuration Usage:**

#### **Custom Configuration:**
1. Edit `values.yaml` with your settings
2. Run deployment script
3. Configuration will be applied automatically

#### **Minimal Setup:**
1. Use `values-minimal.yaml` as template
2. Modify for your environment
3. Deploy with custom values

---

## 🎓 **Learning Folder**

| File | Purpose |
|------|---------|
| **`Factory_Plus_Components_Deep_Dive.md`** | Deep dive into Factory+ components |
| **`Factory_Plus_Hands_On_Projects.md`** | Hands-on learning projects |
| **`Factory_Plus_Learning_Guide.md`** | Complete learning path |
| **`Factory_Plus_Quick_Reference.md`** | Quick reference for learning |

### **Learning Path:**

1. **Start Here:** `Factory_Plus_Learning_Guide.md`
2. **Deep Dive:** `Factory_Plus_Components_Deep_Dive.md`
3. **Hands-On:** `Factory_Plus_Hands_On_Projects.md`
4. **Reference:** `Factory_Plus_Quick_Reference.md`

---

## 🎯 **Common Use Cases**

### **1. First-Time Setup on New Computer**
```powershell
cd Scripts
.\Setup_Factory_Plus_New_Computer.ps1 -Organization "YOUR_ORG" -Email "your-email@domain.com"
```

### **2. Daily Startup After Laptop Boot**
```powershell
cd Scripts
.\Start_Factory_Plus.bat
```

### **3. Troubleshooting Issues**
```powershell
cd Scripts
.\Restart_Factory_Plus.ps1
```

### **4. Advanced Configuration**
1. Edit files in `Configurations/` folder
2. Run `Factory_Plus_Complete_Deployment.ps1`
3. Apply custom settings

### **5. Learning Factory+**
1. Read `Documentation/Factory_Plus_Learning_Guide.md`
2. Follow hands-on projects in `Learning/` folder
3. Use quick reference for commands

---

## 🔧 **Service Access**

After running startup scripts, access services at:

| Service | URL | Purpose |
|---------|-----|---------|
| **Manager** | http://localhost:8081/login | Main Factory+ interface |
| **Visualiser** | http://localhost:8082/ | Data visualization |
| **Grafana** | http://localhost:8083/ | Monitoring dashboards |
| **Auth** | http://localhost:8084/ | Authentication services |
| **ConfigDB** | http://localhost:8085/ | Configuration database |

### **Default Login:**
- **Username:** admin
- **Password:** [Generated during installation]

---

## 🛠️ **Troubleshooting**

### **Common Issues:**

#### **Services Not Starting:**
```powershell
cd Scripts
.\Restart_Factory_Plus.ps1
```

#### **White Page on Manager:**
- Configuration fix is applied automatically
- If issue persists, run restart script

#### **Port Forwarding Issues:**
```powershell
Get-Process | Where-Object {$_.ProcessName -eq "kubectl"} | Stop-Process -Force
cd Scripts
.\Start_Factory_Plus.ps1
```

#### **Minikube Issues:**
```powershell
minikube delete
minikube start --memory=8192 --cpus=4 --disk-size=50g
```

### **Diagnostic Commands:**
```powershell
# Check pod status
kubectl get pods -n factory-plus

# Check services
kubectl get svc -n factory-plus

# Check logs
kubectl logs -n factory-plus -l component=manager
```

---

## 📋 **File Organization Summary**

### **Scripts/ - Automation & Management**
- ✅ All deployment scripts
- ✅ Startup scripts
- ✅ Troubleshooting scripts
- ✅ One-command setup

### **Documentation/ - Guides & References**
- ✅ Complete deployment guides
- ✅ Troubleshooting documentation
- ✅ Quick reference materials
- ✅ Status reports

### **Configurations/ - YAML Files**
- ✅ Main configuration files
- ✅ Ingress configurations
- ✅ TLS certificate settings
- ✅ Namespace configurations

### **Learning/ - Educational Materials**
- ✅ Learning guides
- ✅ Hands-on projects
- ✅ Component deep dives
- ✅ Quick references

---

## 🎉 **Ready to Use!**

Your Factory+ deployment package is now organized and ready for:

1. **New Computer Setup** - Use Scripts folder
2. **Daily Operations** - Use startup scripts
3. **Troubleshooting** - Use diagnostic scripts
4. **Learning** - Use Learning folder
5. **Configuration** - Use Configurations folder

**Everything is organized, documented, and ready to use!** 🏭
