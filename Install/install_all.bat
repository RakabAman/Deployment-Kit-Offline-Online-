@echo off
CD /d %~dp0

rem ---------------------------------------
rem Get folder/App name
for %%a in (.) do set appname=%%~na
rem ------------------------------------

rem Installing .exe files

echo Installing Offline Apps/Programs By Rakab Aman
echo.

for /r %%G in (*.cmd) Do start /wait /b "" "%%G"
	
timeout -t 03