@ECHO OFF
SETLOCAL EnableDelayedExpansion

CALL nuget restore "%~dp0packages.config" -source https://api.nuget.org/v3/index.json -ConfigFile "%~dp0..\tools\nuget\NuGet.config" -PackagesDirectory "%~dp0..\packages" >NUL

SET PACKAGE=%~1
SET TOOL=%~2
FOR /f "tokens=2,* delims= " %%A IN ("%*") DO ( SET TOOL_ARGS=%%B )

CALL :FindExe
IF %ERRORLEVEL% NEQ 0 ( EXIT /b )
CALL :Run
EXIT /b
:FindExe
FOR /F "USEBACKQ TOKENS=*" %%G IN (`DIR /B "%~dp0..\packages\%PACKAGE%*"`) DO (
  FOR /F "USEBACKQ TOKENS=*" %%H IN (`DIR /B /S "%~dp0..\packages\%%~G\tools\*%TOOL%.exe"`) DO (
    SET EXE=%%~H
    EXIT /b
  )
  CALL "%~dp0error" 1 "%TOOL%.exe tool not found in %PACKAGE%."
  EXIT /b
)
CALL "%~dp0error" 1 "%PACKAGE% package not found.  It should be included in scripts/packages.config"
EXIT /b

:Run
  ECHO "%EXE%" %TOOL_ARGS%
  CALL "%EXE%" %TOOL_ARGS%
EXIT /b