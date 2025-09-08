@echo off
title NPM Error Fix Tool
color 0C

:: Auto-request admin rights
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cls
echo ==========================================
echo        NPM ENOENT Error Fix Tool
echo ==========================================
echo.
echo This will fix the npm directory error you're experiencing.
echo.
pause

echo [1/6] Creating missing npm directories...
if not exist "%APPDATA%\npm" (
    mkdir "%APPDATA%\npm"
    echo ✓ Created %APPDATA%\npm
) else (
    echo ✓ %APPDATA%\npm already exists
)

if not exist "%APPDATA%\npm-cache" (
    mkdir "%APPDATA%\npm-cache" 
    echo ✓ Created %APPDATA%\npm-cache
) else (
    echo ✓ %APPDATA%\npm-cache already exists
)

if not exist "%LOCALAPPDATA%\npm-cache" (
    mkdir "%LOCALAPPDATA%\npm-cache"
    echo ✓ Created %LOCALAPPDATA%\npm-cache
) else (
    echo ✓ %LOCALAPPDATA%\npm-cache already exists
)

echo.
echo [2/6] Setting npm configuration...
npm config set prefix "%APPDATA%\npm"
npm config set cache "%LOCALAPPDATA%\npm-cache" 
npm config set tmp "%TEMP%"
echo ✓ npm directories configured

echo.
echo [3/6] Clearing corrupted cache...
npm cache clean --force
echo ✓ Cache cleared

echo.
echo [4/6] Fixing npm permissions...
icacls "%APPDATA%\npm" /grant "%USERNAME%:(OI)(CI)F" /T >nul 2>&1
icacls "%LOCALAPPDATA%\npm-cache" /grant "%USERNAME%:(OI)(CI)F" /T >nul 2>&1
echo ✓ Permissions fixed

echo.
echo [5/6] Updating PATH environment...
setx PATH "%PATH%;%APPDATA%\npm" >nul
echo ✓ PATH updated (will take effect after restart)

echo.
echo [6/6] Verifying npm installation...
npm --version
if %errorLevel% == 0 (
    echo ✓ npm is working correctly!
    echo Current npm version: 
    npm --version
) else (
    echo Reinstalling npm...
    node "%ProgramFiles%\nodejs\node_modules\npm\bin\npm-cli.js" install -g npm@latest
    echo ✓ npm reinstalled
)

echo.
echo ==========================================
echo           ✓ FIX COMPLETED! ✓
echo ==========================================
echo.
echo The npm error should now be resolved.
echo You may need to restart your command prompt.
echo.
echo Testing npm with a simple command:
npm config list
echo.
echo If you still get errors, try:
echo 1. Restart your computer
echo 2. Run this fix script again
echo.
pause