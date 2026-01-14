@echo off
Rem rename ddlvalley extra to required string to remove
setlocal ENABLEDELAYEDEXPANSION
set pth=%*
cd %pth%

title Searching in %pth% and all sub directories

:begin
set LF=
cls
echo ToExit - Dont Search [Hit Enter]
set /p LF=Looking for :
if x%LF%==x goto eof
dir /s %LF%
echo.
echo done.
pause>nul
goto begin
:eof
cls
echo Thank YOu
pause>nul
