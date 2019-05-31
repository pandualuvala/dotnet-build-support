@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

IF "%~1" EQU "help" (
  CALL :Help
  EXIT /B
) ELSE IF "%~1" EQU "test" (
  CALL :TestScript
  EXIT /B
) ELSE IF "%~1" EQU "" (
  CALL :Error "file cannot be blank!"
  EXIT /B
) ELSE IF "%~2" EQU "" (
  CALL :Error "oldstring cannot be blank!"
  EXIT /B
) ELSE IF "%~3" EQU "" (
  CALL :Warn "newstring is blank.  command will remove occurrences of '%~2'."
)

:Substitution
SET FILE=%~1
SET OLDSTRING=%~2
SET NEWSTRING=%~3
CALL powershell [System.IO.File]::WriteAllText('!FILE!', [System.IO.File]::ReadAllText('!FILE!').Replace('!OLDSTRING!','!NEWSTRING!'))
EXIT /B 0

:Warn 
ECHO.
ECHO WARN:  %~1
EXIT /B 0

:Error
ECHO.
ECHO ERROR: %~1
ECHO.
CALL :Help
EXIT /B 1

:TestScript
ECHO if exist "test message file" ( del "test message file" )
ECHO echo Hello World^>"test message file" 
ECHO type "test message file"
ECHO call substitute "test message file" "Hello" "Goodnight" 
ECHO call substitute "test message file" "World" "Moon" 
ECHO type "test message file"
ECHO del "test message file"
EXIT /B 0

:Help
ECHO    .--[ SUBSTITUTE ]----------------------------------------.
ECHO   /                                                          \
ECHO  ^| id:                                                      ^| 
ECHO  ^|   substitute                                             ^| 
ECHO  ^| type:                                                    ^| 
ECHO  ^|   Command                                                ^| 
ECHO  ^| description:                                             ^| 
ECHO  ^|   substitute an oldstring for a newstring in a file      ^| 
ECHO  ^| arguments:                                               ^| 
ECHO  ^|   - file                                                 ^| 
ECHO  ^|   - oldstring                                            ^| 
ECHO  ^|   - newstring                                            ^| 
ECHO  ^| syntax:                                                  ^| 
ECHO  ^|   - substitute file oldstring newstring                  ^| 
ECHO  ^|   - substitute "file path" "old string" "new string"     ^|
ECHO    \_________________________________________________________/ 
ECHO.
ECHO  * Example Usage:
ECHO.
ECHO          ^|---^|-----------------------------------------------.
ECHO          ^|IN ^|-----------------------------------------------^<
ECHO    given ^| 1 ^| ^>"message file": echo Hello World             ^|
ECHO    when  ^| 2 ^| substitute "message file" "Hello" "Goodnight" ^|
ECHO          ^| 3 ^| substitute "message file" "World" "Moon"      ^|
ECHO    then  ^| 4 ^| type "message file"                           ^|
ECHO          ^|OUT^|-----------------------------------------------^<
ECHO          ^| 5 ^| Goodnight Moon                                ^|
ECHO          ^|---^|-----------------------------------------------'                			  
EXIT /B