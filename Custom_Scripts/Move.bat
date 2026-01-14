@echo on
title Move File into folder
md "%~n1"
move %1 "%~n1"
