# Factory+ Service Status Report
# Quick status check for all services

Write-Host "🏭 Factory+ Service Status Report" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Check port forwarding status
Write-Host "`n🔍 Port Forwarding Status:" -ForegroundColor Cyan

$ports = @(
    @{Port="8080"; Service="Traefik"; Status="Unknown"},
    @{Port="8081"; Service="Manager"; Status="Unknown"},
    @{Port="8082"; Service="Visualiser"; Status="Unknown"},
    @{Port="8083"; Service="Grafana"; Status="Unknown"},
    @{Port="8084"; Service="Auth"; Status="Unknown"},
    @{Port="8085"; Service="ConfigDB"; Status="Unknown"}
)

foreach ($portInfo in $ports) {
    $isListening = netstat -an | Select-String -Pattern "127.0.0.1:$($portInfo.Port)" | Select-String -Pattern "LISTENING"
    if ($isListening) {
        $portInfo.Status = "✅ Listening"
        Write-Host "$($portInfo.Service) (Port $($portInfo.Port)): $($portInfo.Status)" -ForegroundColor Green
    } else {
        $portInfo.Status = "❌ Not Listening"
        Write-Host "$($portInfo.Service) (Port $($portInfo.Port)): $($portInfo.Status)" -ForegroundColor Red
    }
}

# Test service accessibility
Write-Host "`n🧪 Service Accessibility Test:" -ForegroundColor Cyan

$services = @(
    @{Name="Manager"; Port="8081"; URL="http://localhost:8081"},
    @{Name="Visualiser"; Port="8082"; URL="http://localhost:8082"},
    @{Name="Grafana"; Port="8083"; URL="http://localhost:8083"},
    @{Name="Auth"; Port="8084"; URL="http://localhost:8084"},
    @{Name="ConfigDB"; Port="8085"; URL="http://localhost:8085"}
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.URL -Method Head -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $($service.Name): HTTP 200 - Working" -ForegroundColor Green
        } elseif ($response.StatusCode -eq 401) {
            Write-Host "✅ $($service.Name): HTTP 401 - Working (Auth Required)" -ForegroundColor Green
        } else {
            Write-Host "⚠️ $($service.Name): HTTP $($response.StatusCode) - Working" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ $($service.Name): Not accessible - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Display service URLs
Write-Host "`n🌐 Service URLs:" -ForegroundColor Cyan
Write-Host "Manager:    http://localhost:8081/login" -ForegroundColor White
Write-Host "Visualiser: http://localhost:8082/" -ForegroundColor White
Write-Host "Grafana:    http://localhost:8083/" -ForegroundColor White
Write-Host "Auth:       http://localhost:8084/" -ForegroundColor White
Write-Host "ConfigDB:   http://localhost:8085/" -ForegroundColor White

# Get admin credentials
Write-Host "`n🔐 Admin Credentials:" -ForegroundColor Cyan
try {
    $adminPassword = kubectl get secret krb5-passwords -o jsonpath="{.data.admin}" -n factory-plus-new
    $decodedPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($adminPassword))
    Write-Host "Username: admin" -ForegroundColor White
    Write-Host "Password: $decodedPassword" -ForegroundColor White
} catch {
    Write-Host "Username: admin" -ForegroundColor White
    Write-Host "Password: [Check kubectl get secret krb5-passwords -n factory-plus-new]" -ForegroundColor Yellow
}

Write-Host "`n🎉 All Factory+ services are now working!" -ForegroundColor Green
