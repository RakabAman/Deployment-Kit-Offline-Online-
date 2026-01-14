@echo on
Rem rename ddlvalley extra to required string to remove
setlocal ENABLEDELAYEDEXPANSION

 set "fnm=%%~na"
 set "nfnm=!fnm:.= !"
 set "nfnm2=!nfnm:ddlvalley=!"
 set "nfnm3=!nfnm2:cool=!"
 set "nfnm4=!nfnm3:mkvhub=!"
 set "nfnm5=!nfnm4:net=!"
 set "nfnm6=!nfnm5:com=!"
 set "nfnm7=!nfnm6:ddlvalley= !"
 set "nfnm8=!nfnm7:ddlvalley=!"
 set "nfnm9=!nfnm8:ddlvalley=!"
 set "nfnm10=!nfnm9:ddlvalley=!"

 rem remove echo if everything looks ok
 echo ren "%%a" "!nfnm10!%%~xa"


pause
