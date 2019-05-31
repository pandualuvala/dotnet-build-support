@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION  

  SET FRAMEWORK=net452
  SET PACKAGE_FRAMEWORKS=net452 net451 net45 net40 net35 net20
  SET REPOS=https://github.com/thegoldcube
  SET COMMON_PACKAGES=log4net@2.0.8
  SET COMMON_FRAMEWORK_DLLS=mscorlib System System.Core

  IF "%~1" EQU "count" (
    SET SUBCOMMAND=^:Count
  ) ELSE IF "%~1" EQU "list" (
    SET SUBCOMMAND=^:List
  ) ELSE IF "%~1" EQU "create" (
    SET SUBCOMMAND=^:Create
  ) ELSE (
    CALL "%~dp0error" 1 "'%~1' is not a valid subcommand.  Use one of: count; list; or, create."
    EXIT /b
  )
  IF "%~2" EQU "cs" (
    SET PROJECT_TYPE=FAE04EC0-301F-11D3-BF4B-00C04F79EFBC
    SET ASSEMBLY_INFO_FILE=Properties\AssemblyInfo.cs
    SET ASSEMBLY_INFO_CONTENT=[assembly^: System.Reflection.AssemblyTitle^("NAME"^)]
  ) ELSE IF "%~2" EQU "fs" (
    SET PROJECT_TYPE=F2A71F9B-5D33-465A-A702-920D77279786
    SET ASSEMBLY_INFO_FILE=AssemblyInfo.fs
    SET ASSEMBLY_INFO_CONTENT=[^<assembly^: System.Reflection.AssemblyTitle^("NAME"^)^>]
  ) ELSE IF "%~2" EQU "vb" (
    SET PROJECT_TYPE=F184B08F-C81C-45F6-A57F-5ABD9991F28F
    SET ASSEMBLY_INFO_FILE=My Project\AssemblyInfo.vb
    SET ASSEMBLY_INFO_CONTENT=^<Assembly^: System.Reflection.AssemblyTitle^("NAME"^)^>
  ) ELSE IF "%~2" EQU "dir" (
    SET PROJECT_TYPE=2150E333-8FDC-42A3-9474-1A3956D46DE8
    IF "%~1" EQU "create" (
      CALL "%~dp0error" 1 "Cannot create solution folder because MSBuild solution folders are not bound to the file system."
      EXIT /b
    )
  ) ELSE (
    CALL "%~dp0error" 1 "'%~2' is not a valid project type.  Use one of: cs; vb; fs; or, dir."
    EXIT /b
  )

  IF "%~3" EQU "" (
    CALL "%~dp0error" 1 "'%~3' is not a valid solution path because it is blank.  Use an existent file with a .sln extension."
    EXIT /b
  )
  IF "%~x3" NEQ ".sln" (
    CALL "%~dp0error" 1 "'%~3' is not a valid solution path because it has the wrong extension.  Use an existent file with a .sln extension."
    EXIT /b
  ) 
  IF NOT EXIST "%~3" (
    CALL "%~dp0error" 1 "'%~3' was not found.  Use a solution path for an existent file."
    EXIT /b
  )
  SET SOLUTION_PATH=%~3
  SET SOLUTION_DIR=%~dp3
  
  
:Main
  CALL !SUBCOMMAND! "!PROJECT_TYPE!" "!SOLUTION_PATH!"
EXIT /b

:List
  SET PROJECT_TYPE=%~1
  SET SOLUTION_PATH=%~2
  FOR /F "USEBACKQ TOKENS=1-30 DELIMS=^=,{}() " %%G IN (`type "!SOLUTION_PATH!"`) DO (
    IF "%%~I" EQU "%PROJECT_TYPE%" (
      ECHO %%~L=%%~N
    )
  )
EXIT /b

:Count
  SET PROJECT_TYPE=%~1
  SET SOLUTION_PATH=%~2
  SET /A COUNT=0
  FOR /F "USEBACKQ TOKENS=1-30 DELIMS=^=,{}() " %%G IN (`type "!SOLUTION_PATH!"`) DO (
    IF "%%~I" EQU "%PROJECT_TYPE%" (
      SET /A COUNT+=1
    )
  )
  ECHO !COUNT!
EXIT /b

:FindPackageFramework
  SET PACKAGE_ID=%~1
  SET PACKAGE_VERSION=%~2
  SET PACKAGE_LIB_FOLDER=!SOLUTION_DIR!packages\!PACKAGE_ID!.!PACKAGE_VERSION!\lib
  SET PACKAGE_FRAMEWORK=
  PUSHD !PACKAGE_LIB_FOLDER!
  FOR %%A IN (!FRAMEWORK! !PACKAGE_FRAMEWORKS!) DO (
    IF EXIST "!PACKAGE_LIB_FOLDER!\%%~A" (
	  SET PACKAGE_FRAMEWORK=%%~A
	  POPD
	  EXIT /b
	)
	IF EXIST "!PACKAGE_LIB_FOLDER!\%%~A*" (
	  ECHO FOR /D %%B IN ("!PACKAGE_LIB_FOLDER!\%%~A*")
	  FOR /D %%B IN ("!PACKAGE_LIB_FOLDER!\%%~A*") DO (
	    SET PACKAGE_FRAMEWORK=%%~nB
	    POPD
	    EXIT /b
	  )	  
	)
  )
  POPD
EXIT /b

:FindPackageReferences
  SET PACKAGE_REFERENCES=
  SET PACKAGE=%~1
  
  IF "!PACKAGE!" EQU "" (
    CALL "%~dp0error" 1 ":FindPackageReferences was called without the required PACKAGE parameter."
    EXIT /b
  )
  
  FOR /F "TOKENS=1,2 DELIMS=@" %%G IN ("!PACKAGE!") DO (
    SET PACKAGE_ID=%%~G
    SET PACKAGE_VERSION=%%~H
	
    CALL :FindPackageFramework !PACKAGE_ID! !PACKAGE_VERSION!
    
    SET LIB_FOLDER=!SOLUTION_DIR!packages\!PACKAGE_ID!.!PACKAGE_VERSION!\lib\
    IF "!PACKAGE_FRAMEWORK!" EQU "" ( 
      CALL "%~dp0error" 1 ":FindPackageFramework found no compatible framework in !LIB_FOLDER!"
      EXIT /b
    ) ELSE ( 
      SET LIB_FOLDER=!LIB_FOLDER!!PACKAGE_FRAMEWORK!\
    )
    SET DLL_FOUND=
    PUSHD "!LIB_FOLDER!"
    FOR /F "TOKENS=*" %%I IN ('DIR /b *.dll') DO (
      SET PACKAGE_REFERENCE=!LIB_FOLDER!%%~I
      IF DEFINED PACKAGE_REFERENCES (
        SET PACKAGE_REFERENCES=!PACKAGE_REFERENCES! "!PACKAGE_REFERENCE!"   
      ) ELSE (
        SET PACKAGE_REFERENCES="!PACKAGE_REFERENCE!"
      )
      SET PACKAGE_REFERENCE=
    )
    POPD
    SET LIB_FOLDER=
  )
  SET PACKAGE=
EXIT /b

:Create
  
  FOR %%B IN ("%COMMON_PACKAGES: =" "%") DO (
    FOR /F "TOKENS=1,2 DELIMS=@" %%C IN ('ECHO %%~B') DO (
      IF NOT EXIST "!SOLUTION_DIR!packages\%%~C.%%~D" (
	      CALL nuget install %%~C -Version %%~D -Framework %FRAMEWORK% -OutputDirectory "!SOLUTION_DIR!packages" -ConfigFile "!SOLUTION_DIR!tools\nuget\NuGet.Config"
      )
	  ) 
  )
  
  FOR /F "USEBACKQ TOKENS=1-30 DELIMS=^=,{}^(^) " %%G IN (`type "!SOLUTION_PATH!"`) DO (
    IF "%%~G" EQU "Project" (
	
      IF "%%~I" EQU "%PROJECT_TYPE%" (
	  
		    SET PROJECT_PATH=!SOLUTION_DIR!%%~L
        FOR %%A IN ("!PROJECT_PATH!") DO (
          SET TITLE=%%~nA
          SET GUID=%%~N
		      SET FOLDER=%%~dpA
        )
		
		    IF NOT EXIST "!PROJECT_PATH!" (
		      CALL :CreateProject "!PROJECT_PATH!" "!TITLE!" "!GUID!" "!FOLDER!"
		    )
	    )
	  )
  )
  EXIT /b
  
:CreateProject
  SET PROJECT_PATH=%~1
  SET TITLE=%~2
  SET GUID=%~3
  SET FOLDER=%~4

  IF NOT EXIST "!FOLDER!" (
    MKDIR "!FOLDER!"
    ECHO !FOLDER!
  ) 

  :: e.g. enter source/Owner.Library
  PUSHD "!FOLDER!"
		
  :: e.g. source/Owner.Library/Properties/AssemblyInfo.cs
  SET FILE=!FOLDER!!ASSEMBLY_INFO_FILE!
  FOR %%B IN ( "!FILE!" ) DO (
    :: e.g. source/Owner.Library/Properties
    IF NOT EXIST "%%~dpB" (
      MKDIR "%%~dpB"
      ECHO %%~dpB
    )
  )
  FOR %%X IN ( "!TITLE!" ) DO (
  >"!FILE!": ECHO !ASSEMBLY_INFO_CONTENT:NAME=%%~X!
  )
  ECHO !FILE!
		
        :: e.g. source/Owner.Library/Owner.Library.csproj
		SET FILE=!PROJECT_PATH!
		>"!FILE!":  ECHO ^<?xml version="1.0" encoding="utf-8"?^>
        >>"!FILE!": ECHO ^<Project ToolsVersion="14.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003"^>
        >>"!FILE!": ECHO   ^<PropertyGroup^>
        >>"!FILE!": ECHO     ^<ProjectGuid^>{!GUID!}^<^/ProjectGuid^>
        >>"!FILE!": ECHO     ^<AssemblyName^>!TITLE!^<^/AssemblyName^>
        >>"!FILE!": ECHO     ^<RootNamespace^>!TITLE!^<^/RootNamespace^>
        >>"!FILE!": ECHO     ^<SolutionDir Condition^=" '$(SolutionDir)' == '' "^>^$^(MSBuildThisFileDirectory^)..^\..^\^<^/SolutionDir^>
        >>"!FILE!": ECHO   ^<^/PropertyGroup^>
        >>"!FILE!": ECHO   ^<Import Project^="$(SolutionDir)tools\msbuild\net452.library.props" ^/^>
        >>"!FILE!": ECHO   ^<ItemGroup^>
        >>"!FILE!": ECHO     ^<None Include^="packages.config" ^/^>
        >>"!FILE!": ECHO     ^<None Include^="!TITLE!.nuspec" ^/^>
        >>"!FILE!": ECHO   ^<^/ItemGroup^>
        >>"!FILE!": ECHO   ^<ItemGroup^>
	    FOR %%B IN ("%COMMON_PACKAGES: =" "%") DO (
          CALL :FindPackageReferences "%%~B"
          IF NOT DEFINED PACKAGE_REFERENCES (
            CALL "%~dp0error" 404 "No dll found in the lib or compatible framework folder of lib for package !PACKAGE_ID! !PACKAGE_VERSION! in (!PACKAGE_FRAMEWORKS!)."
            EXIT /b
          )  
          FOR %%C IN (!PACKAGE_REFERENCES!) DO (
            SET PACKAGE_REFERENCE=%%~C
			FOR %%X IN ("!SOLUTION_DIR!") DO (
			  SET PACKAGE_PATH=!PACKAGE_REFERENCE:%%~X=..^\..^\!
			)
      FOR /F "USEBACKQ TOKENS=*" %%D IN (`@powershell "[System.Reflection.AssemblyName]::GetAssemblyName('!PACKAGE_REFERENCE!').FullName"`) DO (
        SET PACKAGE_FULL_NAME=%%~D
      )
  >>"!FILE!": ECHO     ^<Reference Include^="!PACKAGE_FULL_NAME!"^>
  >>"!FILE!": ECHO       ^<HintPath^>!PACKAGE_PATH!^<^/HintPath^>
  >>"!FILE!": ECHO       ^<Private^>True^<^/Private^>
  >>"!FILE!": ECHO     ^<^/Reference^>
    )
  )
  >>"!FILE!": ECHO   ^<^/ItemGroup^>
  >>"!FILE!": ECHO ^<^/Project^>
  ECHO !FILE! 

  :: e.g. source/Owner.Library/packages.config
  SET FILE=!FOLDER!packages.config
  >"!FILE!":  ECHO ^<?xml version="1.0" encoding="utf-8"?^>
  >>"!FILE!": ECHO ^<packages^>
  FOR %%B IN ("%COMMON_PACKAGES: =" "%") DO (
    FOR /F "TOKENS=1,2 DELIMS=@" %%C IN ('ECHO %%~B') DO (
  >>"!FILE!": ECHO   ^<package id^="%%C" version^="%%D" targetFramework^="%FRAMEWORK%" ^/^> 
    ) 
  )
  >>"!FILE!": ECHO ^<^/packages^>
  ECHO !FILE!
  

  :: e.g. source/Owner.Library/Owner.Library.nuspec
  SET FILE=!FOLDER!!TITLE!.nuspec
  >"!FILE!":  ECHO ^<?xml version="1.0" encoding="utf-8"?^>
  >>"!FILE!": ECHO ^<package^>
  >>"!FILE!": ECHO   ^<metadata^>
  >>"!FILE!": ECHO     ^<id^>$id$^<^/id^>
  >>"!FILE!": ECHO     ^<version^>$version$^<^/version^>
  >>"!FILE!": ECHO     ^<title^>$title$^<^/title^>
  >>"!FILE!": ECHO     ^<authors^>$author$^<^/authors^>
  >>"!FILE!": ECHO     ^<owners^>$author$^<^/owners^>
  >>"!FILE!": ECHO     ^<description^>$description$^<^/description^>
  >>"!FILE!": ECHO     ^<copyright^>$copyright$^<^/copyright^>
  >>"!FILE!": ECHO     ^<iconUrl^>%REPOS%/package-directory/raw/master/content/icons/$id$.png^<^/iconUrl^>
  >>"!FILE!": ECHO     ^<projectUrl^>%REPOS%^<^/projectUrl^>
  >>"!FILE!": ECHO     ^<repository type^="git" url^="%REPOS%" ^/^>
  >>"!FILE!": ECHO     ^<tags^>$id$ $author$^<^/tags^>
  >>"!FILE!": ECHO     ^<frameworkAssemblies^>
  FOR %%B IN ("%COMMON_FRAMEWORK_DLLS: =" "%") DO (
  >>"!FILE!": ECHO       ^<frameworkAssembly assemblyName^="%%~B" ^/^>
  )
  >>"!FILE!": ECHO     ^<^/frameworkAssemblies^>
  >>"!FILE!": ECHO     ^<dependencies^>
  FOR %%B IN ("%COMMON_PACKAGES: =" "%") DO (
    FOR /F "TOKENS=1,2 DELIMS=@" %%C IN ('ECHO %%~B') DO (
      IF "%%~D" NEQ "" (
  >>"!FILE!": ECHO       ^<dependency id^="%%~C" version^="%%~D" ^/^>
      ) ELSE (
  >>"!FILE!": ECHO       ^<dependency id^="%%~C" ^/^>
      )
    ) 
  )
  >>"!FILE!": ECHO     ^<^/dependencies^>
  >>"!FILE!": ECHO   ^<^/metadata^>
  >>"!FILE!": ECHO   ^<files^>
  >>"!FILE!": ECHO     ^<file src^="bin\$configuration$\$id$.dll" target^="lib\%FRAMEWORK%" ^/^>
  >>"!FILE!": ECHO     ^<file src^="bin\$configuration$\$id$.pdb" target^="lib\%FRAMEWORK%" ^/^>
  >>"!FILE!": ECHO   ^<^/files^>
  >>"!FILE!": ECHO ^<^/package^>
  ECHO !FILE!
	
	
  :: e.g. exit source/Owner.Library
  POPD
		

  EXIT /b 
