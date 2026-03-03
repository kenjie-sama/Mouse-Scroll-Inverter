# ==========================================
# Interactive Mouse Scroll Inverter
# ==========================================

Write-Host ""
Write-Host "=== Mouse Scroll Configuration Tool ==="
Write-Host ""

try {

    # Ask for Hardware ID
    $TargetHardwareID = Read-Host "Enter Mouse Hardware ID (example: VID_046D&PID_C52B)"

    if ([string]::IsNullOrWhiteSpace($TargetHardwareID)) {
        Write-Host "No Hardware ID entered. Exiting..."
        exit
    }

    Write-Host ""
    Write-Host "Invert scroll direction?"
    Write-Host "Press Y for YES"
    Write-Host "Press any other key for NO"
    Write-Host ""

    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    if ($key.Character -eq 'y' -or $key.Character -eq 'Y') {
        $flipValue = 1
        Write-Host "`nScroll will be INVERTED."
    }
    else {
        $flipValue = 0
        Write-Host "`nScroll will be NORMAL."
    }

    Write-Host ""
    Write-Host "Searching for devices matching: $TargetHardwareID"
    Write-Host ""

    $enumPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\HID"
    $devices = Get-ChildItem -Path $enumPath -Recurse -ErrorAction SilentlyContinue

    $modified = 0

    foreach ($device in $devices) {
        try {
            $hardwareIds = Get-ItemProperty -Path $device.PSPath -Name "HardwareID" -ErrorAction Stop

            if ($hardwareIds.HardwareID -match $TargetHardwareID) {

                $deviceParamsPath = Join-Path $device.PSPath "Device Parameters"

                if (Test-Path $deviceParamsPath) {

                    New-ItemProperty -Path $deviceParamsPath `
                                     -Name "FlipFlopWheel" `
                                     -PropertyType DWord `
                                     -Value $flipValue `
                                     -Force | Out-Null

                    Write-Host "Updated:" $device.PSChildName
                    $modified++
                }
            }
        }
        catch {}
    }

    Write-Host ""
    if ($modified -gt 0) {
        Write-Host "$modified device instance(s) updated successfully."
        Write-Host "Replug the mouse or restart Windows to apply changes."
    }
    else {
        Write-Host "No matching devices found."
    }

}
catch {
    Write-Host ""
    Write-Host "Operation cancelled."
}