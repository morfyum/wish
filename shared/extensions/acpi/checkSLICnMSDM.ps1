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

[AcpiChecker]::CheckOemType()