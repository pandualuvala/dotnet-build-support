@FOR /F %%G IN ('dir /B /O:-D *.log') DO @( ECHO %%G && TYPE %%G && EXIT /B 0 )
