@echo off
title Node.js and Playwright Installer
color 0A

:: Auto-request admin rights
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cls
echo ==========================================
echo    Node.js and Playwright Auto-Installer
echo ==========================================
echo.

:: Check if Node.js exists
echo [1/3] Checking Node.js installation...
node --version >nul 2>&1
if %errorLevel% == 0 (
    echo ✓ Node.js already installed
    node --version
    goto playwright
)

echo [2/3] Installing Node.js...
echo Downloading Node.js LTS...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://nodejs.org/dist/v20.17.0/node-v20.17.0-x64.msi' -OutFile '%temp%\node.msi'"

if not exist "%temp%\node.msi" (
    echo ✗ Download failed. Check internet connection.
    pause
    exit /b 1
)

echo Installing Node.js (please wait)...
msiexec /i "%temp%\node.msi" /quiet /norestart
timeout /t 15 /nobreak >nul

:: Refresh PATH
call refreshenv >nul 2>&1
set PATH=%PATH%;%ProgramFiles%\nodejs

echo ✓ Node.js installation completed

:playwright
echo [3/3] Installing Playwright...
echo This may take 2-3 minutes...
npx playwright install

if %errorLevel% == 0 (
    echo.
    echo ==========================================
    echo           ✓ SUCCESS! ✓
    echo ==========================================
    echo.
    echo Node.js and Playwright installed successfully!
    echo You can now use: npx playwright test
    echo.
) else (
    echo ✗ Playwright installation failed
)



