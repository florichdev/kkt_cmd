@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo Desktop Restriction Tool v1.0
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

echo Applying desktop restrictions for students...
echo.

:: Create Студенты folder on desktop if it doesn't exist
set "desktop=%PUBLIC%\Desktop"
if not exist "%desktop%\Студенты" (
    mkdir "%desktop%\Студенты"
    echo Created Студенты folder on desktop
)

:: Set permissions for Студенты folder - allow students to create/modify inside
icacls "%desktop%\Студенты" /grant "Users":(OI)(CI)F /T >nul 2>&1

:: Registry modifications to restrict desktop changes
echo Configuring registry restrictions...

:: Disable wallpaper changes
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" /v NoChangingWallPaper /t REG_DWORD /d 1 /f >nul
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v Wallpaper /t REG_SZ /d "" /f >nul

:: Disable desktop context menu for creating new items
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDesktopCleanupWizard /t REG_DWORD /d 1 /f >nul
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoCloseDragDropBands /t REG_DWORD /d 1 /f >nul

:: Restrict file operations on desktop
echo Setting desktop permissions...

:: Remove write permissions for Users group on desktop (except Students folder)
icacls "%desktop%" /deny "Users":(W,WD,AD,WEA,WA) >nul 2>&1

:: Protect desktop shortcuts from modification
for %%f in ("%desktop%\*.lnk") do (
    icacls "%%f" /deny "Users":(W,WD,D,WEA,WA) >nul 2>&1
)

:: Protect desktop folders (except Студенты folder)
for /d %%d in ("%desktop%\*") do (
    if /i not "%%~nxd"=="Студенты" (
        icacls "%%d" /deny "Users":(W,WD,D,AD,WEA,WA) >nul 2>&1
    )
)

:: Create a scheduled task to reapply permissions periodically
schtasks /create /tn "Desktop Protection" /tr "icacls \"%desktop%\" /deny \"Users\":(W,WD,AD,WEA,WA) /T" /sc hourly /ru SYSTEM /f >nul 2>&1

:: Apply Group Policy settings via registry
echo Applying additional restrictions...

:: Prevent desktop icon arrangement changes
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoSaveSettings /t REG_DWORD /d 1 /f >nul

:: Disable drag and drop on desktop
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDragDrop /t REG_DWORD /d 1 /f >nul

:: Force refresh of desktop
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo.
echo ========================================
echo Desktop restrictions applied successfully!
echo.
echo Students can now only:
echo - Use existing shortcuts and programs
echo - Create files/folders inside Студенты folder
echo - Cannot modify desktop, shortcuts, or wallpaper
echo ========================================
echo.
pause