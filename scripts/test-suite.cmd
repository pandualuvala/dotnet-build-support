@ECHO OFF
SETLOCAL
SET LOCAL_CONFIG=%~dp0..\test-suite.nunit
SET SOURCE_CONFIG=%~dp0..\tools\nunit\test-suite.nunit
SET DELETE_LOCAL_CONFIG_ON_CLEANUP=0

CALL %~dp0VERSION
>nunit-args.txt: powershell (scripts\get nunit-args).Replace('\"--result','--result').Replace(';format=nunit3\"', ';format=nunit3')
SET /P NUnitArgs=<nunit-args.txt
DEL nunit-args.txt
CALL :EnsureConfig
CALL "%~dp0nunit3-console" %NUnitArgs%
CALL :Cleanup
EXIT /B


:EnsureFolders
IF NOT EXIST "%~dp0..\test\run" ( MKDIR "%~dp0..\test\run" )
IF NOT EXIST "%~dp0..\test\report" ( MKDIR "%~dp0..\test\report" )

:EnsureConfig
IF NOT EXIST "%LOCAL_CONFIG%" (
  SET DELETE_LOCAL_CONFIG_ON_CLEANUP=1
  COPY "%SOURCE_CONFIG%" "%LOCAL_CONFIG%"
)
EXIT /b

:Cleanup
  IF %DELETE_LOCAL_CONFIG_ON_CLEANUP% EQU 1 (
	DEL %LOCAL_CONFIG% /Q /F
  ) 
EXIT /b