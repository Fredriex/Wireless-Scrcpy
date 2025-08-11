@echo off
rem Sets the window title and color for a better look
title Portable Wireless ADB Helper (for Android 11+)
color 0B

:MainMenu
cls
echo =================================================
echo   Wireless ADB Helper (for Android 11+)
echo =================================================
echo.
echo This tool helps you connect to your phone using
echo the built-in 'Wireless Debugging' feature.
echo.
echo  MENU:
echo.
echo    1. Pair New Device (One-Time Setup)
echo    2. Connect to Paired Device (Daily Use)
echo    3. Exit
echo.
echo =================================================
echo.

set "CHOICE="
set /p CHOICE="--> Enter your choice (1-3): "

if "%CHOICE%"=="1" goto PairDevice
if "%CHOICE%"=="2" goto ConnectDevice
if "%CHOICE%"=="3" exit /b
goto MainMenu

rem --- Pairing Section ---
:PairDevice
cls
echo [Pair New Device]
echo.
echo 1. On your phone, go to Settings > Developer Options > Wireless Debugging.
echo 2. Tap on 'Pair device with pairing code'.
echo 3. The phone will show an IP Address, a Port, and a Pairing Code.
echo.

set /p PAIR_IP_PORT="--> Enter the IP Address and Port (e.g., 192.168.1.5:41239): "
if not defined PAIR_IP_PORT goto MainMenu

echo.
echo Executing pairing command...
rem Executes the command using the local adb.exe file
adb.exe pair %PAIR_IP_PORT%
echo.

set /p PAIR_CODE="--> Enter the 6-digit Wi-Fi pairing code: "
if not defined PAIR_CODE goto MainMenu

echo.
echo ---
echo Pairing process finished. Check the output above for success or failure.
echo ---
echo.
pause
goto MainMenu

rem --- Connecting Section ---
:ConnectDevice
cls
echo [Connect to Paired Device]
echo.
echo 1. On your phone, go to Settings > Developer Options > Wireless Debugging.
echo 2. The screen will show an IP Address and Port for connection.
echo    (This port is DIFFERENT from the pairing port).
echo.

set /p CONN_IP_PORT="--> Enter the IP Address and Port (e.g., 192.168.1.5:37521): "
if not defined CONN_IP_PORT goto MainMenu

echo.
echo Attempting to connect...
rem Executes the command using the local adb.exe file
adb.exe connect %CONN_IP_PORT%
echo.

echo ---
echo Connection process finished. You can now use scrcpy or other adb commands.
echo ---
echo.
pause
goto MainMenu
