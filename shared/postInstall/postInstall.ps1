# C:\Windows\Setup\Scripts\postInstall.ps1
# Start me: C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\startPostInstall.cmd
Write-Host "# POST INSTALL SCRIPT" -ForegroundColor Cyan

Set-executionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force
Get-ExecutionPolicy

$taskList = Get-Content ./taskList.json | ConvertFrom-Json
$numberOfTasks = ($taskList.tasks).Length
$taskCounter = 1

Write-Host "## TASKS TO RUN" -ForegroundColor Cyan
$taskList.tasks | ForEach-Object {
    Write-Host "Task $taskCounter/$numberOfTasks : $($_.taskName)"
    $postInstallRoot = (Get-Location).Path
    Set-Location $_.taskDirectory
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $_.taskWorker" -Wait
    Set-Location $postInstallRoot
}

<# TODO
    - Install OEM Keys
    - Start unknownDeviceHandler
    - Verify transactions
#>

Write-Host "# Please Check: [C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\startPostInstall.cmd]" -ForegroundColor Yellow
PAUSE

Write-Host "End of script postInstall.ps1" -ForegroundColor Cyan
Write-Host "startPostInstall.cmd will be removed after first run?" -ForegroundColor Cyan