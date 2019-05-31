@ECHO OFF

PUSHD "%~dp0.."
FOR /F "tokens=* USEBACKQ" %%V IN (`call %~dp0gitversion %CD% /showvariable NuGetVersionV2`) DO ( 
  SET VERSION=%%V
)
POPD
ECHO %VERSION%