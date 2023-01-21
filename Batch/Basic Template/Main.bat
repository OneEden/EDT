@echo off
setlocal
rem ********************Begin Comment********************
rem 
rem      This is the entry batch of the tool package
rem 
rem ******************** End Comment ********************

rem ### Set default script parameters. These are used in other scripts. 
set Script_LogMsg=LogMsg.bat
set Script_DisplayMsg=DisplayMsg.bat
set Script_ErrorHandler=ErrorHandler.bat
set JobName=JobName
set StartDate=%DATE%
set StartTime=%TIME%
set StartTimeString=%date:~6,4%-%date:~0,2%-%date:~3,2%-%time:~0,2%-%time:~3,2%-%time:~6,2%
set ScriptName=%~f0
set ScriptVersion=0.1
set ErrMsg=Undefined Error message
set Msg=
set File_Log=%JobName%-%StartTimeString%.log
set File_ErrLog=ERR_%JobName%-%StartTimeString%.log

call ResetLogFile.bat

rem #


:EXIT

endlocal
pause
@echo on