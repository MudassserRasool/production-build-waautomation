function Run-WithTimeout($file, $timeout) {
    $process = Start-Process cmd.exe -ArgumentList "/c `"$file`"" -PassThru
    if (-not $process.WaitForExit($timeout * 1000)) {
        # Didn't finish in time, kill it
        Write-Host "$file exceeded $timeout seconds. Killing process..."
        try { $process.Kill() } catch {}
    } else {
        Write-Host "$file finished successfully."
    }
}

# Step 1: Run config.bat
Run-WithTimeout "config.bat" 10

# Step 2: Run app.bat (only after config is done)
Run-WithTimeout "app.bat" 10

# Step 3: Run copy.bat (only after app is done)
Run-WithTimeout "copy.bat" 30
