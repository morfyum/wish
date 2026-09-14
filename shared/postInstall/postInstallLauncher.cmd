@ECHO OFF
::C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\runPostInstall.cmd
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\wish\postInstall.ps1"
:: Self-delete this wrapper script from the Startup folder
DEL "%~f0"