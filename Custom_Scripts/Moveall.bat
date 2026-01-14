@echo on
title Move all files into Folder
for %%f in (*) do (
  md "%%~nf"
  move "%%f" "%%~nf"
) >nul 2>&1