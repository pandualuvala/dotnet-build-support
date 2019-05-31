ECHO OFF
@SETLOCAL ENABLEDELAYEDEXPANSION
@CALL "%~dp0now" T1
ECHO [ %T1% ] RESTORING ...
CALL "%~dp0restore"
@CALL "%~dp0now" T2
ECHO [ %T2% ] ... RESTORED!  BUILDING ... 
CALL "%~dp0build-sln" "%~dp0..\build.proj"
@CALL "%~dp0now" T3
ECHO [ %T3% ] ... BUILT!  TESTING ... 
CALL "%~dp0cover-suite"
@CALL "%~dp0now" T4
ECHO [ %T4% ] ... TESTED!  REPORTING ... 
CALL "%~dp0report"
@CALL "%~dp0now" T5
ECHO [ %T5% ] ... REPORTED!  PACKING... 
CALL "%~dp0pack"
@CALL "%~dp0now" T6
ECHO [ %T6% ] ... PACKED!
