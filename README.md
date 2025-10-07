# Factory+ Installation Package

## 📁 What You Have

This package contains everything you need to install and run the AMRC Connectivity Stack (Factory+) on a new PC.

### 📚 Main Guide
- **`Factory_Plus_Complete_Guide.md`** - Complete installation and usage guide (everything in one file)

### 🚀 Quick Installation
- **`Factory_Plus_Quick_Install.ps1`** - Automated installation script (run as Administrator)

### ⚙️ Configuration Files
- **`values.yaml`** - ACS configuration (customize for your organization)
- **`letsencrypt-issuer.yaml`** - TLS certificate configuration
- **`factory-plus-ingress.yaml`** - Ingress configuration for production

### 📋 Other Files
- **`pod.yml`** - Example pod configuration
- **`README.md`** - This file

## 🚀 Quick Start

### Option 1: Automated Installation (Recommended)
```powershell
# Run PowerShell as Administrator
.\Factory_Plus_Quick_Install.ps1 -Organization "YOUR_ORG" -Email "your-email@domain.com"
```

### Option 2: Manual Installation
Follow the complete guide in `Factory_Plus_Complete_Guide.md`

## 📖 What's Included

The complete guide covers:
- ✅ **Prerequisites** - All required software
- ✅ **Installation** - Step-by-step setup
- ✅ **Configuration** - TLS certificates and ingress
- ✅ **Service Access** - Port forwarding and URLs
- ✅ **Troubleshooting** - Solutions for all common issues
- ✅ **Production Deployment** - DNS and LoadBalancer setup
- ✅ **Reference** - Essential commands and URLs

## 🏭 What You Get

After installation, you'll have:
- **Manager** - Main Factory+ interface (http://localhost:8081/login)
- **Visualiser** - Data visualization (http://localhost:8082/)
- **Grafana** - Monitoring dashboards (http://localhost:8083/)
- **Auth** - Authentication system (http://localhost:8084/)
- **ConfigDB** - Configuration store (http://localhost:8085/)
- **MQTT** - Real-time message broker
- **Complete Data Infrastructure** - InfluxDB, PostgreSQL, MinIO
- **Security** - Kerberos authentication and TLS certificates

## 🔐 Login Credentials

- **Username**: `admin`
- **Password**: (Get with command in the guide)

## 📞 Support

- **Complete Guide**: `Factory_Plus_Complete_Guide.md`
- **Factory+ Documentation**: https://factoryplus.app.amrc.co.uk
- **ACS GitHub**: https://github.com/AMRC-FactoryPlus/amrc-connectivity-stack

## 🎯 Next Steps

1. **Read the guide**: `Factory_Plus_Complete_Guide.md`
2. **Run the installer**: `.\Factory_Plus_Quick_Install.ps1`
3. **Access services**: http://localhost:8081/login
4. **Configure Factory+**: Follow the guide for setup

---

**Your Factory+ framework is ready to transform your manufacturing operations!** 🏭✨
