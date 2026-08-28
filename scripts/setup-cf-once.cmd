@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-cf-once.ps1" %*
