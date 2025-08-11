@echo off
rem Sets the window title and color for a better look
title Portable ADB TCP/IP Activator
color 0A

cls
echo =================================================
echo   Automatic Activator for ADB TCP/IP (Port 5555)
echo =================================================
echo.
echo  ATTENTION:
echo  Please make sure your phone is connected to this
echo  computer using a USB cable and USB DEBUGGING IS ON.
echo.

rem Pauses the script and waits for the user to press any key
pause

echo.
echo Executing 'adb tcpip 5555' command...
echo.

rem Executes the command using the local adb.exe file
adb.exe tcpip 5555

echo.
echo =================================================
echo  SUCCESS!
echo  Port 5555 is now open. You can now unplug
echo  the USB cable and use wireless mode.
echo =================================================
echo.

rem Pauses the script so the window doesn't close immediately
pause
