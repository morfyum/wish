# WISH.PS1 : WINDOWS IMAGING SHELL BY MORFYUM
# REQUIREMENTS
. ./utils.ps1
. ./logging/logging.ps1

# HARDCODE
$configFile = "Config.json"
$sourcePanther = "C:/Windows/Panther"
$postInstallDestination = "C:/wish"
$wishLogs = "../logs/wish.log"
$unitLogs = "../logs/units"
$unitlogFile = "unit.log"
$extensions = "../extensions"
$targetDrive = "C:\"

Logging -LogLevel "INFO" -LogMessage "# WELCOME IN WINDOWS IMAGING SHELL!" -LogDestination $wishLogs -ShowColors -Less


Logging -LogLevel "INFO" -LogMessage "- Create [$unitLogs] directory tree if it doesnt exist" -LogDestination $wishLogs -ShowColors -Less
New-Item -ItemType Directory -Path $unitLogs -ErrorAction SilentlyContinue | Out-Null


#Write-Host "# TASK 1 : GATHERING FACTS" -ForegroundColor Cyan
#Write-Host "- Read hardware data..."
Logging -LogLevel "INFO" -LogMessage "# TASK 1 : GATHERING FACTS" -LogDestination $wishLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Read hardware data..." -LogDestination $wishLogs -ShowColors -Less
$serialNumber = getSerialNumber
$model = getModel
$manufacturer = getManufacturer
$architecture = getArchitecture
$BIOSVersion = getSMBIOSBIOSVersion
$baseBoardProduct = getBaseBoardProduct
$keyboardType = getKeyboardType
$OEMKey = getAcpiOemType

if ($serialNumber -eq $null) {
    #Write-Host "WARNING: Serial number is null" -ForegroundColor Red
    Logging -LogLevel "WARNING" -LogMessage "WARNING: Serial number is null" -LogDestination $wishLogs -ShowColors -Less
    $serialNumber = Read-Host "Please enter serial number manually"
}
if ($model -eq $null) {
    #Write-Host "WARNING: Model is null" -ForegroundColor Red
    Logging -LogLevel "WARNING" -LogMessage "WARNING: Model is null" -LogDestination $wishLogs -ShowColors -Less
    $model = Read-Host "Please enter model manually"
}
if ($manufacturer -eq $null) {
    #Write-Host "WARNING: Manufacturer is null" -ForegroundColor Red
    Logging -LogLevel "WARNING" -LogMessage "WARNING: Manufacturer is null" -LogDestination $wishLogs -ShowColors -Less
    $manufacturer = Read-Host "Please enter manufacturer manually"
}


$unitLogDir = "$unitLogs/$serialNumber"
Logging -LogLevel "INFO" -LogMessage "- Create [$unitLogDir] directory if it doesnt exist" -LogDestination $wishLogs -ShowColors -Less
New-item -ItemType Directory -Path $unitLogDir -ErrorAction SilentlyContinue | Out-Null
if (-not (Test-Path $unitLogDir)) {
    Logging -LogLevel "ERROR" -LogMessage "- Cannot create directory [$unitLogDir] fall back to [$wishLogs]" -LogDestination $wishLogs -ShowColors -Less
    exit 1
} else {
    Logging -LogLevel "INFO" -LogMessage "- OK [$unitLogDir]" -LogDestination $wishLogs -ShowColors -Less
    $fullPathUnitLogs = "$unitLogs/$serialNumber/$unitlogFile"
    Logging -LogLevel "INFO" -LogMessage "- Start logging into [$fullPathUnitLogs]" -LogDestination $wishLogs -ShowColors -Less
}




Logging -LogLevel "INFO" -LogMessage "- Serial Number  : $serialNumber" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Model          : $model" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Manufacturer   : $manufacturer" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Architecture   : $architecture" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- BIOS version   : $BIOSVersion" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Baseboard code : $baseBoardProduct" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Keyboard Type  : $keyboardType" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- OEM Key        : $OEMKey" -LogDestination $fullPathUnitLogs -ShowColors -Less

#Write-Host "- Serial Number  : $serialNumber"
#Write-Host "- Model          : $model"
#Write-Host "- Manufacturer   : $manufacturer"
#Write-Host "- Architecture   : $architecture"
#Write-Host "- BIOS version   : $BIOSVersion"
#Write-Host "- Baseboard code : $baseBoardProduct"
#Write-Host "- Keyboard Type  : $keyboardType"
#Write-Host "- OEM Key        : $OEMKey"


Logging -LogLevel "INFO" -LogMessage "- Read config..." -LogDestination $fullPathUnitLogs -ShowColors -Less
#Write-Host "# WELCOME IN WINDOWS IMAGING SHELL!" -ForegroundColor Cyan
#Write-Host "- Read config..."
$config = Get-Content -Path $configFile | ConvertFrom-Json

if ($config -eq $null) {
    #Write-Host "- CRITICAL: Config file is null" -ForegroundColor Red
    Logging -LogLevel "CRITICAL" -LogMessage "- CRITICAL: [$configFile] is null => EXIT" -LogDestination $wishLogs -ShowColors -Less
    Pause
    exit 1
}

Logging -LogLevel "INFO" -LogMessage "- Mount point               : $($config.mountPoint)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- ISO path                  : $($config.ISOPath)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- LOG path                  : $($config.LOGPath)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Unit log path             : $($config.unitLogPath)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Driver path               : $($config.driverPath)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Default language          : $($config.defaultLanguage)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Default system            : $($config.defaultSystem)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Default Windows edition   : $($config.defaultWindowsEdition)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- OEM key priority          : $($config.OEMKeyPriority)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Update BIOS               : $($config.updateBIOS)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- file / diskpart.txt       : $($config.fileDiskpartTXT)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- file / unattend.xml       : $($config.fileUnattendedXML)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- file/postInstall Launcher : $($config.filePostInstallLauncher)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- file / postInstall Script : $($config.filePostInstallScript)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- dir / postInstall         : $($config.dirPostInstall)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- dir / Win11 HU source     : $($config.dirWin11Hun)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- dir / Win11 EN source     : $($config.dirWin11Eng)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Reboot after OSinstall    : $($config.rebootAfterOSInstalled)" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Pause before end          : $($config.pauseBeforeEnd)" -LogDestination $fullPathUnitLogs -ShowColors -Less

#Write-Host "- Mount point               : $($config.mountPoint)" 
#Write-Host "- ISO path                  : $($config.ISOPath)"
#Write-Host "- LOG path                  : $($config.LOGPath)"
#Write-Host "- Unit log path             : $($config.unitLogPath)"
#Write-Host "- Driver path               : $($config.driverPath)"
#Write-Host "- wish log file             : $($config.fileSysLog)"
#Write-Host "- Default language          : $($config.defaultLanguage)"
#Write-Host "- Default system            : $($config.defaultSystem)"
#Write-Host "- Default Windows edition   : $($config.defaultWindowsEdition)"
#Write-Host "- OEM key priority          : $($config.OEMKeyPriority)"
#Write-Host "- Update BIOS               : $($config.updateBIOS)"
#Write-Host "- file / diskpart.txt       : $($config.fileDiskpartTXT)"
#Write-Host "- file / unattend.xml       : $($config.fileUnattendedXML)"
#Write-Host "- file / postInstall.cmd    : $($config.filePostInstall)"
#Write-Host "- dir / Win11 HU source     : $($config.dirWin11Hun)"
#Write-Host "- dir / Win11 EN source     : $($config.dirWin11Eng)"
#Write-Host "- Reboot after OSinstall    : $($config.rebootAfterOSInstalled)"

# TODO Overwrite default if needed
$selectedWindowsEdition = getIndexFromDictionary -WinEdition $($config.defaultWindowsEdition)

if ($selectedWindowsEdition -eq $null) {
    Logging -LogLevel "CRITICAL" -LogMessage "- $($serialNumber) Selected Windows Edition is null => EXIT" -LogDestination $wishLogs -ShowColors -Less
    Logging -LogLevel "CRITICAL" -LogMessage "- Selected Windows Edition is null => EXIT" -LogDestination $fullPathUnitLogs -ShowColors -Less
    Pause
    exit 1
}
Logging -LogLevel "INFO" -LogMessage "- Selected Windows edition  : $selectedWindowsEdition" -LogDestination $fullPathUnitLogs -ShowColors -Less


Logging -LogLevel "WARNING" -LogMessage "- TODO Verify info..." -LogDestination $fullPathUnitLogs -ShowColors -Less
#Write-Host "- Verify info..."



# TODO selectSystemByOEMKey
if ($($config.OEMKeyPriority) -eq $true) {
    #Write-Host "- TODO: select system by OEM key"
    Logging -LogLevel "WARNING" -LogMessage "- TODO: select system by OEM key" -LogDestination $wishLogs -ShowColors -Less
} else {
    #Write-Host "- TODO: select system by default system in config"
    Logging -LogLevel "WARNING" -LogMessage "- TODO: select system by config" -LogDestination $wishLogs -ShowColors -Less
}


#Write-Host "- Build paths..."
Logging -LogLevel "WARNING" -LogMessage "- Build paths..." -LogDestination $fullPathUnitLogs -ShowColors -Less
$fullPathWin11HunSrc = "$($config.mountPoint)\$($config.ISOPath)\$($config.dirWin11Hun)\sources\install.wim"
$fullPathWin11EngSrc = "$($config.mountPoint)\$($config.ISOPath)\$($config.dirWin11Eng)\sources\install.wim"
$fullPathDrivers = "$($config.mountPoint)\$($config.driverPath)\$manufacturer/$model"
$fullPathUnattendXMLDestination = "$sourcePanther/$($config.fileUnattendedXML)"
$fullPathPostInstallLauncher = "$($config.mountPoint)/$($config.dirPostInstall)/$($config.filePostInstallLauncher)"
$fullPathPostInstallScriptSource   = "$($config.mountPoint)/$($config.dirPostInstall)/$($config.filePostInstallScript)"
$fullPathUnitLog = "$unitLogs\$serialNumber.log"
$fullPathPostInstallLauncherDestination = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\$($config.filePostInstallLauncher)"
$fullPathPostInstallScriptDestination = "$postInstallDestination/$($config.filePostInstallScript)"


$fullPathManufacturer = "$($config.mountPoint)/$($config.driverPath)/$manufacturer"
Logging -LogLevel "INFO" -LogMessage "- Create $fullPathManufacturer directory if it doesnt exist" -LogDestination $wishLogs -ShowColors -Less
New-item -ItemType Directory -Path $fullPathManufacturer -ErrorAction SilentlyContinue | Out-Null

# TODO SELECTED SYSTEM
Logging -LogLevel "WARNING" -LogMessage "- TODO Select system by OEM key logic" -LogDestination $wishLogs -ShowColors -Less
# Select System Language
# Selet system language


#$selectedSystem = $fullPathWin11HunSrc
$selectedSystem = $null
if ($($config.defaultLanguage).ToUpper() -eq "ENGB") {
    $selectedSystem = $fullPathWin11EngSrc
    Logging -LogLevel "INFO" -LogMessage "- Selected installation pathy by Config : [$($config.defaultLanguage)] " -LogDestination $fullPathUnitLogs -ShowColors -Less
} elseif ($($config.defaultLanguage).ToUpper() -eq "HU") {
    $selectedSystem = $fullPathWin11HunSrc
    Logging -LogLevel "INFO" -LogMessage "- Selected installation pathy by Config : [$($config.defaultLanguage)] " -LogDestination $fullPathUnitLogs -ShowColors -Less
} else {
    Logging -LogLevel "CRITICAL" -LogMessage "- CRITICAL: Selected installation path is null => EXIT" -LogDestination $wishLogs -ShowColors -Less
    Logging -LogLevel "CRITICAL" -LogMessage "- CRITICAL: Selected installation path is null => EXIT" -LogDestination $fullPathUnitLogs -ShowColors -Less
    Pause
    exit 1
}
Logging -LogLevel "INFO" -LogMessage "- INSTALL: [$selectedSystem]" -LogDestination $fullPathUnitLogs -ShowColors -Less



Logging -LogLevel "INFO" -LogMessage "- Full path Win11 HU source : $fullPathWin11HunSrc" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Full path Win11 EN source : $fullPathWin11EngSrc" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Full path drivers         : $fullPathDrivers" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Full path unattend.xml    : $fullPathUnattendXMLDestination" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Full path logging         : $wishLogs" -LogDestination $fullPathUnitLogs -ShowColors -Less
#Write-Host "- Full path Win11 HU source : $fullPathWin11HunSrc"
#Write-Host "- Full path Win11 EN source : $fullPathWin11EngSrc"
#Write-Host "- Full path drivers         : $fullPathDrivers"
#Write-Host "- Full path unattend.xml    : $fullPathUnattendXMLDestination"
#Write-Host "- Full path logging         : $wishLogs


#Write-Host "# TASK 2 : FORMAT DISK 0" -ForegroundColor Cyan
Logging -LogLevel "INFO" -LogMessage "# TASK 2 : FORMAT DISK 0" -LogDestination $fullPathUnitLogs -ShowColors -Less
exitOnMissingFile -Path $($config.fileDiskpartTXT)
Logging -LogLevel "INFO" -LogMessage "- Format disk..." -LogDestination $fullPathUnitLogs -ShowColors -Less
#diskpart.exe /s $($config.fileDiskpartTXT)
measureTask -TaskName "Disk Partitioning" -ScriptBlock {
    formatTargetDrive -DiskpartTXT $($config.fileDiskpartTXT)
}
checkLastCommand -ContextMessage "Format drive C:"
Start-Sleep -Seconds 3


#Write-Host "# TASK 3 : APPLYING IMAGE" -ForegroundColor Cyan
#Write-Host "- Hardcoded Win11HUN src in progress"
Logging -LogLevel "INFO" -LogMessage "# TASK 3 : APPLYING IMAGE" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Image $selectedSystem" -LogDestination $fullPathUnitLogs -ShowColors -Less
exitOnMissingFile -Path $selectedSystem
Logging -LogLevel "INFO" -LogMessage "- Applying image..." -LogDestination $fullPathUnitLogs -ShowColors -Less
#Dism /Apply-Image /ImageFile:$selectedSystem /Index:$selectedWindowsEdition /ApplyDir:$targetDrive
measureTask -TaskName "Apply Windows Image" -ScriptBlock {
    applyWindowsImage -WimPath $selectedSystem -Index $selectedWindowsEdition -TargetDrive $targetDrive
}
checkLastCommand -ContextMessage "Apply Windows Image"

Logging -LogLevel "INFO" -LogMessage "# TASK 4 : INJECT DRIVERS" -LogDestination $fullPathUnitLogs -ShowColors -Less
#Write-Host "# TASK 4 : INJECT DRIVERS" -ForegroundColor Cyan
returnFalseOnMissingFile -Path $fullPathDrivers
#Dism /Image:$targetDrive /Add-Driver /Driver:$fullPathDrivers /Recurse /ForceUnsigned
measureTask -TaskName "Inject Drivers" -ScriptBlock {
    injectDrivers -TargetDrive $targetDrive -DriverPath $fullPathDrivers
}
checkLastCommand -ContextMessage "Inject Drivers"

Logging -LogLevel "INFO" -LogMessage "# TASK 5 : CONFIGURE BOOT DEVICE" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- bcdboot.exe C:\Windows /s S: /f UEFI" -LogDestination $fullPathUnitLogs -ShowColors -Less
#Write-Host "# TASK 5 : CONFIGURE BOOT DEVICE" -ForegroundColor Cyan
#Write-Host "- bcdboot.exe C:\Windows /s S: /f UEFI"
bcdboot.exe C:\Windows /s S: /f UEFI
checkLastCommand -ContextMessage "Configure Boot Device"

Logging -LogLevel "INFO" -LogMessage "# TASK 6 : INJECT UNATTEND.XML" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Create Panther directory" -LogDestination $fullPathUnitLogs -ShowColors -Less
#Write-Host "# TASK 6 : INJECT UNATTEND.XML" -ForegroundColor Cyan
#Write-Host "- Create Panther directory"
New-Item -ItemType Directory -Path C:\Windows\Panther -ErrorAction SilentlyContinue
checkLastCommand -ContextMessage "Create Panther directory"

Logging -LogLevel "INFO" -LogMessage "- Copy unattend file [$($config.fileUnattendedXML)] to [$fullPathUnattendXMLDestination]" -LogDestination $fullPathUnitLogs -ShowColors -Less
#Write-Host "- Copy $($config.fileUnattendedXML)"
returnFalseOnMissingFile -Path $($config.fileUnattendedXML)
Copy-Item $($config.fileUnattendedXML) -Destination $fullPathUnattendXMLDestination
checkLastCommand -ContextMessage "Copy unattend.xml"

Logging -LogLevel "INFO" -LogMessage "- Applying unattend file: [$($config.fileUnattendedXML)]" -LogDestination $fullPathUnitLogs -ShowColors -Less
#Write-Host "- Applying unattend.xml"
#Dism /Image:C:\ /Apply-Unattend:$fullPathUnattendXMLDestination
measureTask -TaskName "Inject Drivers" -ScriptBlock {
    applyUnattendXML -TargetDrive $targetDrive -UnattendXMLPath $fullPathUnattendXMLDestination
}
checkLastCommand -ContextMessage "Apply Unattend.xml"


#Write-Host "# TASK 7 ADD POST-INSTALL SCRIPTS:" -ForegroundColor Cyan
#Write-Host "- Install postInstall launcher script as C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\startPostInstall.cmd"
Logging -LogLevel "INFO" -LogMessage "# TASK 7 ADD POST-INSTALL SCRIPTS:" -LogDestination $fullPathUnitLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "- Check postInstall Launcher [$fullPathPostInstallLauncher]" -LogDestination $fullPathUnitLogs -ShowColors -Less
returnFalseOnMissingFile -Path $fullPathPostInstallLauncher
Logging -LogLevel "INFO" -LogMessage "- Check postInstall Script [$fullPathPostInstallScriptSource]" -LogDestination $fullPathUnitLogs -ShowColors -Less
returnFalseOnMissingFile -Path $fullPathPostInstallScriptSource


Logging -LogLevel "INFO" -LogMessage "- Copy postInstall launcher as [$fullPathPostInstallLauncherDestination]" -LogDestination $fullPathUnitLogs -ShowColors -Less
Copy-Item -Path $fullPathPostInstallLauncher -Destination $fullPathPostInstallLauncherDestination -Force
checkLastCommand
Logging -LogLevel "INFO" -LogMessage "- Create [$postInstallDestination] on new system C:\" -LogDestination $fullPathUnitLogs -ShowColors -Less
New-item -ItemType Directory -Path $postInstallDestination -ErrorAction SilentlyContinue | Out-Null
checkLastCommand
Logging -LogLevel "INFO" -LogMessage "- Copy postInstall Script [$fullPathPostInstallScriptSource] to [$fullPathPostInstallScriptDestination]" -LogDestination $fullPathUnitLogs -ShowColors -Less
Copy-Item -Path $fullPathPostInstallScriptSource -Destination $fullPathPostInstallScriptDestination -Force
Logging -LogLevel "INFO" -LogMessage "- Verify transaction" -LogDestination $fullPathUnitLogs -ShowColors -Less
returnFalseOnMissingFile -Path $fullPathPostInstallLauncherDestination
returnFalseOnMissingFile -Path $fullPathPostInstallScriptDestination


#Write-Host "# TASK 8 : FINAL STATE" -ForegroundColor Cyan
Logging -LogLevel "INFO" -LogMessage "# TASK 8 : FINAL STATE" -LogDestination $fullPathUnitLogs -ShowColors -Less

Logging -LogLevel "WARNING" -LogMessage "- TODO SUMMARY" -LogDestination $wishLogs -ShowColors -Less

Logging -LogLevel "INFO" -LogMessage "# WINDOWS IMAGING SHELL FINISHED ON [$($serialNumber)]. GOODBYE!" -LogDestination $wishLogs -ShowColors -Less
Logging -LogLevel "INFO" -LogMessage "# WINDOWS IMAGING SHELL FINISHED ON [$($serialNumber)]. GOODBYE!" -LogDestination $fullPathUnitLogs -ShowColors -Less


if ($($config.pauseBeforeEnd) -eq $true) {
    Logging -LogLevel "INFO" -LogMessage "- Pausing before end..." -LogDestination $fullPathUnitLogs -ShowColors -Less
    Pause
}

Logging -LogLevel "INFO" -LogMessage "- rebootAfterOSInstalled on $serialNumber is [$($config.rebootAfterOSInstalled)]" -LogDestination $fullPathUnitLogs -ShowColors -Less
if ($($config.rebootAfterOSInstalled) -eq $true) {
    Logging -LogLevel "INFO" -LogMessage "- Rebooting..." -LogDestination $fullPathUnitLogs -ShowColors -Less
    wpeutil reboot
}