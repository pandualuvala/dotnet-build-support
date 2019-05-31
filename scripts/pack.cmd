@ECHO OFF
SETLOCAL EnableDelayedExpansion

FOR %%G IN (ROOT VERSION CONFIGURATION) DO (
  FOR /F USEBACKQ %%F IN (`"%~dp0get" %%G`) DO SET "%%G=%%F"
)

IF NOT EXIST "!ROOT!NuGet.config" ( COPY "!ROOT!tools\nuget\NuGet.config" "!ROOT!NuGet.config" )

FOR /F USEBACKQ %%G IN (`"%~dp0get" nuspecs`) DO ( 
  SET FOLDER=%%~dpG
  IF "!FOLDER:~-1!" EQU "\" (
    SET FOLDER=!FOLDER:~0,-1!
  )
  ECHO nuget pack "!FOLDER!" -Version !VERSION! -ConfigFile "!ROOT!NuGet.config" -OutputDirectory "!ROOT!build" -Symbols -Properties Configuration=!CONFIGURATION!;SolutionDir=!ROOT!
  CALL nuget pack "!FOLDER!" -Version !VERSION! -ConfigFile "!ROOT!NuGet.config" -OutputDirectory "!ROOT!build" -Symbols -Properties Configuration=!CONFIGURATION!;SolutionDir=!ROOT!
)
EXIT /b

