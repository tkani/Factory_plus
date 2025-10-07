# Factory+ All Services Check Script
# Verifies all services are running and accessible

Write-Host "🏭 Factory+ All Services Check" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 1: Check Minikube Status
Write-Host "`n🔍 Step 1: Checking Minikube Status..." -ForegroundColor Cyan

try {
    $minikubeStatus = minikube status --format="json" | ConvertFrom-Json
    if ($minikubeStatus.Host -eq "Running") {
        Write-Host "✅ Minikube is running" -ForegroundColor Green
    } else {
        Write-Host "❌ Minikube is not running. Starting Minikube..." -ForegroundColor Yellow
        minikube start --memory=8192 --cpus=4 --disk-size=50g
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Minikube started successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to start Minikube" -ForegroundColor Red
            exit 1
        }
    }
} catch {
    Write-Host "❌ Minikube not found. Please install Minikube first." -ForegroundColor Red
    exit 1
}

# Step 2: Check Pod Status
Write-Host "`n🔍 Step 2: Checking Pod Status..." -ForegroundColor Cyan

Write-Host "Current pod status:" -ForegroundColor Yellow
kubectl get pods -n factory-plus-new

# Check for any pods not running
$notRunningPods = kubectl get pods -n factory-plus-new --field-selector=status.phase!=Running --no-headers
if ($notRunningPods) {
    Write-Host "`n⚠️ Some pods are not running:" -ForegroundColor Yellow
    $notRunningPods
} else {
    Write-Host "`n✅ All pods are running" -ForegroundColor Green
}

# Step 3: Check Services
Write-Host "`n🔍 Step 3: Checking Services..." -ForegroundColor Cyan

Write-Host "Current service status:" -ForegroundColor Yellow
kubectl get svc -n factory-plus-new

# Step 4: Check Port Forwarding
Write-Host "`n🔍 Step 4: Checking Port Forwarding..." -ForegroundColor Cyan

$kubectlProcesses = Get-Process | Where-Object {$_.ProcessName -eq "kubectl"}
Write-Host "Active kubectl processes: $($kubectlProcesses.Count)" -ForegroundColor Yellow

# Check which ports are listening
$listeningPorts = netstat -an | Select-String -Pattern "808[0-9]" | Select-String -Pattern "LISTENING"
Write-Host "Listening ports:" -ForegroundColor Yellow
$listeningPorts

# Step 5: Test Service Access
Write-Host "`n🧪 Step 5: Testing Service Access..." -ForegroundColor Cyan

$services = @(
    @{Name="Manager"; Port="8081"; URL="http://localhost:8081"},
    @{Name="Visualiser"; Port="8082"; URL="http://localhost:8082"},
    @{Name="Grafana"; Port="8083"; URL="http://localhost:8083"},
    @{Name="Auth"; Port="8084"; URL="http://localhost:8084"},
    @{Name="ConfigDB"; Port="8085"; URL="http://localhost:8085"}
)

$serviceStatus = @()

foreach ($service in $services) {
    Write-Host "Testing $($service.Name) on port $($service.Port)..." -ForegroundColor Yellow
    
    try {
        $response = Invoke-WebRequest -Uri $service.URL -Method Head -TimeoutSec 5
        $status = "✅ $($service.Name): $($response.StatusCode) - Working"
        $serviceStatus += $status
        Write-Host $status -ForegroundColor Green
    } catch {
        $status = "❌ $($service.Name): Not accessible - $($_.Exception.Message)"
        $serviceStatus += $status
        Write-Host $status -ForegroundColor Red
    }
}

# Step 6: Start Missing Port Forwards
Write-Host "`n🔗 Step 6: Starting Missing Port Forwards..." -ForegroundColor Cyan

$requiredPorts = @(8081, 8082, 8083, 8084, 8085)
$missingPorts = @()

foreach ($port in $requiredPorts) {
    $isListening = netstat -an | Select-String -Pattern "127.0.0.1:$port" | Select-String -Pattern "LISTENING"
    if (-not $isListening) {
        $missingPorts += $port
        Write-Host "⚠️ Port $port is not listening" -ForegroundColor Yellow
    }
}

if ($missingPorts.Count -gt 0) {
    Write-Host "Starting missing port forwards..." -ForegroundColor Yellow
    
    # Start missing port forwards
    if ($missingPorts -contains 8081) {
        Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/manager", "8081:80", "-n", "factory-plus-new" -WindowStyle Hidden
        Write-Host "✅ Started Manager port forward (8081)" -ForegroundColor Green
    }
    
    if ($missingPorts -contains 8082) {
        Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/visualiser", "8082:80", "-n", "factory-plus-new" -WindowStyle Hidden
        Write-Host "✅ Started Visualiser port forward (8082)" -ForegroundColor Green
    }
    
    if ($missingPorts -contains 8083) {
        Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/acs-grafana", "8083:80", "-n", "factory-plus-new" -WindowStyle Hidden
        Write-Host "✅ Started Grafana port forward (8083)" -ForegroundColor Green
    }
    
    if ($missingPorts -contains 8084) {
        Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/auth", "8084:80", "-n", "factory-plus-new" -WindowStyle Hidden
        Write-Host "✅ Started Auth port forward (8084)" -ForegroundColor Green
    }
    
    if ($missingPorts -contains 8085) {
        Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/configdb", "8085:80", "-n", "factory-plus-new" -WindowStyle Hidden
        Write-Host "✅ Started ConfigDB port forward (8085)" -ForegroundColor Green
    }
    
    # Wait for port forwards to start
    Write-Host "⏳ Waiting for port forwards to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    # Test again
    Write-Host "`n🧪 Re-testing Service Access..." -ForegroundColor Cyan
    foreach ($service in $services) {
        Write-Host "Testing $($service.Name)..." -ForegroundColor Yellow
        
        try {
            $response = Invoke-WebRequest -Uri $service.URL -Method Head -TimeoutSec 5
            Write-Host "✅ $($service.Name): $($response.StatusCode) - Working" -ForegroundColor Green
        } catch {
            Write-Host "❌ $($service.Name): Still not accessible" -ForegroundColor Red
        }
    }
} else {
    Write-Host "✅ All required ports are already listening" -ForegroundColor Green
}

# Step 7: Final Status Report
Write-Host "`n📊 Step 7: Final Status Report..." -ForegroundColor Cyan

Write-Host "`n🌐 Service URLs:" -ForegroundColor Cyan
Write-Host "Manager:    http://localhost:8081/login" -ForegroundColor White
Write-Host "Visualiser: http://localhost:8082/" -ForegroundColor White
Write-Host "Grafana:    http://localhost:8083/" -ForegroundColor White
Write-Host "Auth:       http://localhost:8084/" -ForegroundColor White
Write-Host "ConfigDB:   http://localhost:8085/" -ForegroundColor White

Write-Host "`n🔐 Login Credentials:" -ForegroundColor Cyan
try {
    $adminPassword = kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus-new
    $decodedPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($adminPassword))
    Write-Host "Username: admin" -ForegroundColor White
    Write-Host "Password: $decodedPassword" -ForegroundColor White
} catch {
    Write-Host "Username: admin" -ForegroundColor White
    Write-Host "Password: [Check kubectl get secret krb5-passwords -n factory-plus-new]" -ForegroundColor Yellow
}

Write-Host "`n📋 Port Forwarding Status:" -ForegroundColor Cyan
$activePorts = netstat -an | Select-String -Pattern "808[0-9]" | Select-String -Pattern "LISTENING"
foreach ($port in $activePorts) {
    Write-Host "✅ $port" -ForegroundColor Green
}

Write-Host "`n🎉 Factory+ Services Check Complete!" -ForegroundColor Green
Write-Host "All services should now be accessible at the URLs above." -ForegroundColor Green

Read-Host "`nPress Enter to continue"
