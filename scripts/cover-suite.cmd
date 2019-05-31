@ECHO OFF
SETLOCAL EnableDelayedExpansion
SET LOCAL_CONFIG=test-suite.nunit
SET SOURCE_CONFIG=tools\nunit\test-suite.nunit
SET DELETE_LOCAL_CONFIG_ON_CLEANUP=0
CALL "%~dp0VERSION" >NUL
FOR /F "tokens=* USEBACKQ" %%A IN (`"%~dp0\get" nunit-args`) DO ( 
  SET NUnitArgs=%%A
) 
CALL :EnsureFolders
CALL :EnsureConfig
CALL scripts\opencover "-register:user" "-target: %~dp0nunit3-console.cmd" "-targetargs: %NUnitArgs%" "-filter: +[*]*" "-hideskipped:All" "-output:%~dp0..\test\run\%VERSION%.opencover-result.xml" -log:All -enableperformancecounters 
CALL :Cleanup
EXIT /b

:EnsureFolders 
IF NOT EXIST "%~dp0..\test\run" ( MKDIR "%~dp0..\test\run" ) 
IF NOT EXIST "%~dp0..\test\report" ( MKDIR "%~dp0..\test\report" ) 
 
:EnsureConfig
IF NOT EXIST %LOCAL_CONFIG% (
  SET DELETE_LOCAL_CONFIG_ON_CLEANUP=1
  COPY "%SOURCE_CONFIG%" "%LOCAL_CONFIG%" >NUL
)
EXIT /b

:Cleanup
  IF %DELETE_LOCAL_CONFIG_ON_CLEANUP% EQU 1 (
	DEL %LOCAL_CONFIG% /Q /F
  ) 
EXIT /b