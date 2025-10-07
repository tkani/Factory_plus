@echo off
echo ========================================
echo    Factory+ Deployment Package
echo ========================================
echo.

echo Choose an option:
echo.
echo 1. Setup Factory+ on New Computer
echo 2. Start Factory+ Services (Daily Use)
echo 3. Restart Factory+ (Troubleshooting)
echo 4. Open Documentation
echo 5. Open Learning Materials
echo 6. Exit
echo.

set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" (
    echo.
    echo Starting Factory+ Setup for New Computer...
    echo.
    cd Scripts
    powershell -ExecutionPolicy Bypass -File "Setup_Factory_Plus_New_Computer.ps1"
    pause
) else if "%choice%"=="2" (
    echo.
    echo Starting Factory+ Services...
    echo.
    cd Scripts
    .\Start_Factory_Plus.bat
) else if "%choice%"=="3" (
    echo.
    echo Restarting Factory+ with Diagnostics...
    echo.
    cd Scripts
    powershell -ExecutionPolicy Bypass -File "Restart_Factory_Plus.ps1"
    pause
) else if "%choice%"=="4" (
    echo.
    echo Opening Documentation...
    start Documentation
) else if "%choice%"=="5" (
    echo.
    echo Opening Learning Materials...
    start Learning
) else if "%choice%"=="6" (
    echo.
    echo Goodbye!
    exit
) else (
    echo.
    echo Invalid choice. Please try again.
    pause
    goto :eof
)
