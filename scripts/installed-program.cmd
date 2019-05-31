@ECHO OFF 
SETLOCAL ENABLEDELAYEDEXPANSION

SET PROGRAM=%~1

FOR /f "tokens=1,* delims= " %%A in ("%*") DO (
  SET ARGS=%%B
)

FOR %%A IN (%PROGRAM%.exe) DO ( 
  IF "%%~$PATH:A" NEQ "" ( 
    SET EXE=%%~$PATH:A
	CALL :Run
	EXIT /b
  ) ELSE ( 
    FOR %%B IN ( "%PROGRAMFILES(X86)%" "%PROGRAMFILES%" "%PROGRAMDATA%" ) DO (
	  IF EXIST "%%~B" (
	    PUSHD "%%~B"
	    FOR /F "USEBACKQ TOKENS=*" %%C IN (`DIR /B /S *%PROGRAM%.exe`) DO ( 
		  SET EXE=%%~C
			POPD
	    CALL :Run
		  EXIT /b
	    )
	    POPD
	  )
	)
  )
)

:Run
  IF EXIST "!EXE!" (
    CALL "!EXE!" %ARGS%
  ) ELSE (
    CALL "%~dp0error" 404 "%PROGRAM% not found."    
  )
EXIT /b