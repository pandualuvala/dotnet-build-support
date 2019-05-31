SETLOCAL

CALL "%~dp0\version"

SET RUN_DIR=%~dp0..\test\run
SET REPORT_DIR=%~dp0..\test\report\%VERSION%

:Full
  CALL :EnsureFolders
  CALL :TestResultsReport
  CALL :TestCoverageReport
EXIT /b

:EnsureFolders
  IF NOT EXIST "%REPORT_DIR%" MKDIR "%REPORT_DIR%"
  IF NOT EXIST "%REPORT_DIR%\test" MKDIR "%REPORT_DIR%\test"
  IF NOT EXIST "%REPORT_DIR%\cover" MKDIR "%REPORT_DIR%\cover"
EXIT /b

:TestResultsReport
  CALL "%~dp0reportunit" "%RUN_DIR%" "%REPORT_DIR%\test"
  COPY "%RUN_DIR%\%VERSION%.nunit-result.xml" "%REPORT_DIR%\test\result.xml"
EXIT /b

:TestCoverageReport
  CALL "%~dp0reportgenerator" "-reports:%RUN_DIR%\%VERSION%.opencover-result.xml" "-targetdir:%REPORT_DIR%\cover"
  COPY "%RUN_DIR%\%VERSION%.opencover-result.xml" "%REPORT_DIR%\cover\data.xml"
EXIT /b
