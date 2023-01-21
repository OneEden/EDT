@echo off

rem # Main Structure
setlocal

rem ## set default value of parameters
set Param_A=0
set Param_B=0

rem ## argument parsing

:loop
if NOT "%~1"=="" (
    rem ### -a for function with parameter
    if "%~1"=="-a" (
        call :JOB_A %~2
        shift
    )
    rem ### -b for function without parameter
    if "%~1"=="-b" (
        call :JOB_B
    )
    shift
    goto :loop
)
goto :EXIT
rem # Functions
rem ## arguments with parameter
:JOB_A
echo Get command -a with %1
EXIT /B 0

rem ## arguments without parameter
:JOB_B
echo Get command -b
EXIT /B 0

:EXIT
endlocal
pause
@echo on