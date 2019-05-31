@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
@FOR %%G IN ("%~dp0..") DO SET ROOT=%%~fG
SET FILE=!ROOT!\SharedVersionInfo.cs
SET ROOT 
SET FILE 
CALL "%~dp0gitversion" "!ROOT!" /updateassemblyinfo "!FILE!"
CALL %~dp0substitute "!FILE!" "/" "."
