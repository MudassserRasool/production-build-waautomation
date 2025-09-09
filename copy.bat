
echo [7/6] Copying application resources...

rem Set dynamic target directory using current user
set "TARGET_DIR=%LOCALAPPDATA%\Programs\desktop\resources"
set "SOURCE_DIR=%~dp0data"

rem Debug: Show paths
echo Source directory: "%SOURCE_DIR%"
echo Target directory: "%TARGET_DIR%"

rem Check if source directory exists
if not exist "%SOURCE_DIR%" (
    echo ERROR: Source directory "%SOURCE_DIR%" does not exist!
    echo Please make sure the 'data' folder is in the same directory as this installer.
    pause
    exit /b 1
)

rem Create target directory if it doesn't exist
if not exist "%TARGET_DIR%" (
    echo Creating target directory: "%TARGET_DIR%"
    mkdir "%TARGET_DIR%" 2>nul
    if errorlevel 1 (
        echo ERROR: Failed to create target directory!
        pause
        exit /b 1
    )
)

rem Copy all contents from source to target, excluding browser-profiles folder
echo Copying contents from "%SOURCE_DIR%" to "%TARGET_DIR%" (excluding browser-profiles)...

rem First copy all files in the root of source directory
echo Copying files...
for %%f in ("%SOURCE_DIR%\*.*") do (
    copy "%%f" "%TARGET_DIR%\" >nul 2>&1
)

rem Then copy all directories except browser-profiles
echo Copying directories...
for /d %%d in ("%SOURCE_DIR%\*") do (
    if /i not "%%~nxd"=="browser-profiles" (
        echo Copying directory: %%~nxd
        xcopy "%%d" "%TARGET_DIR%\%%~nxd\" /E /H /C /I /Y
    ) else (
        echo Skipping directory: %%~nxd
    )
)

set "COPY_ERROR=0"

rem Check if the copy operation was successful
if %COPY_ERROR% neq 0 (
    echo [!] ERROR: Copy failed
    exit /b 1
)
echo [*] Resources copied successfully

rem Restore browser-profiles folder if backup exists
set "BROWSER_PROFILES_BACKUP=%LOCALAPPDATA%\Temp\browser-profiles-backup"
set "BROWSER_PROFILES_DESTINATION=%TARGET_DIR%\browser-profiles"

echo Checking for browser-profiles backup...
if exist "%BROWSER_PROFILES_BACKUP%" (
    echo Found browser-profiles backup. Restoring...
    
    :: Remove any existing browser-profiles folder in destination first
    if exist "%BROWSER_PROFILES_DESTINATION%" (
        echo Removing existing browser-profiles folder...
        rmdir /s /q "%BROWSER_PROFILES_DESTINATION%"
    )
    
    :: Move (cut) the backup folder back to destination
    move "%BROWSER_PROFILES_BACKUP%" "%BROWSER_PROFILES_DESTINATION%"
    if %errorlevel% equ 0 (
        echo [*] Successfully restored browser-profiles folder
    ) else (
        echo [!] Warning: Failed to restore browser-profiles folder
    )
) else (
    echo No browser-profiles backup found to restore.
)

