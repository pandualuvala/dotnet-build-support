@ECHO OFF
SETLOCAL EnableDelayedExpansion

:Main

CALL :RequireRepositoryScriptsFolder "%~0"
IF %ERRORLEVEL% NEQ 0 EXIT /b %ERRORLEVEL%

SET REPO_SCRIPTS=%~dp0
SET REPO=!REPO_SCRIPTS:^\scripts=!
SET MODULE=!REPO!modules\build-support\
SET MODULE_SCRIPTS=!MODULE!scripts
SET MODULE_TOOLS=!MODULE!tools
IF "\" NEQ "!MODULE_SCRIPTS:~-1!" SET MODULE_SCRIPTS=!MODULE_SCRIPTS!\

CALL :EnsureFolderExists "!REPO!scripts"
IF %ERRORLEVEL% NEQ 0 (
  EXIT /b
)

git submodule update --init --recursive

PUSHD !MODULE_SCRIPTS!
FOR %%E IN ( cmd config ) DO (
  FOR /R %%A IN ("*.%%E") DO (
    IF "%%~dpA" NEQ "%~dp0" ( 
      CALL :RequireSourceOrTarget "%%~A" "%~dp0%%~nxA"
      IF %ERRORLEVEL% NEQ 0 (
        POPD
        EXIT /b
      )
      ECHO SOURCE %%~nA
      ECHO LOCAL  %~n0
      IF "%%~nA" NEQ "%~n0" ( 
        CALL COPY /D /V /Y /B "%%~A" "%~dp0"
        CALL :EnsureGitIgnore "%~dp0%%~nxA"
      )
    ) 
  )
)
ECHO %PATH%|find /i "%~dp0">nul  || SET PATH=%PATH%;%~dp0%
POPD 

:EnsureData

CALL :EnsureFolderExists "!REPO!data"
IF %ERRORLEVEL% NEQ 0 (
  EXIT /b
)

IF NOT EXIST "!REPO!data\owner.txt" (
  IF NOT DEFINED OWNER (
    SET OWNER=%USERNAME%
  )
  >"!REPO!data\owner.txt": ECHO !OWNER!
) ELSE ( 
  SET /P OWNER=<"!REPO!data\owner.txt"
)

IF NOT EXIST "!REPO!data\product.txt" (
  IF NOT DEFINED PRODUCT (  
    FOR %%D in ( "%~dp0.." ) DO (
      ECHO CD=%%D
      FOR /F "USEBACKQ DELIMS=^- TOKENS=*" %%E IN ( `ECHO %%~nD` ) DO ( 
        SET PRODUCT=%%~E
      )
    )
  )
  ECHO PRODUCT=!PRODUCT!
  >"!REPO!data\product.txt": ECHO !PRODUCT!
) ELSE ( 
  SET /P OWNER=<"!REPO!data\product.txt"
)

IF NOT EXIST "!REPO!data\summary.txt" (
  IF NOT DEFINED SUMMARY (  
    FOR %%D in ( "%~dp0.." ) DO (
      SET SUMMARY=%%~nD is an instance of something that does some activity for someone in some context.
    )
  )
  >"!REPO!data\summary.txt": ECHO !SUMMARY!
) ELSE ( 
  SET /P OWNER=<"!REPO!data\summary.txt"
)




CALL :EnsureToolSupport "!MODULE_TOOLS!" msbuild "proj props targets"
IF %ERRORLEVEL% NEQ 0 (
  EXIT /b
)

CALL :EnsureToolSupport "!MODULE_TOOLS!" "nuget" "config"
IF %ERRORLEVEL% NEQ 0 (
  EXIT /b
)

CALL :EnsureToolSupport "!MODULE_TOOLS!" "gitversion" "yml"
IF %ERRORLEVEL% NEQ 0 (
  EXIT /b
)

CALL :EnsureToolSupport "!MODULE_TOOLS!" "nunit" "nunit"
IF %ERRORLEVEL% NEQ 0 (
  EXIT /b
)

CALL :SaveConsoleLaunchScript !REPO!

CALL :EnsureSharedAssemblyMetadata
EXIT /b 


:EnsureGitIgnore
  PUSHD !REPO!
  IF NOT EXIST "!REPO!.gitignore" (
    IF EXIST "!REPO!modules\build-support\tools\git\.gitignore" (
      CALL COPY /D /V /Y /B "!REPO!modules\build-support\tools\git\.gitignore" "!REPO!.gitignore"
    )
    IF %ERRORLEVEL% NEQ 0 (
      EXIT /b
    )
  )
  SET FILE_TO_IGNORE=%~1
  SET FILE_TO_IGNORE=!FILE_TO_IGNORE:%CD%=!
  SET FILE_TO_IGNORE=!FILE_TO_IGNORE:\=/!
  ECHO EnsureGitIgnore !FILE_TO_IGNORE!
  SET FOUND_GITIGNORE=0
  IF EXIST !REPO!.gitignore (
    FOR /F "TOKENS=*" %%A IN (!REPO!.gitignore) DO (
      IF "%%~A" EQU "!FILE_TO_IGNORE!" SET FOUND_GITIGNORE=1
    )
  )
  IF !FOUND_GITIGNORE! EQU 0 >>"!REPO!.gitignore": ECHO !FILE_TO_IGNORE!
  POPD
EXIT /b

:RequireSourceOrTarget
  SET SOURCE=%1
  SET TARGET=%2
  IF EXIST "!SOURCE!" (
    ECHO Source found @ '!SOURCE!'
  ) ELSE (
    ECHO Source folder not found @ '!SOURCE!' ...
    IF NOT EXIST "!TARGET!" (
      CALL "%~dp0error" 1 "'!SOURCE!' not found and cannot be copied to '!TARGET!'."
    ) ELSE (
      ECHO '!SOURCE!' not found so existing '!TARGET!' will be used.
    )
  )
EXIT /b

:RequireRepositoryScriptsFolder
  SET FOLDER=%~dp1
  SET SHOULD_BE_SCRIPTS=!FOLDER!
  SET SHOULD_BE_SCRIPTS=%SHOULD_BE_SCRIPTS:~-8%
  SET SHOULD_BE_SCRIPTS=!SHOULD_BE_SCRIPTS:^\=!
  IF "!SHOULD_BE_SCRIPTS!" NEQ "scripts" (
    FOR %%E IN ("!FOLDER!") DO (
      CALL "%~dp0error" 1 "%%~nxE must be run from the scripts folder inside the repository root.  The %%~nxE script was executed from %%~dpE."    
    )
  )
  IF NOT EXIST "!FOLDER!..\.git" (
    FOR %%E IN ("%FOLDER%") DO (
      CALL "%~dp0error" 1 "%%~nxE must be run from the scripts folder inside the repository root.  The %%~nxE was executed from a scripts folder but its parent !FOLDER:^\scripts=! does not look like a repository."
    )
  )
EXIT /b 

:SaveConsoleLaunchScript 
  IF EXIST "!REPO!" (
    > "!REPO!console.cmd": ECHO START "scripts | !REPO!" /D "!REPO!" CMD /E:ON /V:ON /F:ON /K
    CALL :EnsureGitIgnore "/console.cmd"
  )
EXIT /b

:EnsureFolderExists
  SET FOLDER=%~1
  ECHO Ensuring folder "%FOLDER%" 
  IF EXIST "%FOLDER%" (
    ECHO Found the folder "%FOLDER%"
  ) ELSE (
    ECHO Failed to find the folder "%FOLDER%"
    ECHO Creating folder "%FOLDER%"
    MKDIR "%FOLDER%"
    IF EXIST "%FOLDER%" ( 
      ECHO Created folder "%FOLDER%" 
    ) ELSE (
      CALL "%~dp0error" 1 "Failed to create missing folder '%FOLDER%'"
    )
  )

EXIT /b

:EnsureToolSupport
IF "%~1"=="" (
  CALL %~dp0error Did not ensure tool support because the source tools folder was not provided.
  EXIT /b
)
IF "%~2"=="" (
  CALL %~dp0error Did not ensure tool support because the tool's identifier was not provided.
  EXIT /b
)
IF "%~3"=="" (
  CALL %~dp0error Did not ensure tool support because the tool's included extension list was not provided.
  EXIT /b
) 
SET TOOLS=%~1
SET TOOL_ID=%~2
SET EXTLIST=%~3
CALL :EnsureFolderExists "!REPO!tools\%TOOL_ID%"
IF %ERRORLEVEL% NEQ 0 (
  EXIT /b
)
PUSHD "%~1" 
FOR %%E in (%EXTLIST%) DO (
    FOR /R %%A IN ("*.%%E") DO (
      CALL :RequireSourceOrTarget "%%~A" "!REPO!tools\%TOOL_ID%\%%~nxA"
      IF %ERRORLEVEL% NEQ 0 ( 
        POPD 
        EXIT /b
      ) ELSE (
	    IF NOT EXIST "!REPO!tools\%TOOL_ID%" (
          CALL COPY /D /V /Y /B "%%~A" "!REPO!tools\%TOOL_ID%"
		)
	IF %ERRORLEVEL% NEQ 0 (
	  POPD
	  EXIT /b
        )
	REM CALL :EnsureGitIgnore "!REPO!tools\%TOOL_ID%\%%~nxA"
	IF %ERRORLEVEL% NEQ 0 (
	  POPD
	  EXIT /b
	)
      )  
  )
)
POPD 
EXIT /b


:EnsureSharedAssemblyMetadata
SET ASSEMBLY_INFO_FILE=%~dp0..\SharedAssemblyInfo.cs
SET VERSION_INFO_FILE=%~dp0..\SharedVersionInfo.cs
CALL %~dp0version
FOR /F "USEBACKQ DELIMS=^-^. TOKENS=1-4" %%A IN (`CALL "%~dp0version"`) DO (
  SET MAJOR=%%A
  SET MINOR=%%B
  SET PATCH=%%C
  SET PRERELEASE=%%D
)
IF NOT EXIST "%VERSION_INFO_FILE%" (
  >"%VERSION_INFO_FILE%": ECHO using System.Reflection;
  FOR %%F IN ( Version FileVersion InformationalVersion ) DO (
    >>"%VERSION_INFO_FILE%": ECHO [assembly^: Assembly%%~F^("%MAJOR%.%MINOR%.%PATCH%"^)]
  )
)
IF NOT EXIST "%ASSEMBLY_INFO_FILE%" (   
  >"%ASSEMBLY_INFO_FILE%": ECHO using System.Reflection;
  FOR /F "USEBACKQ TOKENS=*" %%A IN ( `CALL "%~dp0get" summary` ) DO ( 
    >>"%ASSEMBLY_INFO_FILE%": ECHO [assembly^: AssemblyDescription^("%%A"^)]
  )
  FOR /F "USEBACKQ TOKENS=*" %%A IN ( `CALL "%~dp0get" product` ) DO ( 
    >>"%ASSEMBLY_INFO_FILE%": ECHO [assembly^: AssemblyProduct^("%%A"^)]
  )
  FOR /F "USEBACKQ TOKENS=*" %%A IN (`CALL "%~dp0get" owner`) DO (
    >>"%ASSEMBLY_INFO_FILE%": ECHO [assembly^: AssemblyCompany^("%%A"^)]
    >>"%ASSEMBLY_INFO_FILE%": ECHO [assembly^: AssemblyCopyright^("Copyright %DATE:~10% %%A"^)]
  )
  >>"%ASSEMBLY_INFO_FILE%": ECHO #if DEBUG
  >>"%ASSEMBLY_INFO_FILE%": ECHO [assembly^: AssemblyConfiguration^("Debug"^)]
  >>"%ASSEMBLY_INFO_FILE%": ECHO #else
  >>"%ASSEMBLY_INFO_FILE%": ECHO [assembly^: AssemblyConfiguration^("Release"^)]
  >>"%ASSEMBLY_INFO_FILE%": ECHO #endif 
)
EXIT /b
