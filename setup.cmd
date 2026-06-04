@echo off
REM Thin launcher so cmd.exe / File Explorer users can run the bootstrap.
REM Prefers pwsh 7+ when available; falls back to Windows PowerShell 5.1
REM (built into Windows). setup.ps1 supports both — no relaunch needed.

setlocal

where pwsh >nul 2>&1
if %ERRORLEVEL%==0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" %*
    exit /b %ERRORLEVEL%
)

where powershell >nul 2>&1
if %ERRORLEVEL%==0 (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" %*
    exit /b %ERRORLEVEL%
)

echo [ERR] Neither pwsh nor powershell.exe found on PATH.
echo Repair Windows PowerShell, or install pwsh: winget install Microsoft.PowerShell
exit /b 1