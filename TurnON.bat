CHCP 1258 >nul 2>&1
CHCP 65001 >nul 2>&1
@echo off

::===========================================================================
title Battery Saver
mode con: cols=123 lines=35
chcp 65001 >nul
color f0
:main
cls
@echo ===========================================================
powercfg /setdcvalueindex SCHEME_CURRENT SUB_ENERGYSAVER ESBATTTHRESHOLD 100
powercfg /setactive scheme_current

::Add the name of the application to be disabled here.
TASKKILL /F /IM program.exe

exit