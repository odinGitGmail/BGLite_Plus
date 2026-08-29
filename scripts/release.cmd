@echo off
setlocal
REM 无参数：toc 最小版本段 +1；有参数：使用指定版本
if "%~1"=="" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0release.ps1"
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0release.ps1" -Version "%~1"
)
exit /b %ERRORLEVEL%
