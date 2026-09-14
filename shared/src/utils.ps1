# utils.ps1
. ./logging/logging.ps1
#$wishLogs = "..\logs\wish.log"

function waitForMissingFile {
    <#  waitForMissingFile is handle network issues,
        use this function if you have instable internet connection between actions
    #>
    # TODO 
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
        [string[]]$ArgumentList
    )
    # Execute command and capture both standard output and error streams
    $output = & $FilePath $ArgumentList 2>&1

    if ($LASTEXITCODE -eq 0) {
        #Write-Host "- OK : $FilePath executed successfully." -ForegroundColor Green
        Logging -LogLevel "INFO" -LogMessage "- OK : [$FilePath] executed successfully." -LogDestination $fullPathUnitLogs -ShowColors -Less
        return $true
    } else {
        #Write-Host "- ERROR: $FilePath failed with exit code $LASTEXITCODE" -ForegroundColor Red
        Logging -LogLevel "ERROR" -LogMessage "- ERROR: [$FilePath] failed with exit code $LASTEXITCODE" -LogDestination $wishLogs -ShowColors -Less
        if ($output) {
            #Write-Host "Output:" -ForegroundColor Yellow
            Logging -LogLevel "INFO" -LogMessage "Output:" -LogDestination $fullPathUnitLogs -ShowColors -Less
            #$output | ForEach-Object { Write-Host "  $_" }
            $output | ForEach-Object { Logging -LogLevel "INFO" -LogMessage "[$_]" -LogDestination $fullPathUnitLogs -ShowColors -Less }
        }
        return $false
    }
}
function checkLastCommand {
    [CmdletBinding()]
    param(
        [string]$ContextMessage = "" # Optional Comment
    )

    # Get data from Call Stack
    $caller         = (Get-PSCallStack)[1]
    $callerFunction = if ($caller.Command) { $caller.Command } else { "MainScript" }
    $lineNumber     = $caller.ScriptLineNumber
    $lineText       = if ($caller.Position) { $caller.Position.Text.Trim() } else { "N/A" }

    Logging -LogLevel "INFO" -LogMessage "## checkLastCommand (Caller: $callerFunction)" -LogDestination $fullPathUnitLogs -ShowColors -Less

    if ($LASTEXITCODE -eq 0) {
        Logging -LogLevel "INFO" -LogMessage "- OK : [$callerFunction] executed successfully (Line $lineNumber)." -LogDestination $fullPathUnitLogs -ShowColors -Less
    } else {
        $errorMsg = "Failed in [$callerFunction] | Line $lineNumber | Command: '$lineText' | ExitCode: [$LASTEXITCODE]"
        
        if ($ContextMessage) {
            $errorMsg += " | Note: $ContextMessage"
        }

        Logging -LogLevel "ERROR" -LogMessage "- $($serialNumber) : $errorMsg" -LogDestination $wishLogs -ShowColors -Less
        Logging -LogLevel "ERROR" -LogMessage "- $errorMsg" -LogDestination $fullPathUnitLogs -ShowColors -Less
    }
}

function exitOnMissingFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string] $Path
    )
    #Write-Host "## exitOnMissingFile: $Path"
    Logging -LogLevel "INFO" -LogMessage "## exitOnMissingFile" -LogDestination $fullPathUnitLogs -ShowColors -Less
    if (-not (Test-Path $Path)) {
        #Write-Host "- CRITICAL: file is missing" -ForegroundColor Red
        Logging -LogLevel "CRITICAL" -LogMessage "- CRITICAL: on $($serialNumber) - file is missing: [$Path]" -LogDestination $wishLogs -ShowColors -Less
        Logging -LogLevel "CRITICAL" -LogMessage "- CRITICAL: on $($serialNumber) - file is missing: [$Path]" -LogDestination $fullPathUnitLogs -ShowColors -Less
        exit 1
    }
    #Write-Host "- OK"
    Logging -LogLevel "INFO" -LogMessage "- OK : [$Path]" -LogDestination $fullPathUnitLogs -ShowColors -Less
    #return $true
}

function returnFalseOnMissingFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string] $Path
    )
    #Write-Host "## returnFalseOnMissingFile: $Path"
    Logging -LogLevel "INFO" -LogMessage "## returnFalseOnMissingFile" -LogDestination $fullPathUnitLogs -ShowColors -Less
    $result = Test-Path $path
    if ($false -eq $result){
        #Write-Host "- ERROR: missing file $path" -ForegroundColor Red
        Logging -LogLevel "ERROR" -LogMessage "- ERROR: missing file [$Path]" -LogDestination $wishLogs -ShowColors -Less
        Logging -LogLevel "ERROR" -LogMessage "- ERROR: missing file [$Path]" -LogDestination $fullPathUnitLogs -ShowColors -Less
    } else {
        #Write-Host "- OK : $Path"
        Logging -LogLevel "INFO" -LogMessage "- OK : [$Path]" -LogDestination $fullPathUnitLogs -ShowColors -Less
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

function getIndexFromDictionary {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$WinEdition
    )
    # Hashtable
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

    $key = $WinEdition.Trim().ToLower()

    if ($map[$key] -ne $null) {
        #Write-Host "- OK   : Found index for [$WinEdition] -> [$($map[$key])]" -ForegroundColor Green
        Logging -LogLevel "INFO" -LogMessage "- OK : Found index for [$WinEdition] -> [$($map[$key])]" -LogDestination $wishLogs -ShowColors -Less
        return $map[$key]
    } else {
        #Write-Host "- ERROR: No index found for [$WinEdition]" -ForegroundColor Red
        $errorMessage = "- No index found for [$WinEdition]"
        Logging -LogLevel "ERROR" -LogMessage $errorMessage -LogDestination $wishLogs -ShowColors -Less
        return $null
    }
    
}

function measureTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$TaskName,

        [Parameter(Mandatory = $true, Position = 1)]
        [scriptblock]$ScriptBlock
    )

    Logging -LogLevel "INFO" -LogMessage ">>> START Task: [$TaskName]" -LogDestination $fullPathUnitLogs -ShowColors -Less

    # Start a stopwatch to measure the execution time
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        # Start ScriptBlock execution
        & $ScriptBlock
    }
    catch {
        Logging -LogLevel "ERROR" -LogMessage "- Task Exception [$TaskName]: $_" -LogDestination $fullPathUnitLogs -ShowColors -Less
    }
    finally {
        # Stop the stopwatch and log the elapsed time
        $stopwatch.Stop()
        
        # Format date and time to hh:mm:ss.ff
        $elapsed = $stopwatch.Elapsed
        $formattedDuration = "{0:hh\:mm\:ss\.ff}" -f $elapsed

        Logging -LogLevel "INFO" -LogMessage "<<< FINISHED Task: [$TaskName] | Duration: $formattedDuration" -LogDestination $fullPathUnitLogs -ShowColors -Less

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