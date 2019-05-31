@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET KEY=%~1

IF "%KEY%" EQU "" (
  GOTO Help
) ELSE (
  GOTO %KEY%
)
IF %ERRORLEVEL% NEQ 0 GOTO Help

EXIT /b 

:Help 
  ECHO enter a command:
  FOR /F "usebackq tokens=*" %%C IN (`CALL "%~dp0labels" "%~dpnx0" ^| SORT`) DO (
    ECHO  * %%C
  )
EXIT /b

:Root
FOR %%G IN ("%~dp0..\") DO @ECHO %%~fG
EXIT /b 

:Branch
FOR /F USEBACKQ %%G IN (`git branch ^| grep \* ^| cut -d ' ' -f2`) DO ( ECHO %%G )
EXIT /b

:Branches
FOR /F "USEBACKQ DELIMS=* " %%G IN (`git branch --all`) DO ( ECHO %%G )
EXIT /b

:Commands
CALL "%~dp0labels" "%~dpnx0" | SORT
EXIT /b 

:Configuration
FOR /F %%G IN ('%~dp0get branch') DO SET BRANCH=%%G
SET CONFIGURATION=
IF "!BRANCH:~0,7!" EQU "release" ( 
  SET CONFIGURATION=Release
) ELSE IF "!BRANCH:~0,6!" EQU "master" (
  SET CONFIGURATION=Release
) ELSE (
  SET CONFIGURATION=Debug
)
ECHO !CONFIGURATION!
EXIT /b

:NUnit-Args
  SETLOCAL EnableDelayedExpansion
  SET VERSIONFILE="%~dp0..\version.txt"
  CALL :Version > %VERSIONFILE%
  SET /P VERSION=<%VERSIONFILE%
  DEL %VERSIONFILE%
  FOR /F %%G IN ('%~dp0get configuration') DO SET CONFIGURATION=%%G
  ECHO "%~dp0..\test-suite.nunit" --framework=v4.0 --trace=Verbose --labels=ALL --work=%~dp0..\test\run --config=!CONFIGURATION! "--result=%VERSION%.nunit-result.xml;format=nunit3" --out=%VERSION%.nunit-out.log
  ENDLOCAL
EXIT /b

:NuSpecs
  FOR %%G IN (source test) DO (
    PUSHD %~dp0..\%%G 
	FOR /R %%H IN (*.nuspec) DO (
	  ECHO %%~H
	)
	POPD 
  )
EXIT /b

:Packages
  DIR "%~dp0..\packages" /B
EXIT /b 

:Reports
>reports.txt: DIR /O:-D /B "%~dp0..\test\report"
SET /P LATEST_REPORT=<reports.txt
DEL reports.txt 
PUSHD "%~dp0..\test\report\!LATEST_REPORT!"
DIR index.htm* /b /s
POPD
EXIT /b

:Source
  TREE "%~dp0..\source" /F /A
EXIT /b 

:Scripts
  DIR "%~dp0..\scripts" /B
EXIT /b 

:Test
  TREE "%~dp0..\test" /F /A
EXIT /b 

:Tools
  FOR /D %%A IN ( %~dp0..\packages\* ) DO (
    FOR %%B IN ( %%A\tools\*.exe ) DO ( 
	    ECHO packages\%%~nxA\tools\%%~nxB
	  ) 
  )
  DIR "%~dp0..\tools" /B
EXIT /b 

:Version
  CALL "%~dp0version"
EXIT /b

:Owner
   IF EXIST "%~dp0..\data\owner.txt" (
    TYPE "%~dp0..\data\owner.txt" 
   ) ELSE (
    ECHO TACTICTEC 
   )
   EXIT /b

:Summary
   IF EXIST "%~dp0..\data\summary.txt" TYPE "%~dp0..\data\summary.txt"
   EXIT /b

:Product
   IF EXIST "%~dp0..\data\product.txt" TYPE "%~dp0..\data\product.txt"
   EXIT /b
   