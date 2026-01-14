@echo off

Title=Creating Directory List to Text file

set path=%~1
set name=%~n1
set ext=txt

Echo Type of Text File (txt,rtf,xls,etc) (default type txt)
set /p ext=Type: 
			
rem echo %path%
rem echo %name%

cd /d "%path%"

dir /b /o:n > "%name%".%ext%

echo.
Echo Directory list Created in %path%

C:\windows\system32\timeout.exe /t 05

