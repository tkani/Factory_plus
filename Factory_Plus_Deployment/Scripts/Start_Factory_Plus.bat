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
powershell -ExecutionPolicy Bypass -File "Start_Factory_Plus.ps1"

pause
