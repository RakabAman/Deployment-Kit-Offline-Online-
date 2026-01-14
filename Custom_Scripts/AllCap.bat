@echo off
Rem rename ddlvalley extra to required string to remove
setlocal enableDelayedExpansion
title Rename File/Folder to All CAP
echo Change name for Sure, close dialog for cancel
echo.

set "fnm=%~nx1"
rem echo %fnm%

FOR /F "delims=," %%A IN ('Powershell -Nop -C "($env:fnm).ToUpper()"') DO SET "nfnm=%%A"

rem echo %fnm% to %nfnm%
rem pause

echo rename "%fnm%" "!nfnm!"
echo.
pause
 ren  "%~1" "!nfnm!"
@endlocal