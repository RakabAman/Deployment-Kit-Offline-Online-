@echo off

setlocal ENABLEDELAYEDEXPANSION

set pth=%*
set file=
cd %pth%

title Searching in %pth% and all sub directories for xinput.dll
@Echo Off
cls

:begin
for /f "tokens=*" %%a in ('WHERE /R "%pth%" /F xinput*') Do (
        echo Found File in %%a
		set xa=%%~xa
		set xpth=%%~dpa
		echo.

		echo Checking for exsisting Backup 
		

		if !xa!==.bak (
			goto bke
			) else (
				echo No Backup File found
				
				goto cpy
				)
	)	
echo.	
set xpth=%pth%
echo Selecting root directory : %xpth%	
goto cpy
goto eof


:BKE
echo.
echo Backup already exist.
echo.
Echo Select Option
echo  1- Restore Original and remove x1input files
echo  2- Goto Copy menu
echo  3- Exit 
set /p j= "Select Option = "
if %j%==1 goto rst
if %j%==2 goto cpy
goto eof

:rst
echo.
title Restoring Orginal file
cd %xpth%
echo Deleting X1input files
del xinput*.dll 
echo Deletion Complete
echo. 
echo Restoring orignal xinput file
ren xinput.bak xinput.dll
echo.
echo Restore Complete
goto eof

:CPY
cd %xpth%
title Copying X1input files to %xpth%
echo.
echo Copy X1input files. Select Option
echo.
echo  1- 64 Bit (Recommanded for most new games)
echo  2- 32 Bit (Recommanded for old/lagacy games)
echo.

set /p j= "Select Which X1nput bit files to copy = "

if %j%==1 (
	echo Backing up orignal file
	ren xinput*.dll *.bak
	echo.
	echo Backup done
	echo.
	echo Copying X1input-64 bit files
	xcopy.exe c:\scripts\X1files\64\*.* %xpth%
	echo.
	echo Copying done
	goto eof
	)
	
if %j%==2 (
	echo Backing up orignal file
	ren xinput*.dll *.bak
	echo.
	echo Backup done
	echo.
	echo Copying X1input-32 bit files
	xcopy.exe c:\scripts\X1files\32\*.* %xpth%
	echo.
	echo Copying done
	goto eof
	)
echo.
echo Wronge Seletion	
goto eof
echo.

:eof
echo.
echo Exiting Program
echo.
setlocal DISABLEDELAYEDEXPANSION
pause


