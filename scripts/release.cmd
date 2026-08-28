@echo off
setlocal
if "%~1"=="" goto usage
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0release.ps1" -Version "%~1"
exit /b %ERRORLEVEL%

:usage
echo Usage: release.cmd 0.1.2
exit /b 1
