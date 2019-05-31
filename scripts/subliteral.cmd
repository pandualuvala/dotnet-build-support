@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
CALL NOW START
>!START!-literal.txt: ECHO %~1
CALL substitute "!START!-literal.txt" "%~2" "%~3"
TYPE !START!-literal.txt
DEL !START!-literal.txt