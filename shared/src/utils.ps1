# utils.ps1
#. ./logging/logging.ps1
#$wishLogs = "..\logs\wish.log"

$Log = {
    param([string]$Level, [string]$Message)
    if ($Logger) {
        & $Logger -LogLevel $Level -LogMessage $Message
    } else {
        switch ($Level) {
            "CRITICAL" { Write-Host "[$Level] $Message" -ForegroundColor Magenta}  # or Write-Error $Message
            "ERROR"    { Write-Host "[$Level]    $Message" -ForegroundColor Red }  # or Write-Error $Message
            "WARNING"  { Write-Host "[$Level]  $Message" -ForegroundColor Yellow}  # or Write-Warning $Message}
            "INFO"     { Write-Host "[$Level]     $Message"}  # or Write-Information $Message
            default    { Write-Host "[$Level]     $Message" }
        }
    }
}


function waitForMissingFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string] $FilePath,

        [Parameter(Mandatory = $False)]
        [int] $TimeoutSeconds = 30,

        [parameter(Mandatory = $false)]
        [scriptblock]$Logger
    )

    & $Log "INFO" "waitForMissingFile: $FilePath"
    while (-not (Test-Path $FilePath)) {
        & $Log "ERROR" "[$FilePath] missing. Retry after [$TimeoutSeconds] seconds."
        Start-Sleep -Seconds $TimeoutSeconds
    }
    & $Log "INFO" "OK - [$FilePath] is present."
}


function waitNetworkCheckPoint {
    <#  waitNetworkCheckPoint is handle network issues,
        use this function if you have instable internet connection between actions
    #>
    # TODO
}


function InvokeNativeExe {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$FilePath,

        [Parameter(Mandatory = $false, Position = 1)]
        [string[]]$ArgumentList,

        [parameter(Mandatory = $false)]
        [scriptblock]$Logger
    )
    # Execute command and capture both standard output and error streams
    $output = & $FilePath $ArgumentList 2>&1

    if ($LASTEXITCODE -eq 0) {
        #Write-Host "- OK : $FilePath executed successfully." -ForegroundColor Green
        & $Log "INFO" "[$FilePath] executed successfully."
        #Logging -LogLevel "INFO" -LogMessage "- OK : [$FilePath] executed successfully." -LogDestination $fullPathUnitLogs -ShowColors -Less
        return $true
    } else {
        #Write-Host "- ERROR: $FilePath failed with exit code $LASTEXITCODE" -ForegroundColor Red
        & $Log "INFO" "[$FilePath] failed with exit code $LASTEXITCODE"
        #Logging -LogLevel "ERROR" -LogMessage "- ERROR: [$FilePath] failed with exit code $LASTEXITCODE" -LogDestination $wishLogs -ShowColors -Less
        if ($output) {
            #Write-Host "Output:" -ForegroundColor Yellow
            & $Log "INFO" "Output:"
            #Logging -LogLevel "INFO" -LogMessage "Output:" -LogDestination $fullPathUnitLogs -ShowColors -Less
            #$output | ForEach-Object { Write-Host "  $_" }
            #$output | ForEach-Object { Logging -LogLevel "INFO" -LogMessage "[$_]" -LogDestination $fullPathUnitLogs -ShowColors -Less }
            $output | ForEach-Object { & $Log "INFO" "[$_]" }
        }
        return $false
    }
}

<#TODO Mandatory SerialNumber #>
function checkLastCommand {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $false)]
        [string]$ContextMessage = "", # Optional Comment

        [parameter(Mandatory = $false)]
        [string]$SerialNumber = "Unknown", # Optional Serial Number for logging

        [parameter(Mandatory = $false)]
        [scriptblock]$Logger
    )

    # Get data from Call Stack
    $caller         = (Get-PSCallStack)[1]
    $callerFunction = if ($caller.Command) { $caller.Command } else { "MainScript" }
    $lineNumber     = $caller.ScriptLineNumber
    $lineText       = if ($caller.Position) { $caller.Position.Text.Trim() } else { "N/A" }

    & $Log "INFO" "checkLastCommand (Caller: $callerFunction)"
    #Logging -LogLevel "INFO" -LogMessage "## checkLastCommand (Caller: $callerFunction)" -LogDestination $fullPathUnitLogs -ShowColors -Less

    if ($LASTEXITCODE -eq 0) {
        & $Log "INFO" "[$callerFunction] executed successfully (Line $lineNumber)."
        #Logging -LogLevel "INFO" -LogMessage "- OK : [$callerFunction] executed successfully (Line $lineNumber)." -LogDestination $fullPathUnitLogs -ShowColors -Less
    } else {
        $errorMsg = "Failed in [$callerFunction] | Line $lineNumber | Command: '$lineText' | ExitCode: [$LASTEXITCODE]"
        
        if ($ContextMessage) {
            $errorMsg += " | Note: $ContextMessage"
        }
        & $Log "ERROR" "- $SerialNumber Serial Number : $errorMsg"
        #Logging -LogLevel "ERROR" -LogMessage "- $($serialNumber) : $errorMsg" -LogDestination $wishLogs -ShowColors -Less
        #Logging -LogLevel "ERROR" -LogMessage "- $errorMsg" -LogDestination $fullPathUnitLogs -ShowColors -Less
    }
}


function exitOnMissingFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string] $Path,

        [parameter(Mandatory = $false)]
        [string] $SerialNumber = "Unknown", # Optional Serial Number for logging

        [parameter(Mandatory = $false)]
        [scriptblock]$Logger
    )
    #Write-Host "## exitOnMissingFile: $Path"
    & $Log "INFO" "exitOnMissingFile"
    #Logging -LogLevel "INFO" -LogMessage "## exitOnMissingFile" -LogDestination $fullPathUnitLogs -ShowColors -Less
    if (-not (Test-Path $Path)) {
        #Write-Host "- CRITICAL: file is missing" -ForegroundColor Red
        & $Log "CRITICAL" "Missing file: [$Path] at Serial Number:[$SerialNumber]"
        #Logging -LogLevel "CRITICAL" -LogMessage "- CRITICAL: on $($serialNumber) - file is missing: [$Path]" -LogDestination $wishLogs -ShowColors -Less
        #Logging -LogLevel "CRITICAL" -LogMessage "- CRITICAL: on $($serialNumber) - file is missing: [$Path]" -LogDestination $fullPathUnitLogs -ShowColors -Less
        exit 1
    }
    #Write-Host "- OK"
    & $Log "INFO" "OK : [$Path]"
    #Logging -LogLevel "INFO" -LogMessage "- OK : [$Path]" -LogDestination $fullPathUnitLogs -ShowColors -Less
    #return $true
}


function returnFalseOnMissingFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string] $Path,

        [parameter(Mandatory = $false)]
        [scriptblock]$Logger
    )
    #Write-Host "## returnFalseOnMissingFile: $Path"
    & $Log "INFO" "returnFalseOnMissingFile"
    #Logging -LogLevel "INFO" -LogMessage "## returnFalseOnMissingFile" -LogDestination $fullPathUnitLogs -ShowColors -Less
    $result = Test-Path $path
    if ($false -eq $result){
        #Write-Host "- ERROR: missing file $path" -ForegroundColor Red
        & $Log "ERROR" "missing file [$Path]"
        #Logging -LogLevel "ERROR" -LogMessage "- ERROR: missing file [$Path]" -LogDestination $wishLogs -ShowColors -Less
        #Logging -LogLevel "ERROR" -LogMessage "- ERROR: missing file [$Path]" -LogDestination $fullPathUnitLogs -ShowColors -Less
    } else {
        #Write-Host "- OK : $Path"
        & $Log "INFO" "OK : [$Path]"
        #Logging -LogLevel "INFO" -LogMessage "- OK : [$Path]" -LogDestination $fullPathUnitLogs -ShowColors -Less
    }
    #return $result
}


function getFormatDate {
    $result = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
    return $result
}


function getSerialNumber {
    $result = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
    return $result
}


function getModel {
    $result = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
    return $result
}


function getManufacturer {
    $result = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
    return $result
}


function getArchitecture {
    $result = (Get-CimInstance -ClassName Win32_ComputerSystem).SystemType
    return $result
}


function getSMBIOSBIOSVersion {
    $result = (Get-CimInstance -ClassName Win32_BIOS).SMBIOSBIOSVersion
    return $result
}


function getBaseBoardProduct {
    $result = (Get-CimInstance -ClassName Win32_BaseBoard).Product
    return $result
}


function getKeyboardType {
    $result = (Get-CimInstance -ClassName Win32_Keyboard).DeviceID
    return $result
}


function getAcpiOemType {
    [CmdletBinding()]
    param()

    $acpiCode = @"
using System;
using System.Runtime.InteropServices;

public class AcpiChecker {
    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern uint GetSystemFirmwareTable(uint FirmwareTableProviderSignature, uint FirmwareTableID, IntPtr pFirmwareTableBuffer, uint BufferSize);

    public static string CheckOemType() {
        uint acpi = 0x41435049; // 'ACPI' provider signature

        // 1. Check for MSDM table (Windows 8 / 10 / 11 OA 3.0)
        uint msdmSize = GetSystemFirmwareTable(acpi, 0x4D53444D, IntPtr.Zero, 0); // 'MSDM'
        if (msdmSize > 0) {
            return "MSDM (Windows 8/10/11 OEM Key embedded in BIOS)";
        }

        // 2. Check for SLIC table (Windows 7 OA 2.1)
        uint slicSize = GetSystemFirmwareTable(acpi, 0x43494C53, IntPtr.Zero, 0); // 'SLIC'
        if (slicSize > 0) {
            return "SLIC (Windows 7 OEM Marker present - Key is on physical COA sticker, NOT in BIOS)";
        }

        return "NONE (No OEM ACPI tables found)";
    }
}
"@

    if (-not ([System.Management.Automation.PSTypeName]'AcpiChecker').Type) {
        Add-Type -TypeDefinition $acpiCode
    }

    return [AcpiChecker]::CheckOemType()
}

<# TODO: FIX: Single Responsibility Principle #>
function getIndexFromDictionary {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$WinEdition,

        [parameter(Mandatory = $false)]
        [string]$ProductLanguage,

        [parameter(Mandatory = $false)]
        [scriptblock]$Logger
    )

    if($ProductLanguage -eq "HU") {
        & $Log "INFO" "Using Hungarian language mapping for Windows Product."
        # Hashtable for HU
        $map = @{
            "home"                 = 1
            "home n"               = 2
            "education"            = 3
            "education n"          = 4
            "pro"                  = 5
            "pro n"                = 6
            "pro for workstations" = 7
            "enterprise"           = 8
        }
    } elseif ($ProductLanguage -eq "ENGB") {
        & $Log "INFO" "Using [$ProductLanguage] language mapping for Windows Product."
        # Hashtable for ENGB
        $map = @{
            "home"                  = 1
            "home n"                = 2
            "home single language"  = 3
            "education"             = 4
            "education n"           = 5
            "pro"                   = 6
            "pro n"                 = 7
            "pro education"         = 8
            "pro education n"       = 9
            "pro for workstation"   = 10
            "pro n for workstation" = 11
        }
    } else {
        & $Log "CRITICAL" "Missing Windows Product for [$ProductLanguage] language mapping"
        & $Log "CRITICAL" "Please upload this product into ISO directory and register into Config.json"
        return $null
    }

    $key = $WinEdition.Trim().ToLower()

    if ($map[$key] -ne $null) {
        & $Log "INFO" "Found index for [$WinEdition] -> [$($map[$key])]"
        return $map[$key]
    } else {
        & $Log "CRITICAL" "No index found for [$WinEdition] windows edition"
        return $null
    }
    
}


function measureTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$TaskName,

        [Parameter(Mandatory = $true, Position = 1)]
        [scriptblock]$ScriptBlock,

        [parameter(Mandatory = $false)]
        [scriptblock]$Logger
    )
    & $Log "INFO" ">>> START Task: [$TaskName]"

    # Start a stopwatch to measure the execution time
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        # Start ScriptBlock execution
        & $ScriptBlock
    }
    catch {
        & $Log "ERROR" "- Task Exception [$TaskName]: $_"
    }
    finally {
        # Stop the stopwatch and log the elapsed time
        $stopwatch.Stop()
        
        # Format date and time to hh:mm:ss.ff
        $elapsed = $stopwatch.Elapsed
        $formattedDuration = "{0:hh\:mm\:ss\.ff}" -f $elapsed

        & $Log "INFO" "<<< FINISHED Task: [$TaskName] | Duration: $formattedDuration"

        # A Check error code an add Duration
        checkLastCommand -ContextMessage "Duration: $formattedDuration"
    }
}


function formatTargetDrive {
    param (
        [parameter(Mandatory = $true)]
        [string]$DiskpartTXT
    )
    diskpart /s $DiskpartTXT
}


function applyWindowsImage {
    param (
        [parameter(Mandatory = $true)]
        [string]$WimPath,
        [parameter(Mandatory = $true)]
        [int]$Index,
        [parameter(Mandatory = $true)]
        [string]$TargetDrive
    )
    $cleanPath = $WimPath.Replace('/', '\')
    dism /Apply-Image /ImageFile:"$cleanPath" /Index:$Index /ApplyDir:$TargetDrive
}


function injectDrivers {
    param (
        [parameter(Mandatory = $true)]
        [string]$TargetDrive,
        [parameter(Mandatory = $true)]
        [string]$DriverPath
    )
    $cleanPath = $DriverPath.Replace('/', '\')
    dism /Image:$TargetDrive /Add-Driver /Driver:$cleanPath /Recurse /ForceUnsigned
}


function applyUnattendXML {
    param (
        [parameter(Mandatory = $true)]
        [string]$TargetDrive,
        [parameter(Mandatory = $true)]
        [string]$UnattendXMLPath
    )
    $cleanPath = $fullPathUnattendXMLDestination.Replace('/', '\')
    dism /Image:C:\ /Apply-Unattend:$cleanPath
}