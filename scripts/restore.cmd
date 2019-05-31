@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
PUSHD %~dp0..

SET ROOT=%CD%\

SET COPIED=
IF NOT EXIST NuGet.config (
  COPY tools\nuget\NuGet.config NuGet.config
  SET COPIED=1
) ELSE (
  SET COPIED=
)

CALL nuget restore -ConfigFile NuGet.config -OutputDirectory packages

IF DEFINED COPIED (
  DEL NuGet.config
)

ENDLOCAL