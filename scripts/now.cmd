@ECHO OFF
REM https://stackoverflow.com/questions/203090/how-do-i-get-current-datetime-on-the-windows-command-line-in-a-suitable-format
FOR /F "TOKENS=2-4 DELIMS=/ " %%E IN ('DATE /T') DO (
  FOR /F "TOKENS=1-3 DELIMS=/: " %%U IN ('TIME /T') DO ( 
    IF "%~1" NEQ "" (
  	  CALL SET "%~1=%%G%%E%%FT%%U%%V%%W"
	) ELSE (
	  ECHO %%G%%E%%FT%%U%%V%%W
    )
  )
)