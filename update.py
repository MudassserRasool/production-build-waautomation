#old

# # run_exe_blocking.py
# import sys
# import subprocess
# from pathlib import Path
# import os

# # sys.argv[0] is script name, so take from index 1
# # if len(sys.argv) < 2:
# #     print("Usage: python run_exe_blocking.py <exe_path> [args...]")
# #     sys.exit(1)



# path = "C:\\Users\\MudasserRasool\\AppData\\Local\\Programs\\desktop\\resources\\production-build\\update.exe"
# exe = Path(path)
# print("ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd")
# print(path)
# print("ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd")

# args = sys.argv[2:]  # the rest are arguments for the exe

# # Run exe + args
# result = os.system(str(exe))
# print("Return code:", result.returncode)
# print("Stdout:", result.stdout)
# print("Stderr:", result.stderr)

# print("Return code:", result.returncode)
# print("Stdout:", result.stdout)
# print("Stderr:", result.stderr)




#!/usr/bin/env python3
"""
Desktop Update Script - Python Version
Downloads and extracts update files from a remote URL
"""

import os
import sys
import requests
import zipfile
import shutil
from datetime import datetime
from pathlib import Path

def write_log(message, log_file=None):
    """Write message to log file and console"""
    if not message:
        message = "Empty message"
    
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_message = f"{timestamp} - {message}"
    
    try:
        if log_file and log_file != "":
            with open(log_file, 'a', encoding='utf-8') as f:
                f.write(log_message + '\n')
    except Exception as e:
        print(f"Warning: Could not write to log file: {e}")
    
    print(message)

def main():
    try:
        print("Starting desktop update process...")
        
        # Determine script directory - works for both .py and compiled .exe
        if getattr(sys, 'frozen', False):
            # Running as compiled executable
            script_dir = os.path.dirname(sys.executable)
        else:
            # Running as Python script
            script_dir = os.path.dirname(os.path.abspath(__file__))
        
        # Ensure script_dir is valid
        if not script_dir:
            script_dir = os.getcwd()
        
        # Change working directory to script location
        try:
            os.chdir(script_dir)
            print(f"Changed working directory to: {script_dir}")
        except Exception as e:
            print(f"Warning: Could not change to script directory: {e}")
        
        # Set up paths
        app_dir = os.path.join(os.path.expanduser("~"), ".local", "share", "desktop")
        if os.name == 'nt':  # Windows
            app_dir = os.path.join(os.environ.get('LOCALAPPDATA', ''), "Programs", "desktop")
        
        resources_dir = os.path.join(app_dir, "resources")
        update_url = "https://backend.aisales.vip/dist.zip"
        dist_zip = os.path.join(script_dir, "dist.zip")
        extract_dir = os.path.join(script_dir, "dist")
        log_file = os.path.join(script_dir, "desktop-update.log")
        
        print(f"Script directory: {script_dir}")
        print(f"Log file: {log_file}")
        
        write_log("Starting desktop update process...", log_file)
        write_log(f"Working directory: {script_dir}", log_file)
        
        # Validate paths
        if not dist_zip:
            raise ValueError("dist_zip path is null or empty")
        if not extract_dir:
            raise ValueError("extract_dir path is null or empty")
        
        # Download update
        write_log(f"Downloading update from: {update_url}", log_file)
        write_log(f"Download destination: {dist_zip}", log_file)
        
        try:
            response = requests.get(update_url, stream=True, timeout=30)
            response.raise_for_status()
            
            with open(dist_zip, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)
            
            write_log("Download completed successfully", log_file)
        except requests.exceptions.RequestException as e:
            write_log(f"Download failed: {e}", log_file)
            raise Exception("Download failed")
        except Exception as e:
            write_log(f"Download failed: {e}", log_file)
            raise Exception("Download failed")
        
        # Check if file was downloaded
        if not os.path.exists(dist_zip):
            raise FileNotFoundError(f"Downloaded file not found at {dist_zip}")
        
        file_size = os.path.getsize(dist_zip)
        write_log(f"Downloaded file size: {file_size} bytes", log_file)
        
        # Extract update
        write_log(f"Extracting update to: {extract_dir}", log_file)
        try:
            # Create extraction directory if it doesn't exist
            if not os.path.exists(extract_dir):
                os.makedirs(extract_dir, exist_ok=True)
                write_log("Created extraction directory", log_file)
            
            with zipfile.ZipFile(dist_zip, 'r') as zip_ref:
                zip_ref.extractall(extract_dir)
            
            write_log("Extraction completed successfully", log_file)
        except zipfile.BadZipFile as e:
            write_log(f"Extraction failed - Bad zip file: {e}", log_file)
            raise Exception("Extraction failed - Bad zip file")
        except Exception as e:
            write_log(f"Extraction failed: {e}", log_file)
            raise Exception("Extraction failed")
        
        # Clean up downloaded zip file
        try:
            os.remove(dist_zip)
            write_log("Cleaned up temporary zip file", log_file)
        except Exception as e:
            write_log(f"Warning: Could not remove temporary file: {e}", log_file)
        
        write_log("Desktop update process completed successfully", log_file)
        print("\n=== UPDATE COMPLETED SUCCESSFULLY ===")
        print(f"Extracted files are in: {extract_dir}")
        
    except Exception as e:
        print("\n=== ERROR OCCURRED ===")
        print(f"Error: {e}")
        # delete dist.zip file
        os.remove("dist.zip")
        if 'log_file' in locals() and os.path.exists(log_file):
            print(f"Check the log file for more details: {log_file}")
    
    finally:
        print("\nPress Enter to continue...")
        try:
            input()
        except (KeyboardInterrupt, EOFError):
            pass

if __name__ == "__main__":
    main()