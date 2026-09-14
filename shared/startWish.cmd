@ECHO OFF
ECHO LAUNCH WISH.PS1
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass"
CD .\src\
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\wish.ps1"
