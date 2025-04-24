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
@echo =======================================================================

powercfg /setdcvalueindex SCHEME_CURRENT SUB_ENERGYSAVER ESBATTTHRESHOLD 0
powercfg /setactive scheme_current
powercfg /setdcvalueindex SCHEME_CURRENT SUB_ENERGYSAVER ESBATTTHRESHOLD 20
powercfg /setactive scheme_current

::Add the link to reopen the application here.
start "program.exe" "the link\program.exe" 

exit