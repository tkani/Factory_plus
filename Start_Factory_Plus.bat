@echo off
echo Starting Factory+ Services...
echo.

REM Check if running as Administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running as Administrator - Good!
) else (
    echo ERROR: This script requires Administrator privileges.
    echo Please right-click and select "Run as Administrator"
    pause
    exit /b 1
)

echo.
echo Starting Factory+...
powershell -ExecutionPolicy Bypass -File "Factory_Plus_Deployment\Scripts\Restart_Factory_Plus.ps1"

echo.
echo Factory+ services started!
echo.
echo Access URLs:
echo - Manager:    http://localhost:8081/login
echo - Visualiser: http://localhost:8082/
echo - Grafana:    http://localhost:8083/
echo - Auth:       http://localhost:8084/
echo - ConfigDB:   http://localhost:8085/
echo.
echo Login with: admin@FACTORYPLUS.AMIC.COM
echo.

pause
