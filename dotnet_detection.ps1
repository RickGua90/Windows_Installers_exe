$TargetVersion = "8.0.24"

# 1. Check if 8.0.24 folder exists (Primary proof)
$Path = "C:\Program Files\dotnet\shared\Microsoft.NETCore.App\$TargetVersion"
$Found = Test-Path $Path

# 2. Check if the dotnet host still sees old versions as ACTIVE
# This only checks the real runtimes, not the messy registry
$Runtimes = & "C:\Program Files\dotnet\dotnet.exe" --list-runtimes 2>$null
$OldFound = $Runtimes | Where-Object { $_ -notlike "*$TargetVersion*" }

# 3. Final Decision for Intune
if ($Found -and !$OldFound) {
    # Success: 8.0.24 is there and the runtime list is clean
    exit 0
} else {
    # Failed: 8.0.24 is missing or old versions are still active
    exit 1
}