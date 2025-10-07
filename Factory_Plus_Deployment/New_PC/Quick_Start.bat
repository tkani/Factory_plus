@echo off
echo ========================================
echo   Factory+ New PC Quick Start
echo ========================================
echo.
echo This will deploy Factory+ with all fixes applied permanently.
echo.
echo Prerequisites:
echo - Docker Desktop
echo - WSL2
echo - Minikube
echo - kubectl
echo - Helm
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause >nul

echo.
echo Starting Factory+ deployment...
echo.

powershell -ExecutionPolicy Bypass -File "Deploy_Factory_Plus_Permanent.ps1"

echo.
echo Deployment complete! Press any key to exit...
pause >nul
