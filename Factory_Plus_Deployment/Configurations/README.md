# Factory+ Permanent Configuration

## Overview
This directory contains permanent configuration files that ensure Factory+ works correctly on any new PC without conflicts.

## Files

### `values-local.yaml`
Contains all the fixes applied to make Factory+ work locally:
- Manager service configuration fixes
- DNS resolution fixes
- Service URL configurations
- Monitor service disabled (due to DNS issues)

### Usage

#### For New PC Deployment:
```powershell
# 1. Run the permanent deployment script
.\Scripts\Deploy_Factory_Plus_Permanent.ps1

# 2. Or manually deploy with Helm
helm upgrade --install acs amrc-connectivity-stack/acs -n factory-plus-new --create-namespace -f values-local.yaml
```

#### For Existing Deployment:
```powershell
# Apply permanent configuration to existing deployment
helm upgrade acs amrc-connectivity-stack/acs -n factory-plus-new -f values-local.yaml
```

## Benefits
- ✅ No conflicts on new PC
- ✅ All fixes applied permanently
- ✅ Survives restarts and upgrades
- ✅ Reproducible deployment
- ✅ No manual patching required

## What's Fixed
- Manager white page issue (APP_URL, ASSET_URL)
- DNS resolution errors (SERVICE_SCHEME, BASE_URL)
- Service communication (CONFIGDB_URL, AUTH_URL, DIRECTORY_URL, CLUSTER_MANAGER_URL)
- Monitor service disabled (DNS resolution issues)
- All services use internal cluster DNS

## Quick Start on New PC
1. Copy entire `Factory_Plus_Deployment` folder to new PC
2. Run: `.\Scripts\Deploy_Factory_Plus_Permanent.ps1`
3. Access services at localhost:8081-8085
4. Login with admin@FACTORYPLUS.AMIC.COM
