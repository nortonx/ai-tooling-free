@echo off
setlocal
where pwsh >nul 2>&1 && (pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" %* & exit /b)
where powershell >nul 2>&1 && (powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" %* & exit /b)
echo [ERR] Neither pwsh nor powershell.exe found.
exit /b 1