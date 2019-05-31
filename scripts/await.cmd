@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
FOR /F "USEBACKQ TOKENS=2 DELIMS=," %%A IN (`TASKLIST ^/NH ^/V ^/FO CSV ^/FI "WINDOWTITLE eq %~1" 2^>^&1`) DO (
  SET PID=%%~A
)
SET INTERVAL=%~2
IF NOT DEFINED INTERVAL ( SET INTERVAL=1 )
CALL :Await
EXIT /b

:Await
ECHO awaiting !PID! for !INTERVAL!s @ %TIME%
FOR /F "USEBACKQ TOKENS=1 DELIMS=," %%A IN (`TASKLIST ^/NH ^/V ^/FO CSV ^/FI "PID eq !PID!" 2^>^&1`) DO (
  IF "%%~A" NEQ "INFO: No tasks are running which match the specified criteria." (
    TIMEOUT /T !INTERVAL!
    GOTO :Await
  ) ELSE (
    ECHO done awaiting @ %TIME%
	EXIT /b
  )
)