@ECHO OFF
SETLOCAL EnableDelayedExpansion

SET SCRIPT_FILE=%~0
SET SOURCE_FOLDER=%~1
SET ARCHIVE_FOLDER=data\archives
SET ARCHIVE=it
SET PERCENT=%%
SET ENCODED_BACKSLASH=%PERCENT%5C
SET BACKSLASH_CONVENTION=__

:Main
  PUSHD %~dp0..
  CALL :Log Main "--CD=%CD% --SOURCE_FOLDER=!SOURCE_FOLDER! --ARCHIVE_FOLDER=!ARCHIVE_FOLDER!"
  CALL :Run FindSourceFolderPath  "!SOURCE_FOLDER!"
  CALL :Run FindTargetArchivePath """!SOURCE_FOLDER!"" ""!ARCHIVE_FOLDER!"""
  ECHO !ARCHIVE!
  CALL :Run CreateTargetArchive """!SOURCE_FOLDER!\*"" ""!ARCHIVE!"""
  CALL :Run DeleteSourceFolder "!SOURCE_FOLDER!"
  POPD
EXIT /B

:Log
  SET LOG_SCOPE=%~1
  SET LOG_MESSAGE=%~2
  ECHO [ !SCRIPT_FILE! ^:!LOG_SCOPE! ] !LOG_MESSAGE!
EXIT /B

:Run
  ECHO RUN %*
  IF %ERRORLEVEL% NEQ 0 (
    CALL :Log Run "--proc=%~1 --event=failure --reason=""The session is in an error state."" --error=%ERRORLEVEL%" >&2
  ) ELSE (
    CALL :Log Run "--proc=%~1 --event=start %~2"
    CALL :%~1 %~2
	CALL :Log Run "--proc=%~1 --event=done"
  )
EXIT /B

:FindSourceFolderPath
  SET SOURCE_FOLDER=%~1
  IF "!SOURCE_FOLDER!" EQU "" (
    CALL :Log FindSourceFolderPath "No source was provided." >&2
    CALL :Log FindSourceFolderPath "Example Usage:  archive-folder ""test\report"""
    EXIT /B 1
  ) ELSE IF NOT EXIST "!SOURCE_FOLDER!" (
    CALL :Log FindSourceFolderPath "No matching folder was found at !SOURCE_FOLDER!." >&2
    CALL :Log FindSourceFolderPath "Example Usage:  archive-folder ""test\report"""
    EXIT /B 1
  ) ELSE (
    CALL :Log FindSourceFolderPath "SOURCE_FOLDER @ !SOURCE_FOLDER!"	
    EXIT /B 
  )

:FindTargetArchivePath
  SET SOURCE_FOLDER=%~1
  SET ARCHIVE_FOLDER=%~2
  SET ENCODED_SOURCE_FOLDER=!SOURCE_FOLDER:\=%BACKSLASH_CONVENTION%!
  CALL :Log FindTargetArchivePath "ARCHIVE_FOLDER @ !ARCHIVE_FOLDER!"
  FOR /F "TOKENS=*" %%V IN ('scripts\version') DO (
    SET ARCHIVE=%~2\!ENCODED_SOURCE_FOLDER!.%%V-prerelease.zip
  )
  SET ARCHIVE=!ARCHIVE!
  ECHO "ARCHIVE @ !ARCHIVE!"
  CALL :Log FindTargetArchivePath "ARCHIVE @ !ARCHIVE!"
EXIT /B 

:CreateTargetArchive
  SET SOURCE=%~1
  SET SOURCE=!SOURCE:"=!
  SET TARGET=%~2
  SET TARGET=!TARGET:"=!
  SET OPTIONS=-aou -r -tzip

  SET COMMAND=7za a !OPTIONS! "!TARGET:%BACKSLASH_CONVENTION%=%ENCODED_BACKSLASH%!" "!SOURCE!"
  SET COMM
  CALL :Log CreateTargetArchive "!COMMAND!"
  FOR /F "USEBACKQ TOKENS=*" %%G IN (`CALL !COMMAND!`) DO (
    CALL :Log CreateTargetArchive "7za: %%~G"
  )
  IF NOT EXIST !TARGET! (
    CALL :Log CreateTargetArchive "Archival failed because the folder archive was not created." >&2
    EXIT /B 1
  )
EXIT /B 

:DeleteSourceFolder
  SET SOURCE=%~1
  CALL :Log DeleteSourceFolder "SOURCE=!SOURCE!"
  IF EXIST "!SOURCE!" (
    CALL :Log DeleteSourceFolder "RMDIR ""!SOURCE!"" /q /s"
	CALL RMDIR "!SOURCE!" /q /s 
  )
  CALL :Log DeleteSourceFolder "MKDIR ""!SOURCE!"""
  CALL MKDIR "!SOURCE!"
EXIT /B

