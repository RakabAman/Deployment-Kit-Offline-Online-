@echo off
Rem rename ddlvalley extra to required string to remove
setlocal enableDelayedExpansion
title Rename Folder - remove unwanted tags
echo Change name for Sure, close dialog for cancel

set "fnm=%~nx1"

 rem remove unwated tags
for %%G In (ddlvalley mkvhub .cool .net .com [ ] .me .cc tfpdl www) do set "fnm=!fnm:%%G=!"
 
 rem replace dots and dash
for %%G In (. _ -) do set "fnm=!fnm:%%G= !"
 
 rem year in paranthesis
for %%G In (2016 2015 2017 2018 2019 2020 2021 2022 2023) do set "fnm=!fnm:%%G=(%%G)!"


For /f "delims=," %%G in ('
  Powershell -NoP -C "(Get-Culture).TextInfo.ToTitleCase($env:fnm)"
') do set "fnm=%%G"

 rem set changes
set "fnm=!fnm:5 1=5.1!"
set "fnm=!fnm:web dl=WEB-DL!"
 
 rem remove any spaces
for /F "Tokens=*" %%G In ("!fnm!") do set "nfnm=%%G"
 echo rename "%~nx1" "!nfnm!"
pause
 ren  "%~1" "!nfnm!"
@endlocal