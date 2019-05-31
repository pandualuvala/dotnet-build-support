@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
ECHO query:
ECHO   filepath: 
ECHO     '%~dpnx0'
ECHO   arguments:
ECHO     - name: 
ECHO         'searchName'
ECHO       value: 
ECHO         '%~1'
ECHO     - name: 
ECHO         'searchPattern'
ECHO       value: 
ECHO         '%~2'
ECHO %~1:
FOR /R %%C IN ("%~2") DO (
ECHO(
ECHO   - filepath: 
ECHO       '%%C'
ECHO     drive: 
ECHO       '%%~dC'
ECHO     relativePath: 
ECHO       '%%~pC'
ECHO     name: 
ECHO       '%%~nC'
ECHO     extension: 
ECHO       '%%~xC'
SET LINE=0
ECHO     lines: 
FOR /F "USEBACKQ TOKENS=*" %%L IN (`type "%%C"`) DO ( 
SET /A LINE+=1
SET NUMBER=!LINE!
CALL :FormatNumber
SET TEXT=%%~L
SET TEXT=!TEXT:'=''!
ECHO       - { Line: !NUMBER!, Text: '!TEXT!'}
)
)
EXIT /B

:FormatNumber
IF "!NUMBER!" EQU "" (
  EXIT /B 1
) 
IF "!NUMBER:~3,1!" EQU "" (
  SET NUMBER=0!NUMBER!
  CALL :FormatNumber
  EXIT /B
)
EXIT /B
