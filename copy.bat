
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

