@echo off
setlocal
title Windows 10-to-11 Migration Suite

:: PROJECT: Windows 11 Upgrade Engine
:: AUTHOR: Rick
:: LOGIC: Combined Hardware Bypass + Dynamic Update Patching + Silent Setup

echo [1/3] Initializing System Compatibility Overrides...

:: --- SECTION 1: GLOBAL HARDWARE BYPASS ---
:: Setting the core registry keys to ignore TPM, CPU, and RAM requirements
reg add HKLM\SYSTEM\Setup\MoSetup /v AllowUpgradesWithUnsupportedTPMorCPU /t REG_DWORD /d 1 /f >nul
reg add HKLM\SYSTEM\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1 /f >nul
reg add HKLM\SYSTEM\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1 /f >nul
reg add HKLM\SYSTEM\Setup\LabConfig /v BypassRAMCheck /t REG_DWORD /d 1 /f >nul
reg add HKLM\SYSTEM\Setup\LabConfig /v BypassCPUCheck /t REG_DWORD /d 1 /f >nul
reg add HKLM\SYSTEM\Setup\LabConfig /v BypassStorageCheck /t REG_DWORD /d 1 /f >nul

:: --- SECTION 2: DYNAMIC UPDATE INTERCEPTION ---
set "IFEO=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
set "SRCDIR=%SystemDrive%\$WINDOWS.~BT\Sources"

:: If the script is called by the OS during the upgrade, it jumps to the bypass logic
if /i "%~1"=="--bypass" goto :RUN_BYPASS_LOGIC

echo [2/3] Registering Dynamic Update Readiness...
if not exist "%SystemDrive%\Scripts" mkdir "%SystemDrive%\Scripts" >nul
copy /y "%~f0" "%SystemDrive%\Scripts\SysPrep_Readiness.cmd" >nul

:: Redirecting the SetupHost engine to run back through this script
reg add "%IFEO%\SetupHost.exe" /f /v UseFilter /d 1 /t reg_dword >nul
reg add "%IFEO%\SetupHost.exe\0" /f /v FilterFullPath /d "%SRCDIR%\SetupHost.exe" >nul
reg add "%IFEO%\SetupHost.exe\0" /f /v Debugger /d "%SystemDrive%\Scripts\SysPrep_Readiness.cmd --bypass" >nul

:: --- SECTION 3: LAUNCH SETUP ---
:: Initiating the actual Windows 11 upgrade engine
echo [3/3] Launching Windows 11 Setup Engine...
if exist "%~dp0setup.exe" (
    "%~dp0setup.exe" /auto upgrade /quiet /eula accept /compat ignorewarning
) else (
    echo [ERROR] setup.exe not found. Please run this from the root of the Windows 11 ISO.
    pause
    exit /b 1
)

echo Migration command initiated successfully.
endlocal
exit /b 0

:RUN_BP_LOGIC
:: This hidden section only runs when called by the Windows Installer
shift
set CLI=%*
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f /v DisableWUfBSafeguards /d 1 /t reg_dword >nul
reg add HKLM\SYSTEM\Setup\MoSetup /f /v AllowUpgradesWithUnsupportedTPMorCPU /d 1 /t reg_dword >nul
start "" "%SRCDIR%\SetupHost.exe" %CLI% /Compat IgnoreWarning /Telemetry Disable
exit /b
