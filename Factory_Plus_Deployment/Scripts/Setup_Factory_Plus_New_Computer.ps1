# Factory+ New Computer Setup Script
# One-command deployment for fresh installations

param(
    [Parameter(Mandatory=$true)]
    [string]$Organization,
    
    [Parameter(Mandatory=$true)]
    [string]$Email
)

Write-Host "🏭 Factory+ New Computer Setup" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host "Organization: $Organization" -ForegroundColor Yellow
Write-Host "Email: $Email" -ForegroundColor Yellow

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Download and run the complete deployment script
Write-Host "`n📥 Downloading Factory+ Complete Deployment Script..." -ForegroundColor Cyan

$deploymentScript = "Factory_Plus_Complete_Deployment.ps1"
if (!(Test-Path $deploymentScript)) {
    Write-Host "❌ Deployment script not found. Please ensure Factory_Plus_Complete_Deployment.ps1 is in the current directory." -ForegroundColor Red
    Write-Host "You can download it from the Factory+ repository or create it manually." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✅ Deployment script found" -ForegroundColor Green

# Run the complete deployment
Write-Host "`n🚀 Starting Factory+ Complete Deployment..." -ForegroundColor Cyan
Write-Host "This will install all prerequisites and deploy Factory+ with all fixes applied." -ForegroundColor Yellow
Write-Host "The process may take 15-20 minutes..." -ForegroundColor Yellow

& ".\$deploymentScript" -Organization $Organization -Email $Email

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n🎉 Factory+ Setup Complete!" -ForegroundColor Green
    Write-Host "=========================" -ForegroundColor Green
    
    Write-Host "`n✅ Factory+ has been successfully deployed on your new computer!" -ForegroundColor Green
    
    Write-Host "`n📋 Quick Start:" -ForegroundColor Cyan
    Write-Host "1. Run: .\start-services.ps1" -ForegroundColor White
    Write-Host "2. Open: http://localhost:8081/login" -ForegroundColor White
    Write-Host "3. Login with admin credentials" -ForegroundColor White
    
    Write-Host "`n🛠️ If you encounter issues:" -ForegroundColor Cyan
    Write-Host "Run: .\troubleshoot.ps1" -ForegroundColor White
    
    Write-Host "`n📚 Documentation:" -ForegroundColor Cyan
    Write-Host "- Factory_Plus_New_Computer_Deployment.md" -ForegroundColor White
    Write-Host "- https://factoryplus.app.amrc.co.uk" -ForegroundColor White
    
    Write-Host "`n🏭 Your Factory+ framework is ready!" -ForegroundColor Green
} else {
    Write-Host "`n❌ Factory+ Setup Failed!" -ForegroundColor Red
    Write-Host "Please check the error messages above and try again." -ForegroundColor Yellow
    Write-Host "You can also run .\troubleshoot.ps1 for diagnostic information." -ForegroundColor Yellow
}

Read-Host "`nPress Enter to exit"
