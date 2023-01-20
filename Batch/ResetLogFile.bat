if EXIST %File_Log% (del %File_Log%)
if EXIST %File_ErrLog% (del %File_ErrLog%)

(set Msg=%JobName% started in %COMPUTERNAME% on %StartDate% at %StartTime%.) & (call %Script_DisplayMsg%)
(set Msg=Working script: ScriptName %ScriptVersion%)                         & (call %Script_DisplayMsg%)
(set Msg=User: %username%)                                                   & (call %Script_LogMsg%)