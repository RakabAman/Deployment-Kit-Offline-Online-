@echo off
CLS
rem ----------------------Admin Checker-------------------------------------------

echo Checking for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

echo Permission check result: %errorlevel%

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
echo Requesting administrative privileges...
goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

echo Running created temporary "%temp%\getadmin.vbs"
timeout /T 2
"%temp%\getadmin.vbs"
exit /B

:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0" 

echo Batch was successfully started with admin privileges
echo .
cls

rem ----------Version-Checker-------------------------------------------
set arch=x64
if /i %PROCESSOR_ARCHITECTURE%==x86 (
if "%PROCESSOR_ARCHITEW6432%"=="" (set arch=x86)
)
set "CurrentVersion=0"
set "CurrentBuildNumber=0"
for /f "tokens=2*" %%a in ('reg query "hklm\software\microsoft\Windows NT\currentversion" /v CurrentVersion') do set "CurrentVersion=%%b"
if /i "%CurrentVersion%" LSS "6.3" goto :nonsupported

for /f "tokens=2*" %%a in ('reg query "hklm\software\microsoft\Windows NT\currentversion" /v CurrentBuildNumber') do set "CurrentBuildNumber=%%b"
if /i "%CurrentBuildNumber%" LSS "10049" goto :nonsupported

for /f "tokens=2*" %%a in ('reg query "hklm\software\microsoft\Windows NT\currentversion" /v ProductName') do set "ProductName=%%b"

for /f "tokens=2*" %%a in ('reg query "hklm\software\microsoft\Windows NT\currentversion" /v DisplayVersion') do set "DisplayVersion=%%b"

rem ----------------Set setup-------------

set autowingetall=0
color 30
rem ----------------Display------------
:MENU
Title Deployment Kit By Rakab Aman
MODE CON COLS=80 LINES=30
set currentpath=%~dp0%
echo Current Script path %currentpath%
echo. 
echo                     ===================================
echo                         Script made by  Rakab Aman
echo                          Run at your own risk
echo                     ===================================
echo.
Echo      Current System : %ProductName% %DisplayVersion% %arch% Build %CurrentBuildNumber% ver %CurrentVersion% 
ECHO .............................................................................
ECHO                             INSTALLATION MENU 
Echo              PRESS 1-9 to select your task, or enter exit to quit.
ECHO     FIRST TIME press 3! to install chocolatey (if not installed previously)
echo.
Echo........ ........Install Online from Chocolatey ...............................
ECHO. 1 - Install Chocolatey                     2 - Developer Chocolatey apps
ECHO. 3 - Basic Chocolatey apps                  4 - Upgrade apps
ECHO. 
ECHO........ Install Offline from preloaded apps ..................................
ECHO. 5 - Install Offile preloaded apps          6 - Install Drivers
ECHO. 
Echo....................................................
Echo. 7 - Install All 
Echo....................................................
ECHO. 8 - Backup/Restore/Custom Script Menu
Echo....................................................
ECHO.
ECHO. Type Exit to Exit Menu
echo.

SET /P M=.Type 1-8 then press ENTER:
IF %M%==3 GOTO Choco-Basic
IF %M%==2 GOTO CHOCO-DEV
IF %M%==1 GOTO CHOCO-INST
IF %M%==4 GOTO UPG
IF %M%==6 GOTO DRI
IF %M%==5 GOTO SAI
IF %M%==7 goto INS
IF %M%==8 cls&goto BRMENU
IF %M%==9 goto SCP	


echo..... Please make proper selction of Task from the List .....
pause
cls
goto MENU


:UPG
title Upgrading All Apps
Echo....... Upgrading All Apps loaded by Chocolatey ......
choco upgrade choco
GOTO MENU


:CHOCO-INST
REM ----- INSTALL CHOCOLATEY -----
Title Installing Chocolatey.. Please Wait
Echo...... Installing Chocolatey. Make sure connected to Internet ...
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
choco feature enable -n allowGlobalConfirmation
choco upgrade chocolatey

ECHO ...............................................
echo.
ECHO A RESTART OF THE BATCH FILE IS MAYBE NECESSARY!!
ECHO.
ECHO ...............................................
if %M%==7 GOTO :DRI
GOTO MENU


:Choco-Basic
REM ---- Chocolatey Basic apps --------
Title Installing Basic Apps from Chocolatey
echo...... Installing Basic Apps from Chocolatey. Please wait ....
choco install "%currentpath%\defaultapps.config" -y  
IF %M%==7 GOTO :CHOCO-DEV
GOTO MENU

:CHOCO-DEV
REM developer tools
Title Installing Developers apps from Chocolatey
echo...... Installing Developers apps from Chocolatey Please wait ...
choco install "%currentpath%\devapps.config" -y
IF %M%==7 GOTO :SAI
GOTO MENU

:DRI
REM Install drivers
title Installing Drivers
echo..... Installing Driver Please wait......
echo.
Echo. Set Online Option or local
echo.
echo. 1 - Online through Chocolatey
echo. 2 - Local preloaded
echo.
set /P D=.Select online or Local install=
if %D%==1 choco install "%currentpath%\drivers.config"
if %D%==2 PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0installdriver.ps1'"
Echo Driver Installing Complete
IF %M%==7 GOTO SAI
GOTO MENU

:SAI
REM install Secondary apps
title Installing Silent and Non Silent apps.
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0installnonsilent.ps1'"
Echo Install non Silent apps complete.
Echo Installing Silent app... Please wait
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0installsilent.ps1'"
Echo Complete Installing silent apps 
IF %M%==7 GOTO :GEN
GOTO MENU

:INS
REM All install, install choco (CHOCO-INST)->Drivers(CHOCO-DEV)->Offline Apps(sai)->Basic apps(GEn)->Dev Apps(Dev)
Echo Auto Installing All (Choco->Drivers->Offline Apps->Basic Apps->Developers Apps)
goto CHOCO-INST



:BRMENU	
title Backup and Retore Menu By Rakab Aman
echo.............................................
echo Backup and Restore Menu
echo.
echo.
echo.
echo PRESS 1-3 to select your task, or enter exit to quit.
echo.
echo.............................................
echo.
echo. 1 - Backup Files and Folders givin in Local.csv file
echo. 2 - Restore Files and folder given in Local.csv file
echo. 3 - Install Custom Scripts w/ Context menu
echo. 4 - Back to Install Menu
echo. 


SET /P B=Type 1-3 then press ENTER:
IF %B%==1 GOTO BCK
IF %B%==2 GOTO RST
IF %B%==3 GOTO SCP
if %B%==4 cls&goto Menu
if %B%==exit exit

Echo........ Make proper Selection for the Tasks .......
pause
cls
goto BRMENU

:BCK
Rem Run backup Script
Title Backup Script running
Echo........ Launching Backup Script ..........
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0backup.ps1'"
echo.
echo........ Backup Completed .........
goto :BRMENU

:RST
Rem Run Retore Script
Title Restore Script running
Echo........ Launching Backup Script ..........
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0restore.ps1'"
echo.
echo........ Restore Completed .........
goto :BRMENU

:SCP
rEM INSTALL CUSTOM SCRIPTS, Powertools AND CONTEXT MENU
title Loading Custom Scripts
rem Echo 1-StandAlone Shell  or 2-Eczmenu shell
rem SET /P B=Type 1-2 then press ENTER:
rem IF %B%==1 GOTO SCP
rem IF %B%==2 GOTO SCP
rem if %B%==3 cls&goto Menu
rem if %B%==exit exit

ECHO...... Installing Customs Scripts ..........
robocopy "%currentpath%\Custom_Scripts" "%systemdrive%\Scripts" /copyall
robocopy "%currentpath%\powertools" "%systemdrive%\PowerTools" /copyall
Echo Copying Data done....
Echo Registring Context Menu
for %%R in (%systemdrive%\Scripts\reg\*.reg) do REG IMPORT %%R
start /b C:\scripts\tools\EcMenu\EcMenu_x64.exe
timeout /T 1 /nobreak >nul
taskkill /f /IM ecmenu*
echo f|xcopy/y /c /f "C:\scripts\tools\EcMenu\EcMenu.lnk" "%AppData%\Microsoft\Windows\Start Menu\Programs\"
echo f|xcopy/y /c /f "C:\scripts\Audio Repeater (Games).lnk" "%AppData%\Microsoft\Windows\Start Menu\Programs\"
ECHO........ Customs Scripts Iinstallation Completed .........
goto BRMENU
