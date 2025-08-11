@echo off
setlocal enabledelayedexpansion

rem --- Setel mode fullscreen ---
if not "%1"=="max" start "" /max "%~f0" max & exit

:MainMenu
cls
echo =================================================
echo   WIRELESS SCRCPY
echo =================================================
echo.
echo MAIN MENU:
echo.
echo   1. Scan Network (Find New Devices)
echo   2. Connect from Saved IPs
echo   3. Connect with Manual IP
echo   4. Manage IP List
echo   5. Exit
echo.
echo =================================================
echo.

set "CHOICE="
set /p CHOICE="--> Enter your choice (1-5): "

if "%CHOICE%"=="1" goto ScanNetwork
if "%CHOICE%"=="2" goto ScanSavedIPs
if "%CHOICE%"=="3" goto ManualMode
if "%CHOICE%"=="4" goto ManageIPs
if "%CHOICE%"=="5" exit /b
goto MainMenu

rem --- Network Scan Mode ---
:ScanNetwork
cls
echo [Network Scan Mode]
echo.
echo [1] Determining your local network...
set "my_ip="
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do set "my_ip=%%a"
set "my_ip=%my_ip: =%"
for /f "tokens=1-3 delims=." %%a in ("%my_ip%") do set "subnet=%%a.%%b.%%c"

if not defined subnet (
    echo ERROR: Could not determine your local network.
    pause
    goto MainMenu
)
echo Network found: %subnet%.0/24
echo.
echo [2] Clearing old connections and starting scan...
adb.exe disconnect > nul 2> nul
echo (This process may take a moment, please be patient)
echo.

for /L %%i in (1,1,254) do (
    start "" /b adb.exe connect %subnet%.%%i:5555 > nul 2> nul
)

echo [3] Waiting for responses...
timeout /t 8 /nobreak > nul

echo.
echo [4] Compiling list of active devices...
set "count=0"
set "tempfile=%temp%\adb_devices_list.txt"
adb.exe devices > "%tempfile%"

for /f "tokens=1" %%d in ('findstr ":5555.*device" "%tempfile%"') do (
    set /a count+=1
    set "device[!count!]=%%d"
)
if exist "%tempfile%" del "%tempfile%"

if %count% equ 0 (
    echo.
    echo ERROR: No active ADB devices were found on your network.
    pause
    goto MainMenu
)

echo.
echo [5] Getting device model information...
for /L %%i in (1,1,%count%) do (
    set "current_device=!device[%%i]!"
    for /f "delims=" %%m in ('adb.exe -s !current_device! shell getprop ro.product.model') do set "model_name=%%m"
    set "display_list[%%i]=!current_device! (!model_name!)"
)

echo.
echo =================================================
echo   Devices Found
echo =================================================
echo.
for /L %%i in (1,1,%count%) do (
    echo   %%i. !display_list[%%i]!
)
echo.
set "D_CHOICE="
set /p D_CHOICE="--> Select a device to connect (1-%count%): "

if %D_CHOICE% GTR 0 if %D_CHOICE% LEQ %count% (
    set "ACTIVE_DEVICE=!device[%D_CHOICE%]!"
    echo.
    echo Connecting to !ACTIVE_DEVICE!...
    echo.
    scrcpy.exe -s !ACTIVE_DEVICE!
) else (
    echo.
    echo Invalid selection.
)
pause
goto MainMenu

rem --- Scan Saved IPs Mode ---
:ScanSavedIPs
cls
echo [Scan Saved IPs Mode]
echo.
echo [1] Checking IP database...
if not exist "saved_ips.txt" (
    echo ERROR: No saved IPs found.
    echo Please add an IP first via the 'Manage IP List' menu.
    pause
    goto MainMenu
)

echo [2] Clearing old connections...
adb.exe disconnect > nul 2> nul

echo.
echo [3] Launching connection attempts in parallel...
for /f "usebackq" %%i in ("saved_ips.txt") do (
    echo  - Launching connection to %%i ...
    start "" /b adb.exe connect %%i:5555 > nul 2> nul
)

echo.
echo [4] Waiting a few seconds for connections to establish...
timeout /t 3 /nobreak > nul

echo.
echo [5] Searching for an active device...
set "ACTIVE_DEVICE="
set "tempfile=%temp%\adb_devices_list.txt"
adb.exe devices > "%tempfile%"

for /f "tokens=1" %%d in ('findstr ":5555.*device" "%tempfile%"') do (
    if not defined ACTIVE_DEVICE set "ACTIVE_DEVICE=%%d"
)
if exist "%tempfile%" del "%tempfile%"

if defined ACTIVE_DEVICE (
    echo SUCCESS! Active device found at: !ACTIVE_DEVICE!
    echo.
    echo [6] Starting scrcpy...
    scrcpy.exe -s !ACTIVE_DEVICE!
) else (
    echo ERROR: No active device found from your IP list.
)
echo.
pause
goto MainMenu

rem --- Manual Input Mode ---
:ManualMode
cls
echo [Manual Input Mode]
echo.
echo [1] Clearing old connections...
adb.exe disconnect > nul 2> nul
timeout /t 1 /nobreak > nul

echo.
echo [2] Please enter your phone's IP address.
set /p IP_ADDRESS="--> Enter IP Address: "
if not defined IP_ADDRESS goto MainMenu

echo.
echo Connecting to %IP_ADDRESS%:5555 ...
adb.exe connect %IP_ADDRESS%:5555
echo.
echo Starting scrcpy...
scrcpy.exe -s %IP_ADDRESS%:5555
echo.
pause
goto MainMenu

rem --- IP Management Menu ---
:ManageIPs
cls
echo =================================================
echo   Manage IP List
echo =================================================
echo.
echo   1. View Saved IP List
echo   2. Add New IP
echo   3. Delete ALL Saved IPs
echo   4. Back to Main Menu
echo.
echo =================================================
echo.
set "M_CHOICE="
set /p M_CHOICE="--> Enter your choice (1-4): "

if "%M_CHOICE%"=="1" goto ViewIPs
if "%M_CHOICE%"=="2" goto AddIP
if "%M_CHOICE%"=="3" goto ClearIPs
if "%M_CHOICE%"=="4" goto MainMenu
goto ManageIPs

:ViewIPs
cls
echo [Saved IP List]
echo.
if exist "saved_ips.txt" (
    type "saved_ips.txt"
) else (
    echo (No IPs are currently saved)
)
echo.
pause
goto ManageIPs

:AddIP
cls
echo [Add New IP]
echo.
set /p NEW_IP="--> Enter the new IP to save: "
if not defined NEW_IP goto ManageIPs
echo %NEW_IP%>>"saved_ips.txt"
echo.
echo SUCCESS: IP %NEW_IP% has been saved.
pause
goto ManageIPs

:ClearIPs
cls
echo [Delete All IPs]
echo.
echo WARNING: This action will delete all of your saved IPs.
set /p CONFIRM="--> Are you sure? (Type Y to confirm): "
if /i "%CONFIRM%"=="Y" (
    if exist "saved_ips.txt" (
        del "saved_ips.txt"
        echo.
        echo SUCCESS: All IPs have been deleted.
    ) else (
        echo.
        echo Nothing to delete.
    )
) else (
    echo.
    echo Cancelled. Nothing was deleted.
)
pause
goto ManageIPs
