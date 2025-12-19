@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo Desktop Restore Tool v1.0
echo ========================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo Removing desktop restrictions...
echo.

set "desktop=%PUBLIC%\Desktop"

:: Remove registry restrictions
echo Removing registry restrictions...

:: Remove wallpaper restrictions
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" /v NoChangingWallPaper /f >nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v Wallpaper /f >nul 2>&1

:: Remove desktop restrictions
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDesktopCleanupWizard /f >nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoCloseDragDropBands /f >nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoSaveSettings /f >nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDragDrop /f >nul 2>&1

:: Restore full permissions to desktop
echo Restoring desktop permissions...
icacls "%desktop%" /grant "Users":F /T >nul 2>&1

:: Restore permissions to all desktop shortcuts
for %%f in ("%desktop%\*.lnk") do (
    icacls "%%f" /grant "Users":F >nul 2>&1
)

:: Restore permissions to all desktop folders
for /d %%d in ("%desktop%\*") do (
    icacls "%%d" /grant "Users":F /T >nul 2>&1
)

:: Remove the scheduled task
schtasks /delete /tn "Desktop Protection" /f >nul 2>&1

:: Reset desktop to default state
echo Resetting desktop...

:: Force refresh of desktop and explorer
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 >nul
start explorer.exe

:: Clear any cached policies
gpupdate /force >nul 2>&1

echo.
echo ========================================
echo Desktop restrictions removed successfully!
echo.
echo All desktop functionality has been restored:
echo - Students can now modify wallpaper
echo - Students can create/delete files on desktop
echo - Students can modify shortcuts
echo - All permissions restored to default
echo ========================================
echo.
echo NOTE: If desktop icons are missing, try:
echo 1. Right-click desktop - View - Show desktop icons
echo 2. Restart the computer if issues persist
echo.
pause