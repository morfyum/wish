# C:\Windows\Setup\Scripts\postInstall.ps1
# Start me: C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\startPostInstall.cmd
Write-Host "# POST INSTALL SCRIPT" -ForegroundColor Cyan
Set-Location -Path "C:\wish"
Set-executionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force
$policy = Get-ExecutionPolicy
$postInstallRoot = (Get-Location).Path
Write-Host "- POLICY  : $policy"
Write-Host "- LOCATION: $postInstallRoot"
$taskList = Get-Content ./taskList.json | ConvertFrom-Json
$numberOfTasks = ($taskList.tasks).Length
$taskCounter = 0

Write-Host "## TASKS TO RUN" -ForegroundColor Cyan
$taskList.tasks | ForEach-Object {

    $taskCounter++
    $fullPathworkingDir = Join-Path $postInstallRoot $($_.taskDirectory)

    Write-Host "Task $taskCounter/$numberOfTasks : $($_.taskName)"
    Write-Host "- Script path : $postInstallRoot"
    Write-Host "- Working dir : $($_.taskWorker)"
    Write-Host "- Full Path working dir : $fullPathworkingDir"
    Write-Host "- Installation in progress..."
    Pause

    $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $($_.taskWorker)" -WorkingDirectory $fullPathworkingDir -Wait -PassThru

    if ($process.ExitCode -eq 0) {
        Write-Host "[ OK ] Task completed: $($_.taskName)" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Task failed (ExitCode: $($process.ExitCode)): $($_.taskName)" -ForegroundColor Red
    }
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