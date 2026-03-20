# 1. Check if .NET exists at all on the machine
$dotnetCheck = & dotnet --list-runtimes 2>$null
if (!$dotnetCheck) {
    Write-Host "dotnet not found. No need to install it." -ForegroundColor Green
    exit 0
}

# 2. Check if the Uninstall Tool exists; install if missing
$toolPath = "C:\Program Files (x86)\dotnet-core-uninstall\dotnet-core-uninstall.exe"
$msiPath = "$PSScriptRoot\dotnet-core-uninstall.msi"

if (!(Test-Path $toolPath)) {
    if (Test-Path $msiPath) {
        Write-Host "Installing .NET Uninstall Tool..." -ForegroundColor Cyan
        Start-Process "msiexec.exe" -ArgumentList "/i `"$msiPath`" /quiet /norestart" -Wait
    } else {
        Write-Host "Error: dotnet-core-uninstall.msi not found." -ForegroundColor Red
        exit 1
    }
}

# 3. Install .NET 8.0.24 components first
Write-Host "Installing .NET 8.0.24 components..." -ForegroundColor Cyan
$installers = @(
    "windowsdesktop-runtime-8.0.24-win-x64.exe",
    "dotnet-runtime-8.0.24-win-x64.exe",
    "aspnetcore-runtime-8.0.24-win-x64.exe"
)

foreach ($exe in $installers) {
    $exePath = "$PSScriptRoot\$exe"
    if (Test-Path $exePath) {
        Write-Host "Installing $exe..." -ForegroundColor Gray
        # Using /install /quiet /norestart for .exe installers
        Start-Process "$exePath" -ArgumentList "/install /quiet /norestart" -Wait
    }
}

# 4. Proceed with scrubbing old versions using the tool
if (Test-Path $toolPath) {
    Write-Host "Removing all versions below 8.0.24..." -ForegroundColor Yellow
    
    # x64 Cleanup (removes everything below your new 8.0.24)
    & $toolPath remove --all-below 8.0.24 --runtime --yes --force
    & $toolPath remove --all-below 8.0.24 --windows-desktop-runtime --yes --force
    & $toolPath remove --all-below 8.0.24 --aspnet-runtime --yes --force
    & $toolPath remove --all-below 8.0.24 --hosting-bundle --yes --force
    & $toolPath remove --all-below 8.0.24 --sdk --yes --force
    
    # x86 Cleanup (clears x86 entirely)
    & $toolPath remove --all --x86 --runtime --yes --force
    & $toolPath remove --all --x86 --windows-desktop-runtime --yes --force
    & $toolPath remove --all --x86 --aspnet-runtime --yes --force
    & $toolPath remove --all --x86 --hosting-bundle --yes --force
    & $toolPath remove --all --x86 --sdk --yes --force
}

# 5. Final verification
$remaining = & dotnet --list-runtimes 2>$null | Where-Object { $_ -notlike "*8.0.24*" }
if (!$remaining) {
    Write-Host "dotnet 8.0.24 is the only version left" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Some older versions might still be present." -ForegroundColor Yellow
    exit 0
}