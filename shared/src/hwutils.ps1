
function getPhysicalDiskSerialNumbers {
    $ASN = ((Get-CimInstance -Namespace root/Microsoft/Windows/Storage -ClassName MSFT_PhysicalDisk).AdapterSerialNumber)
    Write-Host "AdapterSerialNumber: $ASN"

    # Get ALL physical disks without filtering to ensure we don't miss anything
    $disks = Get-PhysicalDisk
    # Check if we actually got any disks back from the OS
    if ($null -eq $disks) {
        Write-Warning "No physical disks were detected. Please ensure you are running PowerShell as Administrator."
    } else {
        # Capture the entire foreach loop output into the $DriveResults array
        $DriveResults = foreach ($disk in $disks) {
        # Step 1: Fallback logic between ASN and SN
        $rawSn = $disk.AdapterSerialNumber
        if ([string]::IsNullOrEmpty($rawSn)) {
            $rawSn = $disk.SerialNumber
        }
        $cleanedRealSN = "Unknown"
        $normalizedStr = "N/A"
        if ($null -ne $rawSn) {
            # Step 2: Replace EVERY character that is NOT A-Z, a-z, 0-9, or a hyphen with an underscore
            $normalizedStr = $rawSn -replace '[^A-Za-z0-9-]', '_'
            # Step 3: Split the string by underscores to get the remaining data blocks
            $blocks = $normalizedStr -split '_' | Where-Object { $_ -ne "" }
            # Step 4: Find the longest block which is assumed to be the real SN
            $longestBlock = ""
            foreach ($block in $blocks) {
                if ($block.Length -gt $longestBlock.Length) {
                    $longestBlock = $block
                }
            }
            $cleanedRealSN = $longestBlock
        }
        # Output this custom object to be collected by the $DriveResults variable
        [PSCustomObject]@{
        FriendlyName = $disk.FriendlyName
        BusType = $disk.BusType
        RawValue = $rawSn
        NormalizedStr = $normalizedStr
        CleanedRealSN = $cleanedRealSN
        }
        }
        # Display the contents of the array in a formatted table
        $DriveResults | Format-Table -AutoSize
    }
}