@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0upload-curseforge.ps1" %*
