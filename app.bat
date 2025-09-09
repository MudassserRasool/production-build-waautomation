echo Installing Desktop Setup 1.0.0...

:: Backup browser-profiles folder if it exists
set "RESOURCES_DIR=%LOCALAPPDATA%\Programs\desktop\resources"
set "BROWSER_PROFILES_SOURCE=%RESOURCES_DIR%\browser-profiles"
set "BROWSER_PROFILES_BACKUP=%LOCALAPPDATA%\Temp\browser-profiles-backup"

echo Checking for existing browser-profiles folder...
if exist "%BROWSER_PROFILES_SOURCE%" (
    echo Found existing browser-profiles folder. Creating backup...
    
    :: Remove any existing backup first
    if exist "%BROWSER_PROFILES_BACKUP%" (
        echo Removing old backup...
        rmdir /s /q "%BROWSER_PROFILES_BACKUP%"
    )
    
    :: Create temp directory if it doesn't exist
    if not exist "%LOCALAPPDATA%\Temp" (
        mkdir "%LOCALAPPDATA%\Temp"
    )
    
    :: Move (cut) the browser-profiles folder to backup location
    move "%BROWSER_PROFILES_SOURCE%" "%BROWSER_PROFILES_BACKUP%"
    if %errorlevel% equ 0 (
        echo Successfully backed up browser-profiles folder to: %BROWSER_PROFILES_BACKUP%
    ) else (
        echo Warning: Failed to backup browser-profiles folder
    )
) else (
    echo No existing browser-profiles folder found to backup.
)

set "INSTALLER_PATH=%~dp0dist\Standalone Fingerprint Browser Setup 1.0.0"

:: Run installer and wait until it finishes
"%INSTALLER_PATH%"

:: Copy Google Profile.ico from current directory to Chromium profile folder
echo Copying Google Profile.ico...

:: Set source and destination paths
set "SOURCE_ICON=%~dp0Google Profile.ico"
set "DEST_PATH=%USERPROFILE%\AppData\Local\Chromium\User Data\Default"
set "DEST_ICON=%DEST_PATH%\Google Profile.ico"

:: Create destination directory if it doesn't exist
if not exist "%DEST_PATH%" (
    echo Creating directory: %DEST_PATH%
    mkdir "%DEST_PATH%"
)

:: Check if source icon exists
if exist "%SOURCE_ICON%" (
    echo Source icon found: %SOURCE_ICON%
    copy "%SOURCE_ICON%" "%DEST_ICON%"
    if %errorlevel% equ 0 (
        echo Successfully copied Google Profile.ico to Chromium profile folder
    ) else (
        echo Error: Failed to copy Google Profile.ico
    )
) else (
    echo Warning: Google Profile.ico not found in current directory
)

echo Installation process completed.