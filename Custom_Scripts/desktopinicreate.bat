@echo off


for /r %%I in (*.ico) do (
    attrib -r -s "%%~dpI." /S /D 

    if exist %%~dpIdesktop.ini (
        del "%%~dpIdesktop.ini"
    ) 
    >>%%~dpIdesktop.ini echo [.ShellClassInfo]
    >>%%~dpIdesktop.ini echo IconResource="%%~nI%%~xI",0

    attrib -h desktop.ini /S
    attrib +r -s "%%~dpI." /S /D        
)