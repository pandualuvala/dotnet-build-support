@ECHO OFF
CALL "%~dp0nuget-package-tool" "OpenCover" "OpenCover.Console" %*
EXIT /B