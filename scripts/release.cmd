@echo off
setlocal
REM Prefer Python to avoid Windows PowerShell encoding/parser issues.
where python >nul 2>&1
if %ERRORLEVEL%==0 (
  python "%~dp0release.py" %*
  exit /b %ERRORLEVEL%
)

REM Fallback: PowerShell script
if "%~1"=="" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0release.ps1"
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0release.ps1" -Version "%~1"
)
exit /b %ERRORLEVEL%
