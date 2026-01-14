@echo off
Rem rename ddlvalley extra to required string to remove
setlocal enableDelayedExpansion
title Rename All Files and Folder - remove unwanted tags
echo Change name for Sure, close dialog for cancel

for /r %%a in (*) do (
 set "fnm=%~na"
  rem remove unwated tags
for %%G In (ddlvalley mkvhub .cool .net .com [ ] .me .cc tfpdl www) do set "fnm=!fnm:%%G=!"
  rem replace dots and dash
for %%G In (. _ -) do set "fnm=!fnm:%%G= !"
  rem year in paranthesis
for %%G In (2017 2018 2019 2020 2021) do set "fnm=!fnm:%%G=(%%G)!"
  rem set changes
set "fnm=!fnm:5 1=5.1!"
set "fnm=!fnm:web dl=WEB-DL!"
  rem remove any spaces
for /F "Tokens=*" %%G In ("!fnm!") do set "nfnm=%%G"
 echo rename "%~nxa" "!nfnm!%~xa"
pause
 ren  "%~a" "!nfnm!%~xa"
)

for /d %%a in (*) do (
set "fnm=%~nxa"
 rem remove unwated tags
for %%G In (ddlvalley mkvhub cool net com [ ] me cc tfpdl www) do set "fnm=!fnm:%%G=!"
  rem replace dots and dash
for %%G In (. _ -) do set "fnm=!fnm:%%G= !"
  rem year in paranthesis
for %%G In (2017 2018 2019 2020 2021) do set "fnm=!fnm:%%G=(%%G)!"
  rem set changes
set "fnm=!fnm:5 1=5.1!"
set "fnm=!fnm:web dl=WEB-DL!"
  rem remove any spaces
for /F "Tokens=*" %%G In ("!fnm!") do set "nfnm=%%G"
 echo rename "%~nx1" "!nfnm!"
pause
 ren  "%~a" "!nfnm!"
@endlocal
)
Echo operation completed
pause
