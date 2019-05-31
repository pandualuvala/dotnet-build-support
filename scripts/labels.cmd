@ECHO OFF
SETLOCAL EnableDelayedExpansion
IF "%~1" EQU "" (
  ECHO Path missing. 1>&2
    EXIT /b 1
) ELSE (
  IF NOT EXIST "%~1" (
    ECHO Path was not found: "%~1". 1>&2
    EXIT /b 1
  ) ELSE (
    SET LINE=NONE
    FOR /F "usebackq tokens=*" %%A IN (`type "%~1"`) DO (
    	SET LINE=%%A
    	IF "!LINE:~0,1!" EQU ":" (
    		ECHO !LINE:~1!
    	)
    )
    IF "LINE" EQU "NONE" (
        ECHO No labels found in "%~1"
    )
  )
)